close all;
clear all;


fidx='/home/ar/data.CAMELYON16_Full_for_Start/Train_Tumor/idx_PINK.txt';
% % fidx='/home/ar/data.CAMELYON16_Full_for_Start/Train_Normal/idx_PINK.txt';
lstPath=importdata(fidx);

% % numPath=numel(lstPath);
numPath=5;

for ii=1:numPath
    fnTif=lstPath{ii};
    fnTifBase=fnTif(1:end-4);
    fnTifMsk=[fnTifBase,'_MskCksS256.png'];
% %     fnProb=[fnTifBase,'_MaskTiles/idx-tiles.txt-GoogleNet-Prob.csv'];
    fnProb=[fnTifBase,'_MaskTiles/idx-tiles.txt_HIST_q512_LSQ1_k200-ProbDst.csv'];
    fnTifMskVis=[fnTifBase,'_MaskVis.png'];
    %
    timgMsk=imread(fnTifMsk);
    sizMsk=size(timgMsk);
    mskVis=imresize(imread(fnTifMskVis),sizMsk);
    %
    tableProb=readtable(fnProb);
    lstIndex=sub2ind(sizMsk,tableProb.row+1, tableProb.col+1);
    mskProb=zeros(sizMsk);
    mskDist=zeros(sizMsk);
    mskProb(lstIndex)=tableProb.prob;
    mskDist(lstIndex)=tableProb.dist;
    mskProb(mskDist>0.6)=0;
    %
    [~,fname,~]=fileparts(fnTifBase);
    subplot(1,3,1), imshow(mskProb>0.95,[]), title('Prob-Map');
    subplot(1,3,2), imshow(mskDist,[]), title('Prob-Dist');
    subplot(1,3,3), imshow(mskVis), title(['Vis-Map', fname]);
    drawnow;
    fprintf('%d/%d\n',ii,numPath);
end
