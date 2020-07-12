clear;
clc;
close all;

CodebookPath = 'codebook/';
IndexPath = 'index/';
load('../ebay_features/train_feature.mat');
dim = size(features,2);
split = 1;
% K = [256];
K = [2,2,2,2,2,2,2,2];
SplitNum = 1;
Thresh = 0;
slice = int32(dim/split);
for i = 1:split
    TestData = features(:,slice*(i-1)+1:slice*i);
    load([CodebookPath,'train_',num2str(dim),'_split', num2str(split),'_slice',num2str(i),'_CodebookTree_',num2str(K(1)),'_hight',num2str(length(K)),'.mat']);
    Index = distance_hierarchical_quantization(TestData,Tree.Codebook,length(K));
    save([IndexPath,'train_to_test_',num2str(dim),'_split', num2str(split),'_slice',num2str(i),'_IndexTree_',num2str(K(1)),'_hight',num2str(length(K)),'.mat'],'Index');
end
