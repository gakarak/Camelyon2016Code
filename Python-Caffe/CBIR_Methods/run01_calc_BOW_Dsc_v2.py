#!/usr/bin/python
from reportlab.graphics.widgetbase import Face

import skimage.io as io
import cv2
import numpy as np
import matplotlib.pyplot as plt
import pandas as pd
import argparse
import sys
import os

# def_fidx='/home/ar/data/Camelyon16_Challenge/dataset-500-shuf-2classes2/idx.txt'
from django.db.models.expressions import F
from docutils.nodes import header


def getDetector(strDet="SIFT", parP1="500", parP2=3):
    ret=None
    if strDet=="SIFT":
        detName="%s(%d,%d)" % (strDet, parP1, parP2)
        detRet=cv2.SIFT(parP1, parP2)
        ret=(detRet,detName)
    elif strDet=="SURF":
        detName="%s(%d,%d)" % (strDet, parP1, parP2)
        detRet=cv2.SURF(parP1, parP2)
        ret=(detRet,detName)
    else:
        pass
    return ret

############################
if __name__=='__main__':
    parser=argparse.ArgumentParser('Create BOW Dictionary [%s]' % sys.argv[0], add_help=True)
    parser.add_argument("-idx",     help="Path to index-file with image paths", required=True)
    opt=parser.parse_args()
    fidx=opt.idx
    dirOut=os.path.dirname(fidx)
    #
    csvData=pd.read_csv(fidx)
    lstFn=csvData['path']
    numImg=len(lstFn)
    numImgWork=10
    rndIdx=np.random.permutation(numImg)[:numImgWork]

    lstDet=(getDetector("SIFT",800,3), getDetector("SURF",400))
    arrDsc=None
    for ddi,dd in enumerate(lstDet):
        det=dd[0]
        detName=dd[1]
        for i,ii in enumerate(rndIdx):
            timg=io.imread(lstFn[ii])[:,:,:3]
            lstKeys,lstDsc=det.detectAndCompute(timg, None)
            if arrDsc is None:
                arrDsc=lstDsc
            else:
                arrDsc=np.concatenate( (arrDsc,lstDsc) )
            timgKp=cv2.drawKeypoints(timg, lstKeys, flags=cv2.DRAW_MATCHES_FLAGS_DRAW_RICH_KEYPOINTS)
            # plt.figure()
            # plt.subplot(1,2,1), plt.imshow(timg),   plt.title('Original')
            # plt.subplot(1,2,2), plt.imshow(timgKp), plt.title('Original+Kp #%d' % len(lstKeys))
            # plt.show()
            if (i%100)==0:
                print '[%s] %d/%d' % (detName, i, numImgWork)
        foutDsc="%s/dataset_BOW_Dsc_%s.csv" % (dirOut, detName)
        tmp=pd.DataFrame(arrDsc)
        tmp.to_csv(foutDsc, header=False, index=False)
    print '----'
