close all;
clear all;


% % fidx='/home/ar/data.CAMELYON16_Full_for_Start/Train_Tumor/idx_PINK.txt';
% % fidx='/home/ar/data.CAMELYON16_Full_for_Start/Testset/idx_PINK.txt';
fidx='/home/ar/data.CAMELYON16_Full_for_Start/Testset/idx_BLUE.txt';
lstPath=importdata(fidx);

numPath=numel(lstPath);

for ii=1:numPath
    fnTif=lstPath{ii};
    fnTifBase=fnTif(1:end-4);
    fnTifMsk=[fnTifBase,'_MskCksS256.png'];
    fnProb=[fnTifBase,'_MaskTiles/idx-tiles.txt-GoogleNet-Prob.csv'];
% %     fnTifMskVis=[fnTifBase,'_MaskVis.png'];
    fnTifMskVis=[fnTif,'-L8.png'];
    fnImageProb=[fnTifBase,'_GoogleNet-Prob.png'];
    %
    timgMsk=imread(fnTifMsk);
    sizMsk=size(timgMsk);
    mskVis=imresize(imread(fnTifMskVis),sizMsk);
    %
    tableProb=readtable(fnProb);
    lstIndex=sub2ind(sizMsk,tableProb.row+1, tableProb.col+1);
    mskProb=zeros(sizMsk);
    mskProb(lstIndex)=tableProb.prob;
    mskProbVis=(mskProb>0.99);
    mskVis(mskProbVis)=255;
% %     imwrite(uint8(255.*mskProb), fnImageProb);
    %
    [~,fname,~]=fileparts(fnTif);
    subplot(1,2,1), imshow(mskProbVis), title('Prob-Map');
    subplot(1,2,2), imshow(mskVis), title(fname, 'Interpreter', 'None');
    drawnow;
    fprintf('%d/%d\n',ii,numPath);
end