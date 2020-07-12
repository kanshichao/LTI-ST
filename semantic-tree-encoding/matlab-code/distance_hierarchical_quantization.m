function [index] = distance_hierarchical_quantization(fc_trans,codetree,height)
index = cell(height,1);
for i = 1:height
    index{i} = cell(2^i,1);
end
for i = 1:height
    count = 1;
    for j = 1:2^(i-1)
        if(i==1)
            [idx, ~] = yael_nn(codetree{i}{j}',fc_trans');
            for k = 1:size(codetree{i}{j},1)
                id = find(idx==k);
                index{i}{count} = id;
                count = count + 1;
            end
        else
            if ~isempty(codetree{i}{j})
                [idx, ~] = yael_nn(codetree{i}{j}',fc_trans(index{i-1}{j},:)');
                for k = 1:size(codetree{i}{j},1)
                    id = find(idx==k);
                    index{i}{count} = index{i-1}{j}(id);
                    count = count +1;
                end
            else
                count = count + size(codetree{1}{1},1);
            end
        end
    end
end
end