clear;
clc;
close all;

kk = 100; 
codesize = 256;

load('../ebay_features/train_feature.mat');

num = size(features, 1);

D2 =-1*features * features';

D2(1:num+1:num*num) = inf;

knn_class_inds=single(zeros(num,kk));

for i = 1 : num
    this_row = D2(i,:);
    [~, inds] = sort(this_row, 'ascend');
    
    knn_class_inds(i,:) = inds(1:kk);
end

load('codebook/train_512_split1_slice1_CodebookTree_2_hight8.mat')
Codebook = Tree.Codebook;
height = 8;

load('index/train_512_split1_slice1_IndexTree_2_hight8.mat');

wk = ones(1,kk);
wk(1) = 100;

numnode = zeros(height+1,1);
for i = 2:height+1
    numnode(i) = numnode(i-1) + 2^(i-1);
end

label_soft_tree = zeros(num,numnode(height+1));
for i = 1:num
    i
    knn_i = knn_class_inds(i,1:50);
    for k = 2:height+1
        for j = 1:2^(k-1)
            w1 = numel(intersect([-1,knn_i(1)],Index{k}{j}));
            w2 = numel(intersect(knn_i(2:end),Index{k}{j}));
            if w1+w2 > 0
                label_soft_tree(i,numnode(k-1)+j) = (w1*wk(1)+w2)/(w1*wk(1)+w2+numel(Index{k}{j}));
            end
        end
    end
end

label_soft_tree1 = label_soft_tree;
label_soft_tree(:,1:2) = single(label_soft_tree1(:,1:2)./(sum(label_soft_tree1(:,1:2)')'+0.00001));
label_soft_tree(:,3:6) = single(label_soft_tree1(:,3:6)./(sum(label_soft_tree1(:,3:6)')'+0.00001));
label_soft_tree(:,7:14) = single(label_soft_tree1(:,7:14)./(sum(label_soft_tree1(:,7:14)')'+0.00001));
label_soft_tree(:,15:30) = single(label_soft_tree1(:,15:30)./(sum(label_soft_tree1(:,15:30)')'+0.00001));
label_soft_tree(:,31:62) = single(label_soft_tree1(:,31:62)./(sum(label_soft_tree1(:,31:62)')'+0.00001));
label_soft_tree(:,63:126) = single(label_soft_tree1(:,63:126)./(sum(label_soft_tree1(:,63:126)')'+0.00001));
label_soft_tree(:,127:254) = single(label_soft_tree1(:,127:254)./(sum(label_soft_tree1(:,127:254)')'+0.00001));
label_soft_tree(:,255:510) = single(label_soft_tree1(:,255:510)./(sum(label_soft_tree1(:,255:510)')'+0.00001));

save(['ranked_label/soft_train_512_to_train_',num2str(codesize),'_tree.mat'],'label_soft_tree');
