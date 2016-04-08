close all;
clear all;

% % fidx='/home/ar/data/Camelyon16_Challenge/dataset-500-shuf-2classes2/idx.txt';
% % fidx='/home/ar/data.CAMELYON16_Full_for_Start/CAMELYON16_Dataset_Genered/dataset-500-shuf-2classes2/idx.txt';
fidx='/home/ar/data.CAMELYON16_Full_for_Start/CAMELYON16_Dataset_Generated/dataset-12k-kovalev-2classes/idx.txt';

tdata=readtable(fidx);
lstId=tdata.id;
lstPath=tdata.path;
numImg=numel(lstPath);

numImgWork=1200;

rndIdx=randperm(numImg);



lstImg={};
for ii=1:numImgWork
    lstImg{ii}=imread(lstPath{rndIdx(ii)});
    if mod(ii,20)==0
        fprintf('.. loading images .. [%d/%d]\n', ii,numImgWork);
    end
end


% % % % % % % % % % % % % % % % % % % 
numSamplPerImage=20;
lstSizes={21,21,21,21,21,21};
lstSigm={1,3,5,7,9,11};
% % lstSizes={21,21,21};
% % lstSigm={1,3,5};
numPCA=32;

% % ret=calc_FPCA_filter_color(lstPath,10,19,7,32);
lstRet=build_FPCA_filter_list(lstImg,numSamplPerImage, lstSizes, lstSigm, numPCA);

for ii=1:numel(lstRet)
    plot_fpca_filters_color(lstRet{ii});
    drawnow;
end

%%
fun_write_fpca_filterbank('fltbank-camelion2016-rgb.dat', lstRet, lstSigm);
