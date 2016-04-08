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
% % % % % % % % % % % % % % % % % % % 
lstIdxFltSigm={2,3,4};


arrDsc=[];
numDscTypes=numel(lstIdxFltSigm);

for tt=1:numDscTypes
    tidxFltSigm=lstIdxFltSigm{tt};
    foutDscCSV=sprintf('%s/dsc_bfpca_s%d.csv',fileparts(fidx), tidxFltSigm);
    tarrDsc=csvread(foutDscCSV);
	%
    if isempty(arrDsc)
        arrDsc=tarrDsc;
    else
        arrDsc=[arrDsc, tarrDsc];
    end
end

% % % % % % % % % % 
numK=20;
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
