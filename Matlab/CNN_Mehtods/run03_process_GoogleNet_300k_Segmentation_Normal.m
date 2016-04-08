close all;
clear all;


% % fidx='/home/ar/data.CAMELYON16_Full_for_Start/Train_Tumor/idx_PINK.txt';
% % fidx='/home/ar/data.CAMELYON16_Full_for_Start/Train_Tumor/idx_BLUE.txt';
fidx='/home/ar/data.CAMELYON16_Full_for_Start/Train_Normal/idx_PINK.txt';
lstPath=importdata(fidx);

numPath=numel(lstPath);

totErrorSum=0;
for ii=1:numPath
    fnTif=lstPath{ii};
    fnTifBase=fnTif(1:end-4);
    fnTifMsk=[fnTifBase,'_MskCksS256.png'];
    fnProb=[fnTifBase,'_MaskTiles/idx-tiles.txt-GoogleNet-Prob.csv'];
    fnTifMskVis=[fnTif,'-L8.png'];
    fnImageProb=[fnTifBase,'_GoogleNet-Prob.png'];
    %
    timgMsk=imread(fnTifMsk);
    sizMsk=size(timgMsk);
% %     mskVis=imresize(imread(fnTifMskVis),sizMsk);
    mskVis2=imresize(imread(fnTifMskVis),sizMsk);
% %     mskVis2=imresize(fnTif,sizMsk);
    %
    tableProb=readtable(fnProb);
    lstIndex=sub2ind(sizMsk,tableProb.row+1, tableProb.col+1);
    mskProb=zeros(sizMsk);
    mskProb(lstIndex)=tableProb.prob;
    mskVis=mskProb>0.95;
    mskVis2(mskVis)=0;
    %
% %     imwrite(uint8(255.*mskProb), fnImageProb);
    %
% %     imwrite(uint8(255.*mskProb), fnImageProb);
    %
    [~,fname,~]=fileparts(fnTifBase);
% %     subplot(1,2,1), imshow(mskProb>0.95,[]), title('Prob-Map');
    subplot(1,2,1), imshow(mskVis2), title(['Prob-Map: ', fname], 'Interpreter', 'None');
    subplot(1,2,2), imshow(mskVis), title('Vis-Map');
    drawnow;
    tmpError=sum(mskVis(:));
    totErrorSum=totErrorSum+tmpError;
    fprintf('%d/%d, #Error: %d\n',ii,numPath, totErrorSum);
end

fprintf('Total Error: %d\n', totErrorSum);
