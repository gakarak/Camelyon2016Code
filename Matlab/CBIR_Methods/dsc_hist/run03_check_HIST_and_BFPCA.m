close all;
clear all;

fidx='/home/ar/data.CAMELYON16_Full_for_Start/CAMELYON16_Dataset_Generated/dataset-12k-kovalev-2classes/idx.txt';
wdirOut=fileparts(fidx);

tdata=readtable(fidx);
lstId=tdata.id;
lstPath=tdata.path;
numImg=numel(lstId);

fdscHist=[wdirOut,'/dsc_hist_q256.csv'];
fdscBFPCA=[wdirOut,'/dsc_bfpca_s3.csv'];

arrDscHist=csvread(fdscHist);
arrDscBFPCA=csvread(fdscBFPCA);

arrDsc=[arrDscBFPCA,arrDscHist];

numK=20;
lstIdK=repmat(lstId,1,numK);
dst=pdist2(arrDsc,arrDsc,'cityblock');
[BB,II] = sort(dst,2);
gidx=II(:,2:numK+1);
retCls=lstIdK(gidx);
retACC0=sum((retCls==lstIdK),2);
retACC=(retACC0>=(numK/2));
retACC=100*sum(retACC)/numImg;
%
fprintf('Acc: %0.2f %%\n', retACC);