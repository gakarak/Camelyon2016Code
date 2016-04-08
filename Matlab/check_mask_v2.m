close all;
clear all;

% % fnMskAuto='/home/ar/data/Camelyon16_Challenge/data/Tumor_001.tif-L8.png-segm.png';
% % fnMskEval='/home/ar/data/Camelyon16_Challenge/data/Tumor_001_EvaluationMask.png';

% % fnMskAuto='/home/ar/data/Camelyon16_Challenge/data/Tumor_031.tif-L8.png-segm.png';
% % fnMskEval='/home/ar/data/Camelyon16_Challenge/data/Tumor_031_EvaluationMask.png';

dirEval='/media/ar/data6T/data/CAMELYON16_Full_for_Start/Evaluation/EvaluationMasks';
fidx='/media/ar/data6T/data/CAMELYON16_Full_for_Start/Train_Tumor_L8/idx.txt';

lstfn=importdata(fidx);
numfn=numel(lstfn);


lstError=zeros(numfn,1);
figure,
for ii=1:numfn
    tfn=lstfn{ii};
    tfnCut=tfn(1:end-7);
    fnMskAuto=[tfn,'-segm.png'];
    [~,tbn,~]=fileparts(tfnCut);
    fnMskEval=[dirEval,'/',tbn,'_EvaluationMask.png'];
	%
    img=imread(tfn);
    mskAuto=(imread(fnMskAuto)<1);
    mskEval=imread(fnMskEval)>0;
    mskEval=imresize(mskEval, size(mskAuto));
    %
    sumEval=sum(mskEval);
    mskError=mskEval&(mskEval&(~mskAuto));
    sumError=sum(mskError);
    perror=sumError/sumEval;
    lstError(ii)=perror;
    tstr=sprintf('Error = %0.1f%%', perror*100.);
    %
    subplot(1,4,1), imshow(img),     title('Image')
    subplot(1,4,2), imshow(mskAuto), title('Auto')
    subplot(1,4,3), imshow(mskEval), title('Eval')
    subplot(1,4,4), imshowpair(mskAuto, mskEval), title(['Auto & Eval : ', tstr]);
    drawnow;
    %
    disp([tstr, ' : ', tfn]);
end

