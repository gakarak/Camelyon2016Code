close all;
clear all;

fidx='/home/ar/data.CAMELYON16_Full_for_Start/CAMELYON16_Dataset_Genered/dataset-12k-kovalev-2classes/idx.txt';
wdirColorMap='../';

tdata=readtable(fidx);
lstId=tdata.id;
lstPath=tdata.path;
numImg=numel(lstPath);

numQ=8;
fnQMap=sprintf('%s/cmap_pink_q%d.csv', wdirColorMap, numQ);

qMap=csvread(fnQMap);

timg=imread(lstPath{1});
timgQ=rgb2ind(timg,qMap,'nodither');
timgQd=rgb2ind(timg,qMap,'dither');

tdscParam=getParamsCOO_V2( sprintf('p3q(%d)[3]',numQ));
tdsc =calc_COO_PNIGAd_V2(timgQ,  tdscParam);
tdscd=calc_COO_PNIGAd_V2(timgQd, tdscParam);

tdsc =tdsc /sum(tdsc (:));
tdscd=tdscd/sum(tdscd(:));

figure,
subplot(2,2,1), imshow(timgQd, qMap), title('dither');
subplot(2,2,2), imshow(timgQ,  qMap), title('nodither');
subplot(2,2,3), plot(tdscd), title('DSC-dither');
subplot(2,2,4), plot(tdsc),  title('DSC-dither');

disp(pdist2(tdsc', tdscd', 'cityblock'))
