function [ ret ] = fun_write_fpca_filterbank( filename, lst_lst_fpca, lst_scales )
%FUN_READ_FPCA_FILTERBANK Summary of this function goes here
%   Detailed explanation goes here
%
% Format binary-data:
% ---------------------------
% num_scales(sigma)     = Ns   /int32
% numCh /int32
% size_frame_0                 /in32
% sigm_0                       /int32
% num_filters_per_scale = Nf0  /int32
% data_0_flt_0                 /float64
% data_0_flt_1
% ...
% data_0_flt_Nf0
% ...
% ...
% size_frame_Ns
% sigm_Ns
% num_filters_per_scale = Nfs
% data_Ns_flt_0
% data_Ns_flt_1
% ...
% data_Ns_flt_Nfs
% ---------------------------
%
    f=fopen(filename, 'w');
    ret=f;
    numScales=numel(lst_lst_fpca);
    numCh=size(lst_lst_fpca{1}{1},3);
    siz=size(lst_lst_fpca{1}{1});
    sizeFrame=siz(1);
    fwrite(f, numScales,    'int32');
    fwrite(f, numCh,        'int32');
    for ii=1:numScales
        fwrite(f, sizeFrame,    'int32');
        scaleSigma=lst_scales{ii};
        numFiltersPerScale=numel(lst_lst_fpca{ii});
        fprintf('scaleSigma(%d)/%d: #filers=%d\n', scaleSigma, sizeFrame, numFiltersPerScale);
        fwrite(f, scaleSigma,           'int32');
        fwrite(f, numFiltersPerScale,   'int32');
        for ff=1:numFiltersPerScale
            fwrite(f, lst_lst_fpca{ii}{ff},     'float64');
        end
    end
    fclose(f);
end
