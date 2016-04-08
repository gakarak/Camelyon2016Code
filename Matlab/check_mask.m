close all;
clear all;

% % fnMskAuto='/home/ar/data/Camelyon16_Challenge/data/Tumor_001.tif-L8.png-segm.png';
% % fnMskEval='/home/ar/data/Camelyon16_Challenge/data/Tumor_001_EvaluationMask.png';

% % fnMskAuto='/home/ar/data/Camelyon16_Challenge/data/Tumor_031.tif-L8.png-segm.png';
% % fnMskEval='/home/ar/data/Camelyon16_Challenge/data/Tumor_031_EvaluationMask.png';

fnMskAuto='/home/ar/data/Camelyon16_Challenge/data/Tumor_001.tif-L8.png-segm.png';
fnMskEval='/home/ar/data/Camelyon16_Challenge/data/Tumor_001_EvaluationMask.png';
fnImg='/home/ar/data/Camelyon16_Challenge/data/Tumor_001.tif-L8.png';

img=imread(fnImg);
imgg=rgb2gray(img);
mskAuto=(imread(fnMskAuto)<1);
mskEval=imread(fnMskEval)>0;

mskAuto=(imgg<180);
mskEval=imresize(mskEval, size(mskAuto));

figure,
subplot(1,4,1), imshow(img), title('Image')
subplot(1,4,2), imshow(mskAuto), title('Auto')
subplot(1,4,3), imshow(mskEval), title('Eval')
subplot(1,4,4), imshowpair(mskAuto, mskEval), title('Auto & Eval')


