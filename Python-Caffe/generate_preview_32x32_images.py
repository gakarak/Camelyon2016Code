import os
import sys
import numpy as np
# from bs4 import BeautifulSoup as bsoup
import openslide as ops
import matplotlib.pyplot as plt
import matplotlib.path as mplPath
import skimage.io as io

###################################
def usage(argv):
    print('Usage: %s {/path/to/BigTiff-Image-With-XML-Metainfo} [sizeTile]' % os.path.basename(argv[0]))

###################################
defStep=32

###################################
if __name__=='__main__':
    if len(sys.argv)<2:
        usage(sys.argv)
        sys.exit(1)
    fnPath=sys.argv[1]
    if not os.path.isfile(fnPath):
        print '[ERROR] cant find file []' % fnPath
        sys.exit(1)
    if len(sys.argv)>2:
        defStep=int(sys.argv[2])
    #
    fout='%s-s%d.png' % (os.path.splitext(fnPath)[0], defStep)
    if os.path.isfile(fout):
        print '[WARNING] file [%s] exist, skip...' % fout
        sys.exit(0)
    #
    dataIMG=ops.OpenSlide(fnPath)
    siz0=np.array(dataIMG.level_dimensions[0])
    siz1=siz0/defStep
    x_range=range(0,siz0[0],defStep)
    y_range=range(0,siz0[1],defStep)
    retShape=(len(y_range), len(x_range))
    retImg=np.zeros((retShape[0], retShape[1], 3), dtype=np.uint8)
    errCnt=0
    for ixx,xx in enumerate(x_range):
        for iyy,yy in enumerate(y_range):
            try:
                tmp=np.array(dataIMG.read_region((xx,yy),0,(defStep,defStep)))
                retImg[iyy,ixx,0]=tmp[:,:,0].mean()
                retImg[iyy,ixx,1]=tmp[:,:,1].mean()
                retImg[iyy,ixx,2]=tmp[:,:,2].mean()
            except:
                errCnt+=1
                retImg[iyy,ixx,0]=255
                retImg[iyy,ixx,1]=0
                retImg[iyy,ixx,2]=0
        print '[%s] %d/%d' % (os.path.basename(fnPath), xx,x_range[-1])
    print '* generate image [%s]' % fout
    if errCnt>0:
        foutErr='%s-err.txt' % fout[:-4]
        with open(foutErr,'w') as f:
            f.write('%d|%d\n' % (errCnt, np.prod(retShape)) )
    io.imsave(fout, retImg)
