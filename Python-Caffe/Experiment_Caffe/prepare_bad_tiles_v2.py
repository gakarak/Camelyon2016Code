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


fnTiff='/home/ar/data/Camelyon16_Challenge/data/Tumor_031.tif'
fnSegmMask='/home/ar/data/Camelyon16_Challenge/data/Tumor_031.tif-L8.png-segm.png'
fnMaskEval='/home/ar/data/Camelyon16_Challenge/data/Tumor_031_EvaluationMask.png'
sizTile0=256

if __name__=='__main__':
    fnMaskCls='%s-clsmsk.png' % fnSegmMask
    #
    tiffReader=BigTiffReader(fnTiff)
    maskCls=(io.imread(fnMaskCls)>0.90)
    maskEval0=io.imread(fnMaskEval)
    maskEval=tf.resize(maskEval0, maskCls.shape)
    maskEval=(maskEval>0)
    maskEval=morph.dilation(maskEval, selem=disk(10))
    maskWithotTumor=maskCls & (~maskEval)
    #
    fnMaskClsGood='%s-clsmsk-good.png' % fnSegmMask
    fnMaskClsBad='%s-clsmsk-bad.png' % fnSegmMask
    io.imsave(fnMaskClsBad,  255*np.uint8(maskWithotTumor))
    io.imsave(fnMaskClsGood, 255*np.uint8(maskEval0>0))
    #
    nrow1,ncol1 = maskEval.shape
    ncol0,nrow0 = tiffReader.layerSizes[0]
    # !!!
    ridx1,cidx1=np.where(maskWithotTumor)
    ridx0=np.round(nrow0 * (ridx1 + 0.5) / nrow1).astype(np.int)
    cidx0=np.round(ncol0 * (cidx1 + 0.5) / ncol1).astype(np.int)
    #
    print '(process)--> %s' % fnMaskClsBad
    numIdx=len(ridx0)
    tdirOut='%s-badtiles' % fnSegmMask
    if not os.path.isdir(tdirOut):
        os.mkdir(tdirOut)
    for ii in xrange(numIdx):
        trow=ridx0[ii]
        tcol=cidx0[ii]
        timg=np.array(tiffReader.dataImg.read_region((tcol-sizTile0/2, trow-sizTile0/2), 0, (sizTile0,sizTile0)))
        tfout='%s/badtile_c%dr%d.png' % (tdirOut, tcol, trow )
        io.imsave(tfout, timg)
        if (ii%100)==0:
            print "%d/%d" % (ii,numIdx)
    #
    # plt.figure()
    # plt.subplot(1,4,1)
    # plt.imshow(maskCls), plt.title('Mask: Cls')
    # plt.subplot(1,4,2)
    # plt.imshow(maskEval0), plt.title('Mask: Eval Basic')
    # plt.subplot(1,4,3)
    # plt.imshow(maskEval),  plt.title('Mask: Eval')
    # plt.subplot(1,4,4)
    # plt.imshow(maskWithotTumor), plt.title('Mask: Errors withous Tumor')
    # plt.show()
    #
    # print tiffReader
    # print '---------'