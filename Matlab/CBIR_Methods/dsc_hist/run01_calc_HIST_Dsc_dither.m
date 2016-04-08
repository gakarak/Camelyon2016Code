close all;
clear all;

fidx='/home/ar/data.CAMELYON16_Full_for_Start/CAMELYON16_Dataset_Generated/dataset-12k-kovalev-2classes/idx.txt';
wdirQ='..';
wdirOut=fileparts(fidx);
tdata=readtable(fidx);

lstId=tdata.id;
lstPath=tdata.path;
numImg=numel(lstId);
% % numImg=10;

% % lstNumQ=[8,16,32,64,128,256,512];
lstNumQ=[1024];
numNumQ=numel(lstNumQ);

for qq=1:numNumQ
    tnumQ=lstNumQ(qq);
    fQMap=sprintf('%s/cmap_pink_q%d.csv', wdirQ, tnumQ);
    qMap=csvread(fQMap);
    disp(fQMap);
    arrDsc=zeros(numImg,tnumQ);
    parfor ii=1:numImg
        timg=imread(lstPath{ii});
% %         timgQ=rgb2ind(timg, qMap, 'nodither');
        timgQ=rgb2ind(timg, qMap, 'dither');
        tdsc=histc(timgQ(:), 1:tnumQ);
        arrDsc(ii,:)=tdsc/sum(tdsc(:));
    end
% %     foutDsc=sprintf('%s/dsc_hist_q%d.csv', wdirOut, tnumQ);
    foutDsc=sprintf('%s/dsc_hist_q%dd.csv', wdirOut, tnumQ);
    csvwrite(foutDsc, arrDsc);
end
