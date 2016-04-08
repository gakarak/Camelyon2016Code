close all;
clear all;

% % fidx='/home/ar/data.CAMELYON16_Full_for_Start/CAMELYON16_Dataset_Genered/dataset-12k-kovalev-2classes/idx.txt';
fidx='/home/ar/data.CAMELYON16_Full_for_Start/CAMELYON16_Dataset_Generated/dataset-12k-kovalev-2classes/idx.txt';
wdirColorMap='../';
wdirOut=fileparts(fidx);

tdata=readtable(fidx);
lstId=tdata.id;
lstPath=tdata.path;
numImg=numel(lstPath);
% % numImg=10;


% % lstTypesDsc={'p2q(8)[1,3,5]d', 'p2q(16)[1,3,5]d'};
lstTypesDsc={'p2q(8)[1,3,5]', 'p2q(16)[1,3,5]'};
numTypes=numel(lstTypesDsc);

numK=10;
for tt=1:numTypes
    strParamCOO=lstTypesDsc{tt};
    foutDsc=sprintf('%s/dsc_COO_%s.csv', wdirOut, strParamCOO);
% %     arrDsc= csvread(foutDsc);
    arrDsc= sqrt(csvread(foutDsc));
    %
    lstIdK=repmat(lstId,1,numK);
% %     dst=pdist2(arrDsc,arrDsc,'cityblock');
    dst=pdist2(arrDsc,arrDsc,'euclidean');
    
    [BB,II] = sort(dst,2);
    gidx=II(:,2:numK+1);
    retCls=lstIdK(gidx);
    retACC0=sum((retCls==lstIdK),2);
    retACC=(retACC0>=(numK/2));
    retACC=100*sum(retACC)/numImg;
    %
    fprintf('Acc-Dither (%s): %0.2f %%\n', strParamCOO, retACC);
end

