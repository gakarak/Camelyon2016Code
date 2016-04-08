close all;
clear all;

% % fimg='/media/ar/data6T/data/CAMELYON16_Full_for_Start/Train_Normal/Normal_001.tif-L9.png';
% % fimg='/media/ar/data6T/data/CAMELYON16_Full_for_Start/Train_Normal/Normal_034.tif-L8.png';
% % fimg='/home/ar/data/Camelyon16_Challenge/Train_Data_for_1stage_segmentation/Tumor_001.tif-L8.png';

fimg='/home/ar/data.CAMELYON16_Full_for_Start/Train_Tumor/Tumor_001.tif-L9.png';


img=imread(fimg);
imd=im2double(img);
imgg=rgb2gray(img);
imb=im2bw(imgg, graythresh(imgg));

figure()
subplot(1,2,1)
imshow(img);
subplot(1,2,2)
imhist(imgg)

% % q=reshape(imd,[],3);
% % figure,
% % scatter3(q(:,1),q(:,2), q(:,3))

cform = makecform('srgb2lab');
imgLAB = double(applycform(img,cform));
imgLABV=reshape(double(imgLAB),[],3);

nColors = 3;
[cluster_idx, cluster_center] = kmeans(imgLABV(:,2:3),nColors,...
                        'distance','sqEuclidean', ...
                        'Replicates',3);
pixel_labels = reshape(cluster_idx,size(imgLAB,1),size(imgLAB,2));
figure,
subplot(1,3,1),
scatter(imgLABV(:,2), imgLABV(:,3));
subplot(1,3,2),
imshow(img);
subplot(1,3,3),
imshow(pixel_labels,[]);


