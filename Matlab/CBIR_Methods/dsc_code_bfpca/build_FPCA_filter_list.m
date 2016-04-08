function [ ret ] = build_FPCA_filter_list( lst_img, nsamplesPerImage, lst_siz, lst_sigm, npca )
%BUILD_FPCA_FILTER_LIST Summary of this function goes here
%   Detailed explanation goes here
    num_siz=length(lst_siz);
    assert(num_siz>0);
    ret={};
    for ii=1:num_siz
        fprintf('%d/%d\n',ii,num_siz);
        ret{ii}=calc_FPCA_filter_color(lst_img, nsamplesPerImage, lst_siz{ii}, lst_sigm{ii}, npca);
    end
end
