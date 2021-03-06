tic
PCA = load('sst_library_PCA.mat'); lib_coeff = PCA.lib_coeff(:,1:3); clear PCA;
data_names = ["mC41_33", "mC41_12"];
shanks = (1:5)';
N_filters = 8;
N_results = (length(data_names) * length(shanks) - 3) * N_filters;
Results(1:N_results) = struct('data_name',[],'shank',[],...
    'algorithm',[],...
    'mean_FNR',[],'mean_FPR',[],'weighted_FNR',[],'weighted_FPR',[]);
r_count = 1;
for d = 1:length(data_names)
    data_name = data_names(d);
    for s = 1:length(shanks)
        tic
        %% Loading
        shank = shanks(s);
        if (strcmp(data_name, 'mC41_33') && shank == 5) || ...
                (strcmp(data_name, 'mC41_12') && shank == 3) || ...
                (strcmp(data_name, 'mC41_12') && shank == 5)
            continue
        end
        train_filename = sprintf("D:/Alex/%s/MATLAB/%s_shank_%d_train.mat",data_name,data_name,shank);
        test_filename = sprintf("D:/Alex/%s/MATLAB/%s_shank_%d_test.mat",data_name,data_name,shank);
        detections_filename = sprintf("D:/Alex/%s/MATLAB/%s_shank_%d_detections.mat",data_name,data_name,shank);
        
        load(train_filename)
        load(test_filename)
        load (detections_filename)
        X2_train = single(X2_train);
        X2_test = single(X2_test);
        train_aligned_res = realign_ground_truth(raw_train_data, train_res(train_c_clusters));
        test_aligned_res = realign_ground_truth(raw_test_data, test_res(test_c_clusters));
        
        rate_clusters = @(my_clusters) evaluate_clustering(my_clusters, test_aligned_res,test_clu,test_c_clusters);
        result = @(algorithm, my_clusters) clustering_result(rate_clusters(my_clusters),algorithm,data_name,shank);
        disp('Finished Loading')
        %% 3PC for each channel
        all_pc_train_features = sstlibPCA_all(raw_train_data,train_aligned_res, 3);
        all_pc_test_features = sstlibPCA_all(raw_test_data,test_aligned_res, 3);
        
        [cluster_ids, means, prescisions] = gen_GMM(train_clu(train_c_clusters), all_pc_train_features);
        [my_clusters, dists] = given_means(all_pc_test_features, means, prescisions);
        my_clusters = cluster_ids(my_clusters); % naming the clusters by the original names
        
        Results(r_count) = result('3PC Mahalanobis', my_clusters);
        r_count = r_count + 1;
        
        tree = fitctree(all_pc_train_features',train_clu(train_c_clusters), 'MaxNumSplits', 64);
        my_clusters = predict(tree, all_pc_test_features');
        
        Results(r_count) = result('3PC DT', my_clusters);
        r_count = r_count + 1;
        %% 2PC for each channel
        all_pc_train_features = sstlibPCA_all(raw_train_data,train_aligned_res, 2);
        all_pc_test_features = sstlibPCA_all(raw_test_data,test_aligned_res, 2);
        
        [cluster_ids, means, prescisions] = gen_GMM(train_clu(train_c_clusters), all_pc_train_features);
        [my_clusters, dists] = given_means(all_pc_test_features, means, prescisions);
        my_clusters = cluster_ids(my_clusters); % naming the clusters by the original names
        
        Results(r_count) = result('2PC Mahalanobis', my_clusters);
        r_count = r_count + 1;
        
        tree = fitctree(all_pc_train_features',train_clu(train_c_clusters), 'MaxNumSplits', 64);
        my_clusters = predict(tree, all_pc_test_features');
        
        Results(r_count) = result('2PC DT', my_clusters);
        r_count = r_count + 1;
        %% FSDE for each channel
        FSDE_train_features = FSDE(raw_train_data,train_aligned_res);
        FSDE_test_features = FSDE(raw_test_data,test_aligned_res);
        
        [cluster_ids, means, prescisions] = gen_GMM(train_clu(train_c_clusters), FSDE_train_features);
        [my_clusters, dists] = given_means(FSDE_test_features, means, prescisions);
        my_clusters = cluster_ids(my_clusters); % naming the clusters by the original names
        
        Results(r_count) = result('FSDE Mahalanobis', my_clusters);
        r_count = r_count + 1;
        
        tree = fitctree(FSDE_train_features',train_clu(train_c_clusters), 'MaxNumSplits', 64);
        my_clusters = predict(tree, FSDE_test_features');
        
        Results(r_count) = result('FSDE DT', my_clusters);
        r_count = r_count + 1;
        %% Decision Tree samples
        
        all_train_spikes = chained_spikes(X2_train,train_res(train_c_clusters));
        all_test_spikes = chained_spikes(X2_test,test_res(test_c_clusters));
        
        tree = fitctree(all_train_spikes,train_clu(train_c_clusters), 'MaxNumSplits', 64);
        predictor_names = unique(tree.CutPredictor);
        predictor_samples = zeros(size(predictor_names,1)-1,1);
        for i = 2:length(predictor_names)
            predictor_name = predictor_names{i};
            predictor_samples(i-1) = str2double(predictor_name(2:end));
        end
        predictor_samples = unique(predictor_samples);
        
        train_predicor_samples = all_train_spikes(:,predictor_samples)';
        test_predicor_samples = all_test_spikes(:,predictor_samples)';
        
        [cluster_ids, means, prescisions] = gen_GMM(train_clu(train_c_clusters), train_predicor_samples);
        [my_clusters, dists] = given_means(test_predicor_samples, means, prescisions);
        my_clusters = cluster_ids(my_clusters); % naming the clusters by the original names
        
        Results(r_count) = result('DT samples Mahalanobis', my_clusters);
        r_count = r_count + 1;
        %% Decision Tree sort
        my_clusters = predict(tree, all_test_spikes);
        Results(r_count) = result('DT', my_clusters);
        r_count = r_count + 1;
        %%
        disp(struct2table(Results(1:r_count-1)))
        save('features_results','Results');
        toc
    end
end
RTable = struct2table(Results);
RTable((strcmp(RTable.data_name, 'mC41_33') & RTable.shank == 5) | ...
    (strcmp(RTable.data_name, 'mC41_12') & RTable.shank == 3) | ...
    (strcmp(RTable.data_name, 'mC41_12') & RTable.shank == 5),:) = [];
toc
run add_stability
MTable = summarize(RTable);
save('features_results','RTable','MTable');
