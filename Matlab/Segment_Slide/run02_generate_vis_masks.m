close all;
clear all;

% % fidx='/home/ar/data/Camelyon16_Challenge/Train_Data_for_1stage_segmentation/idx_BLUE_L8.txt';
% % fidx='/home/ar/data/Camelyon16_Challenge/Train_Data_for_1stage_segmentation/idx_PINK_L8.txt';

fidx='/home/ar/data.CAMELYON16_Full_for_Start/Train_Tumor/idx_PINK_L8.txt';
% % fidx='/home/ar/data.CAMELYON16_Full_for_Start/Train_Tumor/idx_BLUE_L8.txt';

fidxData=importdata(fidx);
numImg=numel(fidxData);


for ii=1:numImg
    tfn=fidxData{ii};
    tfnBase=tfn(1:end-11);
    tfnEvalInp=[tfnBase,'_EvaluationMask.png'];
    tfnMskVisOut=[tfnBase,'_MaskVis.png'];
    %
    timg=imread(tfn);
    timgEval=imread(tfnEvalInp);
    timgEval=imresize(timgEval,[size(timg,1),size(timg,2)]);
    timgEval2=255*uint8(timgEval>0);
    timgMskVis=timg;
    timgMskVis(:,:,1)=timgEval2;
    imwrite(timgMskVis, tfnMskVisOut);
    fprintf('(%d/%d) --> %s\n', ii,numImg, tfnMskVisOut);
end

