function [step_center,center] = Step_Cluster(Data,K1,K2,Num)
%%
% Author: Shichao Kan
% Paper: Shi-Chao Kan, Yi-Gang Cen, Yi Cen, Yanhong Wang, Viacheslav V. Voronin, Vladimir Mladenovic, Ming Zeng. SURF binarization and fast codebook construction for image retrieval. J. Vis. Commun. Image Represent. 49: 104-114 (2017).
% K1: clusters of the first step, K2: clusters of the second step, Num: the number of random data groups

if(nargin == 1)
    K1 = 2;
    K2 = 2;
    Num = 1;
elseif(nargin == 2)
    K2 = K1;
    Num = 1;
elseif(nargin == 3)
    Num = 1;
end
[m,] = size(Data);
DataNum = floor(m/Num);
step_center = cell(1,Num);
for i = 1:Num
    step = i
    [~,step_center{i},~] = kmeans(single(Data((i-1)*DataNum+1:i*DataNum,:)),K1);
end
if Num>=2
    ClusterData = [];
    for i = 1:Num
        ClusterData = [ClusterData;step_center{i}];
    end
    [~,center,~] = kmeans(single(ClusterData),K2);
else
    center = step_center{1};
end
end

