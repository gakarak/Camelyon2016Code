#!/usr/bin/python

import sys
import os
import pandas as pd
import numpy as np
import skimage.io as io
import caffe

######################################
def usage(sysArgv):
    print 'Usage: %s {/path/to/filenameas-and-labels-index.txt}' % os.path.basename(sysArgv[0])

def checkFile(fnPath, isExit=True):
    isOk=os.path.isfile(fnPath)
    if not isOk:
        print 'ERROR: cant find file [%s]' % fnPath
        if isExit:
            sys.exit(1)
    return isOk

def genRanges(numSamples, sizeBatch):
    l=range(numSamples)
    tmp=[l[x:x+sizeBatch] for x in xrange(0,len(l),sizeBatch)]
    return tmp

######################################
# def_fnCaffeModelDef='/home/ar/deep-learning/CAMELYON16_Dataset/20160305-171855-cfcd_epoch_30.0/deploy.prototxt'
# def_fnCaffeModelWeight='/home/ar/deep-learning/CAMELYON16_Dataset/20160305-171855-cfcd_epoch_30.0/snapshot_iter_1410.caffemodel'
# def_fnCaffeImageMean='/home/ar/deep-learning/CAMELYON16_Dataset/20160305-171855-cfcd_epoch_30.0/mean.binaryproto'
# def_fnLabels='/home/ar/deep-learning/CAMELYON16_Dataset/20160305-171855-cfcd_epoch_30.0/labels.txt'

def_fnCaffeModelDef='/home/ar/deep-learning/CAMELYON16_Dataset/20160306-193628-3f07_epoch_30.0/deploy.prototxt'
def_fnCaffeModelWeight='/home/ar/deep-learning/CAMELYON16_Dataset/20160306-193628-3f07_epoch_30.0/snapshot_iter_1800.caffemodel'
def_fnCaffeImageMean='/home/ar/deep-learning/CAMELYON16_Dataset/20160306-193628-3f07_epoch_30.0/mean.binaryproto'
def_fnLabels='/home/ar/deep-learning/CAMELYON16_Dataset/20160306-193628-3f07_epoch_30.0/labels.txt'


######################################
class CaffeBatchClassifier:
    def __init__(self):
        self.net=None
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
    def loadLabels(self):
        with open(self.fnLabels, 'r') as f:
            self.lbl=f.read().splitlines()
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

######################################
if __name__=='__main__':
    checkFile(def_fnCaffeModelDef)
    checkFile(def_fnCaffeModelWeight)
    checkFile(def_fnCaffeImageMean)
    checkFile(def_fnLabels)
    #
    if len(sys.argv)<2:
        usage(sys.argv)
        sys.exit(0)
    fidx=sys.argv[1]
    checkFile(fidx)
    #
    csvData=pd.read_csv(fidx)
    classCaffe=CaffeBatchClassifier()
    classCaffe.loadModel(def_fnCaffeModelDef,
                         def_fnCaffeModelWeight,
                         def_fnCaffeImageMean,
                         def_fnLabels)
    retClass=classCaffe.processBatch(csvData['path'].tolist())
    foutIdx='%s-cls.csv' % fidx
    print '--> Save results to [%s]' % foutIdx
    with open(foutIdx,'w') as f:
        f.write('path,label,prob,clslalbel\n')
        numImg=len(retClass)
        for ii in xrange(numImg):
            str='%s,%s,%0.3f,%s\n' % (retClass[ii][0],
                                          csvData['label'][ii],
                                          retClass[ii][2],
                                          retClass[ii][1])
            f.write(str)
            print str