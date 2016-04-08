#!/usr/bin/python

import os
import sys
import numpy as np
import matplotlib.pyplot as plt
import skimage.io as io
import skimage.transform as tf
import skimage.morphology as morph
from skimage.morphology import disk, square
from bs4 import BeautifulSoup as bsoup
import caffe
import argparse
import glob
import matplotlib.pyplot as plt
import time
import pandas as pd

import openslide as ops

######################################
def checkFile(fnPath, isExit=True, isCheckDir=False):
    if not isCheckDir:
        isOk=os.path.isfile(fnPath)
    else:
        isOk=os.path.isdir(fnPath)
    if not isOk:
        if not isCheckDir:
            print 'ERROR: cant find file [%s]' % fnPath
        else:
            print 'ERROR: cant find directory [%s]' % fnPath
        if isExit:
            sys.exit(1)
    return isOk

def genRanges(numSamples, sizeBatch):
    l=range(numSamples)
    tmp=[l[x:x+sizeBatch] for x in xrange(0,len(l),sizeBatch)]
    return tmp

####################################
class CaffeBatchClassifier:
    def __init__(self):
        self.net=None
    def loadModelFromDir(self, dirWithModel):
        pathModelDef=os.path.join(dirWithModel, 'deploy.prototxt')
        pathImgMean=os.path.join(dirWithModel, 'mean.binaryproto')
        pathLabels=os.path.join(dirWithModel, 'labels.txt')
        lstModelW=glob.glob('%s/*.caffemodel' % dirWithModel)
        if not os.path.isfile(pathModelDef):
            print "ERROR: cant find Model file [%s] in dir [%s]" % (os.path.basename(pathModelDef), dirWithModel)
            sys.exit(1)
        if not os.path.isfile(pathImgMean):
            print "ERROR: cant find Mean-Image caffe-file [%s] in dir [%s]" % (os.path.basename(pathImgMean), dirWithModel)
            sys.exit(1)
        if not os.path.isfile(pathLabels):
            print "ERROR: cant find Labels file [%s] in dir [%s]" % (os.path.basename(pathLabels), dirWithModel)
            sys.exit(1)
        if len(lstModelW)<1:
            print "ERROR: cant find [.caffemodel] files in directory [%s]" % dirWithModel
            sys.exit(1)
        #
        pathModelW=lstModelW[0]
        self.loadModel(pathModelDef, pathModelW, pathImgMean, pathLabels)
    def loadModel(self, pathModelDef, pathModelW, pathImgMean, pathLabels):
        self.fnModelDef=pathModelDef
        self.fnModelW=pathModelW
        self.fnMean=pathImgMean
        self.fnLabels=pathLabels
        #
        checkFile(self.fnModelDef)
        checkFile(self.fnModelW)
        checkFile(self.fnMean)
        checkFile(self.fnLabels)
        #
        self.loadLabels()
        self.loadMeanInfo()
