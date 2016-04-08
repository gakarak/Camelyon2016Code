close all;
clear all;

% % fidx='/home/ar/data/Camelyon16_Challenge/dataset-500-shuf-2classes2/idx.txt';
% % fidx='/home/ar/data.CAMELYON16_Full_for_Start/CAMELYON16_Dataset_Genered/dataset-500-shuf-2classes2/idx.txt';
fidx='/home/ar/data.CAMELYON16_Full_for_Start/CAMELYON16_Dataset_Generated/dataset-12k-kovalev-2classes/idx.txt';
fltBank='fltbank-camelion2016-rgb.dat';

tdata=readtable(fidx);
lstId=tdata.id;
lstPath=tdata.path;
% % numImg=numel(lstPath);
numImg=10;

% % % % % % % % % % % % % % % % % % %
lstImg={};
for ii=1:numImg
    lstImg{ii}=imread(lstPath{ii});
    if mod(ii,100)==0
        fprintf('.. loading images .. [%d/%d]\n', ii,numImg);
    end
end

% % % % % % % % % % % % % % % % % % % 
lstFltBank=fun_read_fpca_filterbank(fltBank);
sizeBank=numel(lstFltBank);

% % % % % % % % % % % % % % % % % % % 
idxFlt=2;
% % for ii=1:sizeBank
for ii=idxFlt:idxFlt
    plot_fpca_filters_color(lstFltBank{ii});
    drawnow;
end
drawnow;

% % % % % % % % % % % % % % % % % % % 
imgIdx=1;
numx=5;
numy=5;
numFlt=numx*numy;
cnt=1;
figure,
drawnow;
for xx=1:numx
    for yy=1:numy
        timgFlt=sum(imfilter(lstImg{imgIdx},lstFltBank{idxFlt}{cnt}),3);
        subplot(numy,numx,cnt), imshow(timgFlt>0,[]), title(sprintf('#%d', cnt));
        cnt=cnt+1;
        drawnow;
    end
end


