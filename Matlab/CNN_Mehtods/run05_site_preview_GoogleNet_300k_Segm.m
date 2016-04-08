close all;
clear all;


% % fidx='/home/ar/data.CAMELYON16_Full_for_Start/Train_Tumor/idx_PINK.txt';
% % prefType='3D Histech';
fidx='/home/ar/data.CAMELYON16_Full_for_Start/Train_Tumor/idx_BLUE.txt';
prefType='Hamamatsu';

lstPath=importdata(fidx);

numPath=numel(lstPath);

se=strel('disk',2);

for ii=1:numPath
    fnTif=lstPath{ii};
    fnTifBase=fnTif(1:end-4);
    fnTifMsk=[fnTifBase,'_MskCksS256.png'];
    fnProb=[fnTifBase,'_MaskTiles/idx-tiles.txt-GoogleNet-Prob.csv'];
    fnTifMskEval=[fnTifBase,'_EvaluationMask.png'];
    fnImageProb=[fnTifBase,'_GoogleNet-Prob.png'];
    fnTifL8=[fnTif,'-L8.png'];
    fnPreviewOutput=[fnTifBase,'-preview.png'];
    [~,fname,~]=fileparts(fnTifBase);
    % (1) Preproc-msk:
    tifMsk=imread(fnTifMsk);
    sizMsk=size(tifMsk);
    % (2) Evaluation msk:
    mskEval=uint8(255*imresize(imread(fnTifMskEval)>0,sizMsk));
    % (3) CNN-Prob-Map:
    tableProb=readtable(fnProb);
    lstIndex=sub2ind(sizMsk,tableProb.row+1, tableProb.col+1);
    mskProb=zeros(sizMsk);
    mskProb(lstIndex)=tableProb.prob;
    % (4)
    tifL8Resiz=imresize(imread(fnTifL8),sizMsk);
    tifL8ResizTxt=insertText(tifL8Resiz, [10,10], prefType);
    mskGT=tifL8Resiz;
    mskGT_R=mskGT(:,:,2);
    mskGT_R(mskEval>0)=255;
    mskGT(:,:,2)=mskGT_R;
    mskGT_Txt=insertText(mskGT, [10,10], [prefType, ', GT']);
    mskGT_Txt=insertText(mskGT_Txt, [10,sizMsk(1)-30], fname, 'BoxColor','red');
    mskCLS=tifL8Resiz;
    mskCLS(:,:,1)=uint8(255*imclose(mskProb>0.99,se));
    mskCLS_Txt=insertText(mskCLS, [10,10], 'NN-Cls-S1');
    if sizMsk(1)>sizMsk(2)
        retImg=[mskGT_Txt, mskCLS_Txt];
    else
        retImg=[mskGT_Txt; mskCLS_Txt];
    end
    imwrite(retImg, fnPreviewOutput);
    imshow(retImg),  title(['Detected Mask: ', fname], 'Interpreter', 'None');
    drawnow;
    fprintf('%d/%d\n',ii,numPath);
end