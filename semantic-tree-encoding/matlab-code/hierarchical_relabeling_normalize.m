clear;
clc;
close all;

dim = 512;
split = 1;

% K = [256];
K = [2,2,2,2,2,2,2,2];

height = length(K);
Image_path = ['/home/visitor/SSD/data/Stanford_Online_Products'];
img_train_path = [Image_path,'/Ebay_train.txt'];
[image_ids, class_ids, superclass_ids, path_list] = ...
    textread(img_train_path, '%d %d %d %s',...
    'headerlines', 1);
%% for test
% class_ids = class_ids - 11318;
%%

%%
% This code can be used to generate final hard, soft and ranked label that defined in our paper
% load(['ranked_label/soft_train_512_to_train',num2str(256),'.mat'],'label_soft_tree');
% softcode = label_soft_tree;
%%
for si = 1:split
    IndexName = ['train_',num2str(dim),'_split', num2str(split),'_slice',num2str(si),'_IndexTree_',num2str(K(1)),'_hight',num2str(length(K)),'.mat'];

    load(['index/',IndexName]);
    newlabel = zeros(max(class_ids),height);
    numnode = zeros(height+1,1);
    if height>1
        for i = 2:height+1
            numnode(i) = numnode(i-1) + 2^(i-1);
        end
    else
        numnode(height+1) = K;
    end
    onehot = zeros(max(class_ids),numnode(height+1));
    softcode = zeros(max(class_ids),numnode(height+1));
    for k = 1:max(class_ids)
        num_class_data = numel(find(class_ids==k));
        for i = 1:height
            num = zeros(length(Index{i+1}),1);
            for j = 1:length(Index{i+1})
                num(j) = numel(find(class_ids(Index{i+1}{j})==k))/length(Index{i+1}{j});
                softcode(k,numnode(i)+j) = num(j) / num_class_data;
            end
            softcode(k,numnode(i)+1:numnode(i+1)) = softcode(k,numnode(i)+1:numnode(i+1)) / sum(softcode(k,numnode(i)+1:numnode(i+1)));
            maxnum = find(num==max(num));
            newlabel(k,i) = maxnum(1);
            onehot(k,maxnum(1)+numnode(i)) = 1;
        end
    end
    save(['relabeled_data_normalized/soft_train_',num2str(dim),'_split', num2str(split),'_slice',num2str(si),'_IndexTree_',num2str(K(1)),'_hight',num2str(length(K)),'.mat'],'newlabel','onehot','softcode','numnode');
end
