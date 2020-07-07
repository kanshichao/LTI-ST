%%
clear;
clc;
close all;
%% Using examples
% top-down hierarchical clustering

CodebookPath = 'codebook/';
IndexPath = 'index/';
load('../ebay_features/train_feature.mat');
dim = size(features,2);
split = 1; % split is always set as 1 for our TIP paper
% K = [256]; % for codebook
K = [2,2,2,2,2,2,2,2]; % for tree, and the number of child node on each layer
SplitNum = 1;
Thresh = 0;
slice = int32(dim/split);
for i = 1:split
    TrainData = features(:,slice*(i-1)+1:slice*i);
    [Tree,Index] = IndexTree(TrainData,K,SplitNum,Thresh);
    save([CodebookPath,'train_',num2str(dim),'_split', num2str(split),'_slice',num2str(i),'_CodebookTree_',num2str(K(1)),'_hight',num2str(length(K)),'.mat'],'Tree');
    save([IndexPath,'train_',num2str(dim),'_split', num2str(split),'_slice',num2str(i),'_IndexTree_',num2str(K(1)),'_hight',num2str(length(K)),'.mat'],'Index');
end

