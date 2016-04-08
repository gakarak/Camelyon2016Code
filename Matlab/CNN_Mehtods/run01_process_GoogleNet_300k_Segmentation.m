close all;
clear all;


% % fidx='/home/ar/data.CAMELYON16_Full_for_Start/Train_Tumor/idx_PINK.txt';
fidx='/home/ar/data.CAMELYON16_Full_for_Start/Train_Tumor/idx_BLUE.txt';
lstPath=importdata(fidx);

numPath=numel(lstPath);

for ii=1:numPath
    fnTif=lstPath{ii};
    fnTifBase=fnTif(1:end-4);
    fnTifMsk=[fnTifBase,'_MskCksS256.png'];
    fnProb=[fnTifBase,'_MaskTiles/idx-tiles.txt-GoogleNet-Prob.csv'];
    fnTifMskVis=[fnTifBase,'_MaskVis.png'];
    fnImageProb=[fnTifBase,'_GoogleNet-Prob.png'];
    fnTifL8=[fnTif,'-L8.png'];
    %
    timgMsk=imread(fnTifMsk);
    sizMsk=size(timgMsk);
    mskVis=imresize(imread(fnTifMskVis),sizMsk);
% %     mskVis2=imresize(imread(fnTifL8),sizMsk);
    mskVis2=imresize(imread(fnTifMskVis),sizMsk);
    %
    tableProb=readtable(fnProb);
    lstIndex=sub2ind(sizMsk,tableProb.row+1, tableProb.col+1);
    mskProb=zeros(sizMsk);
    mskProb(lstIndex)=tableProb.prob;
    mskVis2R=mskVis2(:,:,1);
    mskVis2R(mskProb>0.99)=255;
    mskVis2(:,:,1)=mskVis2R;
    %
    mskVisGT=imresize(imread(fnTifL8),sizMsk);
    mskVisGTR = mskVisGT(:,:,1);
    mskVisGTR(timgMsk>0)=255;
    mskVisGT(:,:,1)=mskVisGTR;
    %
% %     imwrite(uint8(255.*mskProb), fnImageProb);
    %
    [~,fname,~]=fileparts(fnTifBase);
% %     subplot(1,2,1), imshow(mskProb>0.95,[]), title('Prob-Map');
    subplot(1,2,1), imshow(mskVis2), title(['Detected Mask: ', fname], 'Interpreter', 'None');
    subplot(1,2,2), imshow(mskVis), title('Ground Truth');
    drawnow;
    fprintf('%d/%d\n',ii,numPath);
end