function [ list_fltbank, list_sigma, list_sizes ] = fun_read_fpca_filterbank( filename )
%FUN_READ_FPCA_FILTERBANK Summary of this function goes here
%   Detailed explanation goes here
    f=fopen(filename, 'r');
    numScales=fread(f, 1, 'int32');
    numCh    =fread(f, 1, 'int32');
    list_sigma=zeros(numScales,1);
    list_sizes=zeros(numScales,1);
    list_fltbank={};
    for ii=1:numScales
        sizeFrame          = fread(f, 1, 'int32');
        scaleSigma         = fread(f, 1, 'int32');
        numFiltersPerScale = fread(f, 1, 'int32');
        %
        list_sigma(ii)     = scaleSigma;
        list_sizes(ii)     = sizeFrame;
        tmp_lst_flt={};
        for ff=1:numFiltersPerScale
            cflt=fread(f, sizeFrame*sizeFrame*numCh, '*float64');
            cflt=reshape(cflt, [sizeFrame, sizeFrame, numCh]);
            tmp_lst_flt{ff}=cflt;
        end
        list_fltbank{ii}=tmp_lst_flt;
    end
    fclose(f);
end
