function [result] = clustering_result(single_cluster_ratings,algorithm,data_name,shank)
mean_FNR = mean(single_cluster_ratings.FNR)*100;
mean_FPR = mean(single_cluster_ratings.FPR)*100;
weighted_FNR = sum(single_cluster_ratings.FNR.*single_cluster_ratings.cluster_size)/sum(single_cluster_ratings.cluster_size)*100;
weighted_FPR = sum(single_cluster_ratings.FPR.*single_cluster_ratings.cluster_size)/sum(single_cluster_ratings.cluster_size)*100;
result = struct('data_name',data_name,'shank',shank,...
    'algorithm',algorithm,...
    'mean_FNR',mean_FNR,'mean_FPR',mean_FPR,'weighted_FNR',weighted_FNR,'weighted_FPR',weighted_FPR);
end

