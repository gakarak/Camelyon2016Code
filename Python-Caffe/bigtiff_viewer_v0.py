#!usr/bin/python
__author__ = 'ar'

import os
import sys
import numpy as np
from bs4 import BeautifulSoup as bsoup
import openslide as ops
import cv2

def usage(argv):
    print('Usage: %s {/path/to/BigTiff-Image-With-XML-Metainfo}' % os.path.basename(argv[0]))

class DataInfo:
    def __init__(self, pathImage):
        self.fnIMG=None
        self.fnXML=None
        self.fnMSK=None
        self.loadFromFileName(fnPath)
    def loadFromFileName(self, pathImage):
        if os.path.isfile(pathImage):
            tmpBn=os.path.splitext(pathImage)[0]
            tmpFnIMG='%s.tif' % tmpBn
            tmpFnXML='%s.xml' % tmpBn
            tmpFnMSK='%s_Mask.tif' % tmpBn
            self.checkIsFile(tmpFnIMG)
            self.checkIsFile(tmpFnXML)
            self.checkIsFile(tmpFnMSK)
            self.fnIMG=tmpFnIMG
            self.fnXML=tmpFnXML
            self.fnMSK=tmpFnMSK
            self.dataXML=self.readXmlData(self.fnXML)
            self.dataIMG=ops.OpenSlide(self.fnIMG)
        else:
            self.checkIsFile(pathImage)
            sys.exit(1)
    def isInitialized(self):
        return (self.fnIMG is not None)
    def checkIsFile(self, fnpath, isFinIfNotFound=True):
        if not os.path.isfile(fnpath):
            print('Cant find file [%s], exit...' % fnpath)
            if isFinIfNotFound:
                sys.exit(1)
    def readXmlData(self, fnXML, isCleanEmptyGroups=True, isDebug=False):
        with open(fnXML,'r') as f:
            # (1) read data
            dataXML=bsoup(f.read(),'lxml-xml')
            if isDebug:
                print(dataXML.prettify())
            dictGroup={}
            # (2) parse groups
            for ii in dataXML.findAll('Group'):
                tmp=dict(ii.attrs)
                dictGroup[tmp['Name']]=[]
            if isDebug:
                print dictGroup
            # (3) iterate coords
            for i,ii in enumerate(dataXML.findAll('Annotation')):
                tmp=dict(ii.attrs)
                tIdGroup=tmp['PartOfGroup']
                lstCoords=[]
                for j,jj in enumerate(ii.findAll('Coordinate')):
                    tx=np.float(jj.attrs['X'])
                    ty=np.float(jj.attrs['Y'])
                    tp=np.int(jj.attrs['Order'])
                    lstCoords.append((tp,tx,ty))
                    if isDebug and ((j%2000)==0):
                        print tIdGroup, '(',i,')[',j,'] : {', tp,tx,ty,'}'
                arrCoords=np.array(lstCoords)
                sidx=np.argsort(arrCoords[:,0])
                arrCoords=arrCoords[sidx,1:]
                dictGroup[tIdGroup].append(arrCoords)
            # (4) Clean empty Groups:
            if isCleanEmptyGroups:
                tlstKeyEmpty=[kk for kk,vv in dictGroup.items() if len(vv)<1]
                if isDebug:
                    print 'Empty keys: ', tlstKeyEmpty
                for kk in tlstKeyEmpty:
                    del dictGroup[kk]
            return dictGroup

if __name__=='__main__':
    if len(sys.argv)<2:
        usage(sys.argv)
        sys.exit(1)
    fnPath=sys.argv[1]
    dataInfo=DataInfo(fnPath)
    print '----'
    tIdx=-2
    numLevels=dataInfo.dataIMG.level_count
    listScales=dataInfo.dataIMG.level_downsamples
    listSizes=dataInfo.dataIMG.level_dimensions
    tScale=listScales[-1]
    # tScale=float(listSizes[0][1])/float(listSizes[tIdx][1])
    tSize=np.round(np.array(listSizes[0])/tScale).astype(np.int).tolist()
    tSize=listSizes[tIdx]
    timg=np.array(dataInfo.dataIMG.read_region((0,0), numLevels+tIdx,tSize))
    print tSize
    print tScale
    for ii in dataInfo.dataXML.values():
        for jj in ii:
            tpts=np.round(jj/tScale).astype(np.int)
            cv2.drawContours(timg,[tpts],-1,(0,255,0))
    cv2.imshow('win', timg)
    while True:
        tkey=cv2.waitKey(0)
        if tkey==27:
            break

