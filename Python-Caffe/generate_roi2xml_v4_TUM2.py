import os
import sys
import numpy as np
import argparse
from lxml import etree
import openslide as ops
import matplotlib.pyplot as plt
import matplotlib.path as mplPath

###################################
class DataInfo:
    def __init__(self, pathImage):
        self.fnIMG=None
        self.fnXML=None
        self.loadFromFileName(pathImage)
    def loadFromFileName(self, pathImage):
        if os.path.isfile(pathImage):
            # tmpBn=os.path.splitext(pathImage)[0]
            tmpFnIMG=pathImage
            tmpFnXML='%s_TUM2.xml' % pathImage[:-4]
            self.checkIsFile(tmpFnIMG)
            self.checkIsFile(tmpFnXML)
            self.fnIMG=tmpFnIMG
            self.fnXML=tmpFnXML
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
            for i, kk in enumerate(self.dataXML):
                tstr += '%d: %d, ' % (i, len(kk))
            return tstr
    def __str__(self):
        return self.toString()
    def __repr__(self):
        return self.toString()
    def readXmlData(self, fnXML, isDebug=False):
        with open(fnXML,'r') as f:
            # (1) read data
            dataXML=etree.parse(fnXML)
            if isDebug:
                print etree.tostring(dataXML)
            listPolygons=[]
            self.lstPaths=[]
            # (3) iterate coords
            for i,ii in enumerate(dataXML.findall(".//Annotation[@PartOfGroup='TUM2']")):
                lstCoords=[]
                for j,jj in enumerate(ii.findall('.//Coordinate')):
                    tx=np.float(jj.get('X'))
                    ty=np.float(jj.get('Y'))
                    tp=np.int(jj.get('Order'))
                    lstCoords.append((tp,tx,ty))
                arrCoords=np.array(lstCoords)
                sidx=np.argsort(arrCoords[:,0])
                arrCoords=arrCoords[sidx,1:]
                arrCoords=np.append(arrCoords,[arrCoords[0]],axis=0)
                listPolygons.append(arrCoords)
                self.lstPaths.append(mplPath.Path(arrCoords))
            self.dataXML = listPolygons

###################################
if __name__=='__main__':
    parser=argparse.ArgumentParser('XML-pts generator for TUM2 mask [%s]' % sys.argv[0], add_help=True)
    parser.add_argument("-pathTiff",    help="Path to BigTiff Image", required=True)
    opt=parser.parse_args()
    #
    dataInfo=DataInfo(opt.pathTiff)
    print '----'
    print dataInfo
    #
    siz0=dataInfo.dataIMG.level_dimensions[0]
    print siz0
    tplgn=np.array([[0,0],[0,siz0[1]],[siz0[0],siz0[1]],[siz0[0],0],[0,0]])
    #
    sizTile=256
    sizTile2=sizTile/2
    XX=range(4*sizTile,siz0[0]-4*sizTile,sizTile/2)
    YY=range(4*sizTile,siz0[1]-4*sizTile,sizTile/2)
    lstCoordsPc=np.array([(xx,yy) for xx in XX for yy in YY])
    lstCoordsP1=np.array([(xx-sizTile2,yy-sizTile2) for xx in XX for yy in YY])
    lstCoordsP2=np.array([(xx-sizTile2,yy+sizTile2) for xx in XX for yy in YY])
    lstCoordsP3=np.array([(xx+sizTile2,yy+sizTile2) for xx in XX for yy in YY])
    lstCoordsP4=np.array([(xx+sizTile2,yy-sizTile2) for xx in XX for yy in YY])
    lstPolygonTiles=[]
    for i,ii in enumerate(dataInfo.lstPaths):
        tmp=ii.contains_points(lstCoordsP1)&ii.contains_points(lstCoordsP2)&ii.contains_points(lstCoordsP3)&ii.contains_points(lstCoordsP4)
        tmp1=tmp
        lstPolygonTiles.append(lstCoordsPc[tmp1,:])
        print '(%d) -> %d' % (i, np.sum(tmp1))
    # [Prepare XML-Tree]
    # (1) Append Groups:
    keyName='TUM2'
    tdataXML=etree.parse(dataInfo.fnXML)
    tmp1=tdataXML.find('.//AnnotationGroups')
    tmp1.append(etree.XML('<Group Name="%s_tiles" PartOfGroup="None" Color="#FFFF00"><Attributes/></Group>' % keyName))
    # (2) Append Coordinates:
    tmp2=tdataXML.find('.//Annotations')
    cnt=0
    for ll in lstPolygonTiles:
        for tti,tt in enumerate(ll):
            cnt+=1
            tstrXML='<Annotation Name="tilec_%s_%d" Type="Dot" PartOfGroup="%s_tiles" Color="#FF00CC"><Coordinates>\n' % (keyName,cnt,keyName)
            ppi=0
            tstrXML+='<Coordinate Order="%d" X="%0.1f" Y="%0.1f" S="%d" />\n' % (ppi,tt[0],tt[1],sizTile)
            tstrXML+='</Coordinates></Annotation>'
            tmp2.append(etree.XML(tstrXML))
    fout='%s-proc.xml' % os.path.splitext(dataInfo.fnXML)[0]
    ##print etree.tostring(tdataXML, pretty_print=True)
    with open(fout,'w') as f:
        f.write(etree.tostring(tdataXML, pretty_print=True))
    # print fout
