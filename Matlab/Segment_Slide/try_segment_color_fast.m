close all;
clear all;

close all;
clear all;


fidx1='/home/ar/data.CAMELYON16_Full_for_Start/Testset/idx_PINK_L8.txt';
fidx2='/home/ar/data.CAMELYON16_Full_for_Start/Testset/idx_BLUE_L8.txt';

% % fidx3='/home/ar/data.CAMELYON16_Full_for_Start/Train_Normal/idx_PINK_L8.txt';
% % fidx4='/home/ar/data.CAMELYON16_Full_for_Start/Train_Tumor/idx_BLUE_L8.txt';
% % fidx5='/home/ar/data.CAMELYON16_Full_for_Start/Train_Tumor/idx_PINK_L8.txt';
% % lst_fidx={fidx1, fidx2, fidx3, fidx4, fidx5};

lst_fidx={fidx1, fidx2};

for kk=1:numel(lst_fidx)
    fidx=lst_fidx{kk};
    
    fidxData=importdata(fidx);
    numImg=numel(fidxData);

    se = strel('disk',3);
    timgf=fspecial('gaussian',[11,11],3);

    for ii=1:numImg
        tfn=fidxData{ii};
        tfnBase=tfn(1:end-11);
        tfnEvalInp=[tfnBase,'_EvaluationMask.png'];
        tfnEvalOut=[tfnBase,'_EvaluationMask2.png'];
        %
        timg=imread(tfn);
        timg=imfilter(timg, timgf);
        timgg=rgb2gray(timg);
        timgM=imfilter(timgg, timgf);
        tmsk=timgM<190;
        timgM(tmsk>0)=255;
        %
        tfnMskVisOut=[tfnBase,'_MaskVisNew1.png'];
    % %     timgEval2=255*uint8(timgEval>0);
        imwrite(uint8(255*(tmsk>0)), tfnMskVisOut);
        subplot(1,2,1), imshow(timg);
        subplot(1,2,2), imshow(timgM);
        drawnow;
        fprintf('(%d/%d) --> %s\n', ii,numImg, tfnEvalOut);
    end
end
