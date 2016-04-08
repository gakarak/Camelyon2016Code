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

from run02_segment_with_caffe_v2 import BigTiffReader

import openslide as ops

fnIdx='/home/ar/data.CAMELYON16_Full_for_Start/Train_Tumor_L8/idx_Tumor_Msk.txt'
dirTiff='/home/ar/data.CAMELYON16_Full_for_Start/Train_Tumor'
dirEval='/home/ar/data.CAMELYON16_Full_for_Start/Evaluation/EvaluationMasks'

if __name__=='__main__':
    with open(fnIdx,'r') as f:
        lstIdx=f.read().splitlines()
    for ii in lstIdx:
        fnBase=os.path.basename(ii)[:-16]
        fnTiff=os.path.join(dirTiff, fnBase)
        tiffReader=BigTiffReader(fnTiff)
        fnMaskCls='%s-clsmsk.png' % ii
        fnMaskEval='%s/%s_EvaluationMask.png' % (dirEval, fnBase[:-4])
        maskCls=(io.imread(fnMaskCls)>0.95)
        maskEval0=io.imread(fnMaskEval)
        maskEval=tf.resize(maskEval0, maskCls.shape)
        maskEval=(maskEval>0)
        maskEval=morph.dilation(maskEval, selem=disk(10))
        maskWithotTumor=maskCls & (~maskEval)
        #
        fnMaskClsGood='%s-clsmsk-good.png' % ii
        fnMaskClsBad='%s-clsmsk-bad.png' % ii
        io.imsave(fnMaskClsBad,  255*np.uint8(maskWithotTumor))
        io.imsave(fnMaskClsGood, 255*np.uint8(maskEval0>0))
        #
        ridx,cidx=np.where(maskEval)
        #
        print '(process)--> %s' % fnMaskClsBad
        numIdx=len(ridx)
        tdirOut=''
        # for ii in xrange(numIdx):

        #
        # plt.figure()
        # plt.subplot(1,3,1)
        # plt.imshow(maskCls)
        # plt.subplot(1,3,2)
        # plt.imshow(maskEval)
        # plt.subplot(1,3,3)
        # plt.imshow(maskWithotTumor)
        # plt.show()
        # print tiffReader
        # print '---------'