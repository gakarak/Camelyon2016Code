close all;
clear all;


% % fidx='/home/ar/data.CAMELYON16_Full_for_Start/Train_Tumor/idx_BLUE.txt';
fidx='/home/ar/data.CAMELYON16_Full_for_Start/Train_Normal/idx_PINK.txt';
lstPath=importdata(fidx);
wdir=fileparts(fidx);

numPath=numel(lstPath);

probThreshold=0.85;
foutCSV_ErrorNormal=sprintf('%s-ErrorNormal_p%0.2f.txt', fidx, probThreshold);

fout=fopen(foutCSV_ErrorNormal,'w');
totErrorSum=0;
for ii=1:numPath
    fnTif=lstPath{ii};
    fnTifBase=fnTif(1:end-4);
    fnTifMsk=[fnTifBase,'_MskCksS256.png'];
    fnProb=[fnTifBase,'_MaskTiles/idx-tiles.txt-GoogleNet-Prob.csv'];
    fnTifMskVis=[fnTif,'-L8.png'];
    %
    timgMsk=imread(fnTifMsk);
    sizMsk=size(timgMsk);
    imgWithProbMsk=imresize(imread(fnTifMskVis),sizMsk);
    %
    tableProb=readtable(fnProb);
    lstIndex=sub2ind(sizMsk,tableProb.row+1, tableProb.col+1);
    mskProb=zeros(sizMsk);
    mskProb(lstIndex)=tableProb.prob;
    mskVis=mskProb>probThreshold;
    imgWithProbMsk(mskVis)=0;
    %
    [~,fname,~]=fileparts(fnTifBase);
    subplot(1,2,1), imshow(imgWithProbMsk), title(['Prob-Map: ', fname], 'Interpreter', 'None');
    subplot(1,2,2), imshow(mskVis), title(sprintf('Prob-Map, T=%0.3f', probThreshold));
    drawnow;
    tmpError=sum(mskVis(:));
    totErrorSum=totErrorSum+tmpError;
    lstErrorTiles=tableProb(tableProb.prob>probThreshold,:).filename;
    for kk=1:numel(lstErrorTiles)
        fprintf(fout, '%s/%s\n', fileparts(fnProb), lstErrorTiles{kk});
    end
    fprintf('%d/%d, #Error: %d\n',ii,numPath, totErrorSum);
end

fprintf('Total Error: %d\n', totErrorSum);
