close all;
clear all;

% % fidx='/home/ar/data/Camelyon16_Challenge/dataset-500-shuf-2classes2/idx.txt';
% % fidx='/home/ar/data.CAMELYON16_Full_for_Start/CAMELYON16_Dataset_Genered/dataset-500-shuf-2classes2/idx.txt';
fidx='/home/ar/data.CAMELYON16_Full_for_Start/CAMELYON16_Dataset_Generated/dataset-12k-kovalev-2classes/idx.txt';
fltBank='fltbank-camelion2016-rgb.dat';

tdata=readtable(fidx);
lstId=tdata.id;
lstPath=tdata.path;
numImg=numel(lstPath);
% % numImg=10;

% % % % % % % % % % % % % % % % % % %
% % lstImg={};
% % for ii=1:numImg
% %     lstImg{ii}=imread(lstPath{ii});
% %     if mod(ii,100)==0
% %         fprintf('.. loading images .. [%d/%d]\n', ii,numImg);
% %     end
% % end

% % % % % % % % % % % % % % % % % % % 
lstFltBank=fun_read_fpca_filterbank(fltBank);
sizeBank=numel(lstFltBank);

% % % % % % % % % % % % % % % % % % % 
lstIdxFltSigm={2,3,4};

numDscTypes=numel(lstIdxFltSigm);
numK=20;
for tt=1:numDscTypes
    tidxFltSigm=lstIdxFltSigm{tt};
    foutDscCSV=sprintf('%s/dsc_bfpca_s%d.csv',fileparts(fidx), tidxFltSigm);
    arrDsc=csvread(foutDscCSV);
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
    fprintf('Acc: %0.2f %%\n', retACC);
end

%%
% % numK=10;
% % lstIdK=repmat(lstId,1,numK);
% % dst=pdist2(arrDsc,arrDsc,'cityblock');
% % [BB,II] = sort(dst,2);
% % gidx=II(:,2:numK+1);
% % retCls=lstIdK(gidx);
% % retACC0=sum((retCls==lstIdK),2);
% % retACC=(retACC0>(numK/2));
% % retACC=100*sum(retACC)/numImg;
% % 
% % fprintf('Acc: %0.2f %%\n', retACC)
