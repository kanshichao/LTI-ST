function ctn = count_num(Index)
count = 1;
for i = 1:length(Index)
    for j = 1:length(Index{i})
        ctn(count) = length(Index{i}{j});
        count = count + 1;
    end
end
end