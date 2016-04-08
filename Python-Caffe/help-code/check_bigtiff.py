#!/usr/bin/python

import os
import sys
import numpy as np
import matplotlib.pyplot as plt
import skimage.io as io
from bs4 import BeautifulSoup as bsoup

import openslide as ops


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
fimg='/home/ar/data/Camelyon16_Challenge/data/Tumor_031.tif'

####################################
if __name__=='__main__':
    dataTif=BigTiffReader(fimg)
    print dataTif
    print '-----'