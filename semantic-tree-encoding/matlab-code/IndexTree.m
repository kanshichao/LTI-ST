function [Tree,Index] = IndexTree(TrainData,K,SplitNum,Thresh,Rootbook)
%%
% Author: Shichao Kan
% K: Number of clusters for codebook or tree
% SplitNum: the dimension split for features, and 1 for our TIP paper
% Thresh: not used now
% Rootbook: the codebook of layer 1

if ~exist('K')||K(1)<=1
    K = [2,2,2,2,2];
end
if ~exist('SplitNum')||(SplitNum<=1)
    SplitNum = 1;
    IsPQ = 0;
else
    IsPQ = 1;
end
if ~exist('Thresh')
    Thresh = 0;
end
if ~exist('Rootbook')
     [~,center,~] = kmeans(single(TrainData),K(1));
%     [~,center] = Step_Cluster(TrainData,20,K(1),100);
else
    center = Rootbook;
end

Tree.Deep = length(K);
Tree.KNum = K;
Tree.Width = ones(1,Tree.Deep+1);
Tree.Split = SplitNum;
[~,W] = size(center);
for i = 2:Tree.Deep+1
    Tree.Width(i) = Tree.Width(i-1)*K(i-1);
end
[DataRols,~] = size(TrainData);
Tree.Codebook = cell(1,Tree.Deep);
Index = cell(1,Tree.Deep+1);
SIdx = cell(1,Tree.Deep+1);

Tree.Cdis = cell(1,Tree.Deep);
Tree.Maxdis = cell(1,Tree.Deep + 1);

for i = 1:Tree.Deep
    Tree.Codebook{i} = cell(1,Tree.Width(i));
    Index{i} = cell(1,Tree.Width(i));
    SIdx{i} = cell(1,Tree.Width(i));
    Tree.Cdis{i} = cell(1,Tree.Width(i));
    Tree.Maxdis{i} = zeros(1,Tree.Width(i));
end
if (IsPQ == 1)
    Tree.Codebook{Tree.Deep} = cell(1,Tree.Width(Tree.Deep)*SplitNum);
    Index{Tree.Deep+1} = cell(1,Tree.Width(Tree.Deep+1).*SplitNum);
    SIdx{Tree.Deep+1} = cell(1,Tree.Width(Tree.Deep+1).*SplitNum);
    Tree.Cdis{Tree.Deep} = cell(1,Tree.Width(Tree.Deep)*SplitNum);
    Tree.Maxdis{Tree.Deep + 1} = zeros(1,Tree.Width(Tree.Deep)*SplitNum);
else
    Index{Tree.Deep+1} = cell(1,Tree.Width(Tree.Deep+1));
    SIdx{Tree.Deep+1} = cell(1,Tree.Width(Tree.Deep+1));
    Tree.Maxdis{Tree.Deep+1} = zeros(1,Tree.Width(Tree.Deep+1));
end
Tree.Codebook{1}{1} = center;
Index{1}{1} = 1:DataRols;
SIdx{1}{1} = [];
Tree.Maxdis{1}(1) = Inf;
if IsPQ == 1
    LoopNum = Tree.Deep;
else
    LoopNum = Tree.Deep+1;
end

for i = 2:LoopNum
    Hierarchy = i
    count = 1;
    for j = 1:Tree.Width(i-1)
        if(~isempty(Tree.Codebook{i-1}{j}))
            [Tree.Cdis{i-1}{j}] = yael_dis(Tree.Codebook{i-1}{j}',Tree.Codebook{i-1}{j}');
            [idx,~] = yael_nn(Tree.Codebook{i-1}{j}',TrainData(Index{i-1}{j},:)');
        else
            idx = [];
        end
        
        for k = 1:K(i-1)
            if (~isempty(idx))
                id = find(idx==k);
                Index{i}{count} = Index{i-1}{j}(id);
                SIdx{i}{count} = [];
                [~, Tree.Maxdis{i}(count)] = yael_max(TrainData(Index{i}{count},:)',Tree.Codebook{i-1}{j}(k,:)');
                if (i<LoopNum)
                    if K(i)<=length(id)
                        [~,center,~] = kmeans(single(TrainData(Index{i}{count},:)),K(i));
                        Tree.Codebook{i}{count} = center;
                        [Tree.Cdis{i}{count}] = yael_dis(Tree.Codebook{i}{count}',Tree.Codebook{i}{count}');
                    else
                        center = [];
                    end
                end
            else
                center = [];
            end
            count = count + 1;
        end
    end
end
