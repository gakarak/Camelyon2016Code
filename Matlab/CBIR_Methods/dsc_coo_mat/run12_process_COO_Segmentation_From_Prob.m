close all;
clear all;


fidx='/home/ar/data.CAMELYON16_Full_for_Start/Train_Tumor/idx_PINK.txt';
lstPath=importdata(fidx);

numPath=numel(lstPath);

for ii=1:numPath
    fnTif=lstPath{ii};
    fnTifBase=fnTif(1:end-4);
    fnTifMsk=[fnTifBase,'_MskCksS256.png'];
% %     fnProb=[fnTifBase,'_MaskTiles/idx-tiles.txt-GoogleNet-Prob.csv'];
% %     fnProb=[fnTifBase,'_MaskTiles/idx-tiles.txt_HIST_q512_LSQ1_k20-ProbDst.csv'];
    fnProb=[fnTifBase,'_MaskTiles/idx-tiles.txt_COO_p2q(16)[1,3,5]_LSQ1_k20-ProbDst.csv'];
    fnTifMskVis=[fnTifBase,'_MaskVis.png'];
    %
    timgMsk=imread(fnTifMsk);
    sizMsk=size(timgMsk);
    mskVis=imresize(imread(fnTifMskVis),sizMsk);
    %
    tableProb=readtable(fnProb);
    lstIndex=sub2ind(sizMsk,tableProb.row+1, tableProb.col+1);
    mskProb=zeros(sizMsk);
    mskProb(lstIndex)=tableProb.prob;
    mskDst=zeros(sizMsk);
    mskDst(lstIndex)=tableProb.dist;
    mskProb(mskDst>0.5)=0;
    %
    subplot(1,3,1), imshow(mskProb,[]), title('Prob-Map');
    subplot(1,3,2), imshow(mskDst,[]), title('Dist-Map');
    subplot(1,3,3), imshow(mskVis), title('Vis-Map');
    drawnow;
    fprintf('%d/%d\n',ii,numPath);
end
