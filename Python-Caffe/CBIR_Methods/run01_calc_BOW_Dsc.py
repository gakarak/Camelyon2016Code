#!/usr/bin/python

import skimage.io as io
import cv2
import numpy as np
import matplotlib.pyplot as plt
import pandas as pd
import argparse
import sys

# def_fidx='/home/ar/data/Camelyon16_Challenge/dataset-500-shuf-2classes2/idx.txt'

############################
if __name__=='__main__':
    parser=argparse.ArgumentParser('Create BOW Dictionary [%s]' % sys.argv[0], add_help=True)
    parser.add_argument("-idx",     help="Path to index-file with image paths", required=True)
    opt=parser.parse_args()
    fidx=opt.idx
    #
    csvData=pd.read_csv(fidx)
    lstFn=csvData['path']
    numImg=len(lstFn)
    det=cv2.SIFT(1000, 3)
    # det=cv2.SURF(400)
    arrDsc=None
    for i,ii in enumerate(lstFn):
        timg=io.imread(ii)[:,:,:3]
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
            print '%d/%d' % (i, numImg)
    print '----'
