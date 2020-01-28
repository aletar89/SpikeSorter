function [single_cluster_ratings] = evaluate_clustering(my_clusters, test_aligned_res,test_clu,test_c_clusters)
    unique_test_c_clusters = unique(test_clu(test_c_clusters));
single_cluster_ratings(1:length(unique_test_c_clusters)) = struct('cluster_id',[],'cluster_size',[],'FNR',[],'FPR',[],'rating',[]);
    for i = 1:length(unique_test_c_clusters)
        res_in_this_cluster = test_aligned_res(test_clu(test_c_clusters)==unique_test_c_clusters(i));
        estimated_res_in_this_cluster = test_aligned_res(my_clusters==unique_test_c_clusters(i));
        single_cluster_rating = rate_detection(estimated_res_in_this_cluster, res_in_this_cluster, 10);
        single_cluster_ratings(i) = struct('cluster_id',unique_test_c_clusters(i),'cluster_size',sum(test_clu==unique_test_c_clusters(i)), 'FNR',single_cluster_rating.FNR,'FPR',single_cluster_rating.FPR,'rating',single_cluster_rating);
    end
    %display_confusion(clusterconfusion(test_clu(test_c_clusters), my_clusters ), unique_test_c_clusters, cluster_ids)
    single_cluster_ratings = struct2table(single_cluster_ratings);
end

