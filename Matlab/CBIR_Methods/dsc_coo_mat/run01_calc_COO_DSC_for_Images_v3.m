close all;
clear all;

% % fidx='/home/ar/data.CAMELYON16_Full_for_Start/CAMELYON16_Dataset_Genered/dataset-12k-kovalev-2classes/idx.txt';
fidx='/home/ar/data.CAMELYON16_Full_for_Start/CAMELYON16_Dataset_Generated/dataset-12k-kovalev-2classes/idx.txt';
wdirColorMap='../';
wdirOut=fileparts(fidx);

tdata=readtable(fidx);
lstId=tdata.id;
lstPath=tdata.path;
numImg=numel(lstPath);
% % numImg=10;


lstNumQ=[8,16];
numNumQ=numel(lstNumQ);
lstNumD=[1,3,5];
numNumD=numel(lstNumD);
lstIsDither=[true,false];



for isDither=lstIsDither
    for dd=1:numNumD
        tnumD=lstNumD(dd);
        for qq=1:numNumQ
            tnumQ=lstNumQ(qq);
            fQMap=sprintf('%s/cmap_pink_q%d.csv', wdirColorMap, tnumQ);
            qMap=csvread(fQMap);
            strParamCOO=sprintf('p2q(%d)[%d]',tnumQ,tnumD);
            tdscParam=getParamsCOO_V2( strParamCOO );
            disp(fQMap);
            %
            tmpDsc=calc_COO_PNIGAd_V2(rgb2ind(imread(lstPath{1}), qMap, 'nodither'),  tdscParam);
            arrDsc=zeros(numImg,numel(tmpDsc));
            %
            parfor ii=1:numImg
                timg=imread(lstPath{ii});
                if isDither
                    timgQ=rgb2ind(timg, qMap, 'dither');
                else
                    timgQ=rgb2ind(timg, qMap, 'nodither');
                end
                tdsc=calc_COO_PNIGAd_V2(timgQ,  tdscParam);
                arrDsc(ii,:)=tdsc/sum(tdsc(:));
                if mod(ii,500)==0
                    fprintf('#Q=%d, #D=%d, isDither=%d, %d/%d\n', tnumQ, tnumD, isDither, ii, numImg);
                end
            end
            if isDither
                foutDsc=sprintf('%s/dsc_COO_%sd.csv', wdirOut, strParamCOO);
            else
                foutDsc=sprintf('%s/dsc_COO_%s.csv', wdirOut, strParamCOO);
            end
            csvwrite(foutDsc, arrDsc);
        end
    end
end