#        caffe.set_mode_cpu()
        caffe.set_mode_gpu()
        self.net = caffe.Net(self.fnModelDef,
                             self.fnModelW,
                             caffe.TEST)
        self.sizBatch=self.net.blobs['data'].data.shape[0]
        self.transformer = caffe.io.Transformer({'data': self.net.blobs['data'].data.shape})
        self.transformer.set_transpose('data', (2,0,1))
        self.transformer.set_mean('data', self.mu)
        self.transformer.set_channel_swap('data', (2,1,0))
        #
        print '----'
    def toString(self):
        tstr="def: [%s]\nmodel: [%s]\nmean: [%s]\nlbl: [%s]\n" % (self.fnModelDef,
                                                                  self.fnModelW,
                                                                  self.fnMean,
                                                                  self.fnLabels)
        return tstr
    def __str__(self):
        return self.toString()
    def __repr__(self):
        return self.toString()
    def loadLabels(self):
        with open(self.fnLabels, 'r') as f:
            self.lbl=f.read().splitlines()
            self.idxTumor=self.lbl.index('Tumor')
    def loadMeanInfo(self):
        blobMean=caffe.proto.caffe_pb2.BlobProto()
        with open(self.fnMean,'r') as f:
            blobMean.ParseFromString(f.read())
            arrMean=np.array(caffe.io.blobproto_to_array(blobMean))
            self.mu = np.mean(arrMean[0],axis=(1,2))
    def loadAndTransformImage(self, imagePath):
        checkFile(imagePath)
        timg=io.imread(imagePath)[:,:,:3]
        return self.transformer.preprocess('data', timg)
    def processBatch(self, listPathImg):
        numImg=len(listPathImg)
        lstBatches=genRanges(numImg, self.sizBatch)
        numBatches=len(lstBatches)
        arrProb=None
        arrIdx=None
        for bbi,bb in enumerate(lstBatches):
            for ppi,pp in enumerate(bb):
                tfnImg=listPathImg[pp]
                # print tfnImg
                timg=self.loadAndTransformImage(tfnImg)
                self.net.blobs['data'].data[ppi]=timg
            tout=self.net.forward()
            tprob=np.max(tout['prob'][:len(bb)],axis=1)
            tidx =np.argmax(tout['prob'][:len(bb)],axis=1)
            if arrProb is None:
                arrProb = tprob
                arrIdx  = tidx
            else:
                arrProb = np.append(arrProb, tprob)
                arrIdx  = np.append(arrIdx,  tidx)
            print '%d/%d' % (bbi, numBatches)
        tret=[(listPathImg[ii], self.lbl[arrIdx[ii]], arrProb[ii]) for ii in xrange(numImg)]
        return tret
    def processBatchFromTiff(self, ptrTiff, lstRows, lstCols, idLevel=2, sizTile=64):
        print ':: Start Caffe processing, BatchSize = %d' % self.sizBatch
        # sizTile2=int(sizTile/2)
        sizTileL0=256
        sizTileL0d2=int(256/2)
        numImg=len(lstRows)
        lstBatches=genRanges(numImg, self.sizBatch)
        numBatches=len(lstBatches)
        arrProb=None
        # arrIdx=None
        for bbi,bb in enumerate(lstBatches):
            print '%d/%d' % (bbi, numBatches)
            print '\tread tiles from BigTiff...'
            t0=time.time()
            for ppi,pp in enumerate(bb):
                trow0=int(lstRows[pp])
                tcol0=int(lstCols[pp])
                timg=np.array(ptrTiff.dataImg.read_region((tcol0-sizTileL0d2,trow0-sizTileL0d2),0, (sizTileL0,sizTileL0)))[:,:,:3]
                timgr=255.*tf.resize(timg, (sizTile,sizTile), order=1)
                timg=self.transformer.preprocess('data', timgr)
                self.net.blobs['data'].data[ppi]=timg
            print '\t... %0.5fs' % (time.time()-t0)
            print '\t:net.forward()...'
            t0=time.time()
            tout=self.net.forward()
            print '\t... %0.5fs' % (time.time()-t0)
            tprob=tout['prob'][:len(bb),self.idxTumor]#self.idxTumor]
            if arrProb is None:
                arrProb = tprob
                # arrIdx  = tidx
            else:
                arrProb = np.append(arrProb, tprob)
                # arrIdx  = np.append(arrIdx,  tidx)
        # tret=(arrProb, [self.lbl[arrIdx[ii]] for ii in xrange(numImg)])
        tret=arrProb
        return tret
    def processBatchFromListFnImg(self, lstFnImg):
        numImg=len(lstFnImg)
        print ':: Start Caffe processing, #Image: %d' % numImg
        lstBatches=genRanges(numImg, self.sizBatch)
        numBatches=len(lstBatches)
        arrProb=None
        # arrIdx=None
        for bbi,bb in enumerate(lstBatches):
            print '%d/%d' % (bbi, numBatches)
            t0=time.time()
            for ppi,pp in enumerate(bb):
                tfimg=lstFnImg[pp]
                timgr=io.imread(tfimg)[:,:,:3].astype(np.float)
                timg=self.transformer.preprocess('data', timgr)
                self.net.blobs['data'].data[ppi]=timg
            print '\t... %0.5fs' % (time.time()-t0)
            print '\t:net.forward()...'
            t0=time.time()
            tout=self.net.forward()
            print '\t... %0.5fs' % (time.time()-t0)
            tprob=tout['prob'][:len(bb),self.idxTumor]#self.idxTumor]
            if arrProb is None:
                arrProb = tprob
                # arrIdx  = tidx
            else:
                arrProb = np.append(arrProb, tprob)
                # arrIdx  = np.append(arrIdx,  tidx)
        # tret=(arrProb, [self.lbl[arrIdx[ii]] for ii in xrange(numImg)])
        tret=arrProb
        return tret


