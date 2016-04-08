#!/usr/bin/python

import os
import sys
import numpy as np
import matplotlib.pyplot as plt
import skimage.io as io
from bs4 import BeautifulSoup as bsoup

import openslide as ops

##############################
def usage(sysArgv):
    print 'Usage: %s {/path/to/idx.txt}' % sysArgv[0]

##############################
if __name__=='__main__':
    if len(sys.argv)<2:
        usage(sys.argv)
        sys.exit(1)
    fidx=sys.argv[1]
    if not os.path.isfile(fidx):
        print 'Cant find idx-file [%s]' % fidx
        sys.exit(1)
    lstPath=[]
    lstInvLayersIdx=(1,2,3,4)
    wdir=os.path.dirname(fidx)
    with open(fidx,'r') as f:
        lstFn=f.read().splitlines()
        lstPath = [os.path.join(wdir,ii) for ii in lstFn]
    fidxOut="%s-hardware.txt" % fidx
    with open(fidxOut,'w') as f:
        for ff in lstPath:
            dataImg=ops.OpenSlide(ff)
            xmlInfo=bsoup(dataImg.properties['tiff.ImageDescription'],'lxml-xml')
            txtHardware=xmlInfo.find("Attribute", Name="DICOM_MANUFACTURER").getText()
            tstr="%s,%s" % (os.path.basename(ff),txtHardware)
            f.write(tstr+"\n")
            print tstr
