#!/usr/bin/python

import os
import sys
import numpy as np
import bs4
from bs4 import BeautifulSoup as bsoup
from bs4 import BeautifulStoneSoup, BeautifulSoup
from lxml import etree
import lxml

def_tag0='tag0'
def_tag0_color='#ff0000'
def_tag1='tag1'
def_tag1_color='#c0ffc0'

if __name__=='__main__':
    fn='/home/ar/data/Camelyon16_Challenge/data/Tumor_001-test-mod.xml'
    with open(fn,'r') as f:
        dataXML=etree.parse(fn)
        tmp1=dataXML.findall('.//Group')
        for ii in tmp1:
            print ii.get('Name')
            # ii.append(etree.XML('<tag1 attr="123">Value</tag1>'))
            # print etree.tostring(ii)
        print '----'
        tmp2=dataXML.findall('.//Annotation')
        for ii in tmp2:
            elemCoords=ii.findall('.//Coordinate')
            print 'Name=', ii.get('Name'), ', PartOfGroup=', ii.get('PartOfGroup'), ', len=', len(elemCoords)
        #
        # dataXML=BeautifulSoup(f.read(),'xml')
        # tagGroups=dataXML.find('AnnotationGroups')
        # tagGroups.parent().append(etree.XML('<mytag param="123">Fuck</mytag>'))
        # tagGroups.append(dataXML.new_tag('<Group Name="%s" PartOfGroup="None" Color="%s"><Attributes /></Group>' % (def_tag0,def_tag0_color)))
        # tagGroups.append(BeautifulSoup('<Group Name="%s" PartOfGroup="None" Color="%s"><Attributes /></Group>' % (def_tag1,def_tag1_color), features='lxml-xml'))
        # print dataXML.prettify()

    print '---'