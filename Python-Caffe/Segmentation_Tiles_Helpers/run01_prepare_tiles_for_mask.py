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

import openslide as ops

####################################
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
    print '---------'
    parser = argparse.ArgumentParser('Generator Tiles from Mask  [%s]' % sys.argv[0], add_help=True)
    parser.add_argument("-pathBigTiff", help="Path to BigTiff file", required=True)
    parser.add_argument("-maskPrefix", help="Mask file prefix: /path/to/bigtiff.tif[:-4]{MaskPrefix}", required=True)
    opt = parser.parse_args()
    print opt
    #
    pathTiff=opt.pathBigTiff
    pathMsk ='%s%s' % (pathTiff[:-4], opt.maskPrefix)
    checkFile(pathTiff)
    checkFile(pathMsk)
    tiffReader=BigTiffReader(pathTiff)
    #
    imgMsk=(io.imread(pathMsk)>0)
    lstRowsMsk, lstColsMsk = np.where(imgMsk)
    nrMsk, ncMsk = imgMsk.shape
    ncTiffL0, nrTiffL0 = tiffReader.layerSizes[0]
    lstRowsTiffL0 = np.round(nrTiffL0 * (lstRowsMsk + 0.5) / nrMsk)
    lstColsTiffL0 = np.round(ncTiffL0 * (lstColsMsk + 0.5) / ncMsk)
    #
    dirOut='%s_MaskTiles' % (pathTiff[:-4])
    fidxTiles='%s/idx-tiles.txt' % dirOut
    if not os.path.isdir(dirOut):
        os.mkdir(dirOut)
    #
    numTiles=len(lstRowsTiffL0)
    sizTileL0 = 256
    sizTileL0d2 = int(256 / 2)
    with open(fidxTiles,'w') as f:
        f.write('row,col,filename\n')
        for ii in xrange(numTiles):
            trowMsk=int(lstRowsMsk[ii])
            tcolMsk=int(lstColsMsk[ii])
            trow0 = int(lstRowsTiffL0[ii])
            tcol0 = int(lstColsTiffL0[ii])
            timg = np.array( tiffReader.dataImg.read_region((tcol0 - sizTileL0d2, trow0 - sizTileL0d2), 0, (sizTileL0, sizTileL0)))[:,:,:3]
            tfnTileOut=os.path.join(dirOut, 'tilerc_%d_%d.png' % (trowMsk, tcolMsk) )
            io.imsave(tfnTileOut, timg)
            f.write('%d,%d,%s\n' % (trowMsk, tcolMsk, os.path.basename(tfnTileOut)))
            if (ii%200)==0:
                print '[%d/%d] -> (%s)' % (ii, numTiles, tfnTileOut)
