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

lstNumQ=[8,16,32,64,128,256,512,1024];
numNumQ=numel(lstNumQ);

numK=20;
for qq=1:numNumQ
    tnumQ=lstNumQ(qq);
    fQMap=sprintf('%s/cmap_pink_q%d.csv', wdirQ, tnumQ);
    qMap=csvread(fQMap);
    foutDsc=sprintf('%s/dsc_hist_q%dd.csv', wdirOut, tnumQ);
    arrDsc=csvread(foutDsc);
    %
    lstIdK=repmat(lstId,1,numK);
    dst=pdist2(arrDsc,arrDsc,'cityblock');
    [BB,II] = sort(dst,2);
    gidx=II(:,2:numK+1);
    retCls=lstIdK(gidx);
    retACC0=sum((retCls==lstIdK),2);
    retACC=(retACC0>(numK/2));
    retACC=100*sum(retACC)/numImg;
    %
    fprintf('Acc-Dither(#Q=%d): %0.2f %%\n', tnumQ, retACC);
end