####################################
class BigTiffReader:
    def __init__(self, parFnImg=None):
        self.fnImg=None
        self.dataImg=None
        self.realScales=None
        self.numLevels=-1
        self.layerSizes=None
        if parFnImg is not None:
            self.loadImage(parFnImg)
    def loadImage(self, parFnImg):
        if os.path.isfile(parFnImg):
            self.dataImg=ops.OpenSlide(parFnImg)
            xmlInfo=bsoup(self.dataImg.properties['tiff.ImageDescription'],'lxml-xml')
            lstXMLObj=xmlInfo.find_all("DataObject",  ObjectType="PixelDataRepresentation")
            arrSizesMm=np.zeros(len(lstXMLObj), np.float)
            for i,ii in enumerate(lstXMLObj):
                tmp=ii.find_all("Attribute", Name="DICOM_PIXEL_SPACING")[0]
                tsiz=float(tmp.getText().split(" ")[0].replace('"',''))
                tidx=int(ii.find_all("Attribute", Name="PIIM_PIXEL_DATA_REPRESENTATION_NUMBER")[0].getText())
                print i, " : ", tidx, " : ", tsiz
                arrSizesMm[tidx]=tsiz
            self.realScales=np.round(arrSizesMm/arrSizesMm[0])
            arrLayerSizes=np.array(self.dataImg.level_dimensions)
            self.layerSizes=np.array([(arrLayerSizes[0][0]/ss, arrLayerSizes[0][1]/ss) for ss in self.realScales], np.int)
            self.numLevels=self.dataImg.level_count
    def getImageOnLevel(self,idLevel):
        return np.array(self.dataImg.read_region((0,0),idLevel, self.layerSizes[idLevel]))[:,:,:3]
    def toString(self):
        str="#Scales=%s\nScales=%s\nTile-Sizes: %s" % (self.numLevels, self.realScales, self.layerSizes)
        return str
    def __repr__(self):
        return self.toString()
    def __str__(self):
        return self.toString()


####################################
if __name__=='__main__':
    parser=argparse.ArgumentParser('Caffe segmentator [%s]' % sys.argv[0], add_help=True)
    parser.add_argument("-dirCaffe", help="Path to dir with Caffe model", required=True)
    parser.add_argument("-pathIdxTiles",  help="Path to Tiles Index File", required=True)
    opt=parser.parse_args()
    print '-------'
    checkFile(opt.dirCaffe, isCheckDir=True)
    checkFile(opt.pathIdxTiles)
    print '-------'
    clsCaffe=CaffeBatchClassifier()
    clsCaffe.loadModelFromDir(opt.dirCaffe)
    print clsCaffe
    #
    wdir=os.path.dirname(opt.pathIdxTiles)
    dataIdx=pd.read_csv(opt.pathIdxTiles)
    lstPathTiles=[os.path.join(wdir,ii) for ii in dataIdx['filename']]
    foutProb='%s-GoogleNet-Prob.csv' % (opt.pathIdxTiles)
    retProb=clsCaffe.processBatchFromListFnImg(lstPathTiles)
    dataIdx['prob']=retProb
    dataIdx.to_csv(foutProb)
    print '----'
