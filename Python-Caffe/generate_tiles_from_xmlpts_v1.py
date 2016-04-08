import os
import sys
import numpy as np
# from bs4 import BeautifulSoup as bsoup
import lxml
from lxml import etree
import openslide as ops
import matplotlib.pyplot as plt
import matplotlib.path as mplPath
import cv2
import skimage.io as io


###################################
def usage(argv):
    print('Usage: %s {/path/to/BigTiff-Image-With-XML-Metainfo}' % os.path.basename(argv[0]))

###################################
class DataInfo:
    def __init__(self, pathImage):
        self.fnIMG=None
        self.fnXML=None
        self.fnMSK=None
        self.loadFromFileName(pathImage)
    def loadFromFileName(self, pathImage):
        if os.path.isfile(pathImage):
            tmpBn=os.path.splitext(pathImage)[0]
            tdir=os.path.dirname(tmpBn)
            tmpFn=os.path.basename(tmpBn)
            ##bnIMG=os.path.join(tdir,tmpFn[:9])
            bnIMG=os.path.join(tdir,tmpFn[:10])
            tmpFnIMG='%s.tif' % bnIMG
            tmpFnXML='%s.xml' % tmpBn
            tmpFnMSK='%s_Mask.tif' % bnIMG
            self.checkIsFile(tmpFnIMG)
            self.checkIsFile(tmpFnXML)
            # self.checkIsFile(tmpFnMSK)
            self.fnIMG=tmpFnIMG
            self.fnXML=tmpFnXML
            self.fnMSK=tmpFnMSK
            # self.dataXML=self.readXmlData(self.fnXML)
            self.readXmlData(self.fnXML)
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
    def toString(self):
        if not self.isInitialized():
            return 'XML-DataInfo: is not initialized'
        else:
            tstr='XML-DataInfo: '
            for kk,vv in self.dataXML.items():
                tstr += '[%s]:%d, ' % (kk, len(vv))
            return tstr
    def __str__(self):
        return self.toString()
    def __repr__(self):
        return self.toString()
    def readXmlData(self, fnXML, isCleanEmptyGroups=True, isDebug=False):
        with open(fnXML,'r') as f:
            # (1) read data
            dataXML=etree.parse(fnXML)
            if isDebug:
                print etree.tostring(dataXML)
            dictGroup={}
            # (2) parse groups
            for ii in dataXML.findall('.//Group'):
                dictGroup[ii.get('Name')]=[]
            if isDebug:
                print dictGroup
            # (3) iterate coords
            for i,ii in enumerate(dataXML.findall('.//Annotation')):
                tIdGroup=ii.get('PartOfGroup')
                if tIdGroup in dictGroup.keys():
                    lstCoords=[]
                    for j,jj in enumerate(ii.findall('.//Coordinate')):
                        tx=np.float(jj.get('X'))
                        ty=np.float(jj.get('Y'))
                        tp=np.int(jj.get('Order'))
                        lstCoords.append((tp,tx,ty))
                        if isDebug and ((j%2000)==0):
                            print tIdGroup, '(',i,')[',j,'] : {', tp,tx,ty,'}'
                    arrCoords=np.array(lstCoords)
                    sidx=np.argsort(arrCoords[:,0])
                    arrCoords=arrCoords[sidx,1:]
                    arrCoords=np.append(arrCoords,[arrCoords[0]],axis=0)
                    dictGroup[tIdGroup].append(arrCoords)
            # (4) read Pts
            print 'Build XML-Tree of Dots:'
            xmlDots=dataXML.findall(".//Annotation[@Type='Dot']")
            self.mapDots={}
            for ii in xmlDots:
                tkeyGroup=ii.get('PartOfGroup')
                tn=ii.get('Name')
                if not self.mapDots.has_key(tkeyGroup):
                    self.mapDots[tkeyGroup]=[]
                xmlDotCoord=ii.find('.//Coordinate')
                tx=int(float(xmlDotCoord.get('X')))
                ty=int(float(xmlDotCoord.get('Y')))
                ts=int(float(xmlDotCoord.get('S')))
                self.mapDots[tkeyGroup].append((tx,ty,ts,tn))
            self.dataXML = dictGroup
    def saveDots2Tiles(self):
        wdir='%s-tiles' % os.path.splitext(self.fnXML)[0]
        idIMG=os.path.basename(wdir)
        fnIdx=os.path.join(wdir,'idx.csv')
        if not os.path.isdir(wdir):
            os.mkdir(wdir)
        tkeys=self.mapDots.keys()
        with open(fnIdx,'w') as fIdx:
            for kk in tkeys:
                todir=os.path.join(wdir,kk)
                if not os.path.isdir(todir):
                    os.mkdir(todir)
                lstDots=self.mapDots[kk]
                print ':: save [%s] --> %s' % (kk, fnIdx)
                for ii in lstDots:
                    tx=ii[0]
                    ty=ii[1]
                    ts=ii[2]
                    timg=np.array(self.dataIMG.read_region((tx-ts/2,ty-ts/2),0,(ts,ts)))
                    fnOut=os.path.join(todir,'%s.png' % ii[3])
                    ##cv2.imwrite(fnOut,timg)
                    io.imsave(fnOut,timg)
                    fIdx.write('%s/%s/%s,%d,%d,%d\n' % (idIMG,kk,ii[3],tx,ty,ts))

###################################
if __name__=='__main__':
    if len(sys.argv)<2:
        usage(sys.argv)
        sys.exit(1)
    fnPath=sys.argv[1]
    dataInfo=DataInfo(fnPath)
    print '----'
    print dataInfo
    # print dataInfo.mapDots
    dataInfo.saveDots2Tiles()
