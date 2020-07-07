%%
clc;
clear;
close all;
%% Using examples
% Paper: Shi-Chao Kan, Yi-Gang Cen, Yi Cen, Yanhong Wang, Viacheslav V. Voronin, Vladimir Mladenovic, Ming Zeng. SURF binarization and fast codebook construction for image retrieval. J. Vis. Commun. Image Represent. 49: 104-114 (2017).

train_feature = load('../ebay_features/features_train.mat');
train_feature = train_feature.features;

K1 = 20;     
K2 = 256;     
Num = 500;   
[step_center,center] = Step_Cluster(train_feature,K1,K2,Num);    
