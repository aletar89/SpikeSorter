tic
PCA = load('sst_library_PCA.mat'); lib_coeff = PCA.lib_coeff(:,1:3); clear PCA;
data_names = ["mC41_33", "mC41_12"];
shanks = (1:5)';
N_filters = 5;
N_results = (length(data_names) * length(shanks) - 3) * N_filters;
Results(1:N_results) = struct('data_name',[],'shank',[],...
            'algorithm',[],...
            'dFNR',[],'dFPR2FPR',[],'tree',[]);
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
        gt_test_times = test_res(test_c_clusters);
        if exist(detections_filename,'file')
            load (detections_filename)
            X2_train = single(X2_train);
            X2_test = single(X2_test);
        else
            [X2_train_detections,X2_test_detections, X2_train, X2_test] = X2_detection(raw_train_data,raw_test_data);
            X2_train = int16(X2_train);
            X2_test = int16(X2_test);
            save(detections_filename,'X2_train_detections','X2_test_detections', 'X2_train', 'X2_test');
        end
        train_detection_rating = rate_detection(X2_train_detections, train_res(train_c_clusters), 10);
        test_detection_rating = rate_detection(X2_test_detections, test_res(test_c_clusters), 10);
        
        fit_tree = @(FN_cost, MaxSplits, train_X) fitctree(train_X,train_detection_rating.det_times,...
            'MaxNumSplits', MaxSplits, 'ClassNames',[false, true], 'Cost', [0, 1; FN_cost, 0]);
        rate_tree = @(tree, test_X) rate_detection(X2_test_detections(predict(tree, test_X)), gt_test_times, 10);
        dFNR = @(rating) rating.FNR*100-test_detection_rating.FNR*100;
        dFPR2FPR = @(rating) 100*(test_detection_rating.FPR-rating.FPR)/test_detection_rating.FPR;
        find_cost_for_dFNR_is_1 = @(dFNR_func) fzero(@(x) dFNR_func(x)-1,[10,35],optimset('Display','iter','TolX',0.01));
        disp('Finished Loading')
        %% All X2 samples (8 splits and 64 splits)
        train_all_X2 = chained_spikes(X2_train,X2_train_detections);
        test_all_X2 = chained_spikes(X2_test,X2_test_detections);
        fit_tree_X2 = @(FN_cost, MaxSplits) fit_tree(FN_cost, MaxSplits, train_all_X2);
        dFNR_X2_8 = @(cost) dFNR(rate_tree(fit_tree_X2(cost,8), test_all_X2));
        dFPR2FPR_X2_8 = @(cost) dFPR2FPR(rate_tree(fit_tree_X2(cost,8), test_all_X2));
        Results(r_count) = get_result('All X2 samples 8 splits', dFNR_X2_8,dFPR2FPR_X2_8, fit_tree_X2,...
            data_name,shank,find_cost_for_dFNR_is_1);
        r_count = r_count + 1;
        
        dFNR_X2_64 = @(cost) dFNR(rate_tree(fit_tree_X2(cost,64), test_all_X2));
        dFPR2FPR_X2_64 = @(cost) dFPR2FPR(rate_tree(fit_tree_X2(cost,64), test_all_X2));
        Results(r_count) = get_result('All X2 samples 64 splits', dFNR_X2_64,dFPR2FPR_X2_64, fit_tree_X2,...
            data_name,shank,find_cost_for_dFNR_is_1);
        r_count = r_count + 1;
        disp('Finished All X2')
        %% Full Features (3PC, 16bit)
        train_full_features = calc_features(raw_train_data, X2_train, X2_train_detections, lib_coeff, 3, 16);     
        test_full_features = calc_features(raw_test_data, X2_test, X2_test_detections, lib_coeff, 3, 16);     
        fit_tree_full = @(FN_cost, MaxSplits) fit_tree(FN_cost, MaxSplits, train_full_features);
        dFNR_full = @(cost) dFNR(rate_tree(fit_tree_full(cost,64), test_full_features));
        dFPR2FPR_full = @(cost) dFPR2FPR(rate_tree(fit_tree_full(cost,64), test_full_features));
        Results(r_count) = get_result('Full Features', dFNR_full,dFPR2FPR_full, fit_tree_full,...
            data_name,shank,find_cost_for_dFNR_is_1);
        r_count = r_count + 1;
        %% Quantized Features (3PC, 4bit)
        train_quant_features = calc_features(raw_train_data, X2_train, X2_train_detections, lib_coeff, 3, 4);     
        test_quant_features = calc_features(raw_test_data, X2_test, X2_test_detections, lib_coeff, 3, 4);     
        fit_tree_quant = @(FN_cost, MaxSplits) fit_tree(FN_cost, MaxSplits, train_quant_features);
        dFNR_quant = @(cost) dFNR(rate_tree(fit_tree_quant(cost,64), test_quant_features));
        dFPR2FPR_quant = @(cost) dFPR2FPR(rate_tree(fit_tree_quant(cost,64), test_quant_features));
        Results(r_count) = get_result('Quantized Features', dFNR_quant,dFPR2FPR_quant, fit_tree_quant,...
            data_name,shank,find_cost_for_dFNR_is_1);
        r_count = r_count + 1;
        %% Features w/o p2p (3PC, 16bit)
        train_wo_p2p_features = train_full_features;
        test_wo_p2p_features = test_full_features;
        train_wo_p2p_features.raw_p2p = [];
        test_wo_p2p_features.raw_p2p = [];
        fit_tree_wo_p2p = @(FN_cost, MaxSplits) fit_tree(FN_cost, MaxSplits, train_wo_p2p_features);
        dFNR_wo_p2p = @(cost) dFNR(rate_tree(fit_tree_wo_p2p(cost,64), test_wo_p2p_features));
        dFPR2FPR_wo_p2p = @(cost) dFPR2FPR(rate_tree(fit_tree_wo_p2p(cost,64), test_wo_p2p_features));
        Results(r_count) = get_result('Features w/o p2p', dFNR_wo_p2p,dFPR2FPR_wo_p2p, fit_tree_wo_p2p,...
            data_name,shank,find_cost_for_dFNR_is_1);
        r_count = r_count + 1; 
        %%
        disp(struct2table(Results(1:r_count-1)))
        save('filter_results_mC41_12','Results');
        toc
    end
end
RTable = struct2table(Results);
RTable((strcmp(RTable.data_name, 'mC41_33') & RTable.shank == 5) | ...
    (strcmp(RTable.data_name, 'mC41_12') & RTable.shank == 3) | ...
    (strcmp(RTable.data_name, 'mC41_12') & RTable.shank == 5),:) = [];
toc
run add_stability
unpruned_RTable = RTable;
RTable(RTable.dFNR<0.8 | RTable.dFNR>1.2,:) = [];
RTable.tree = [];
MTable = summarize(RTable);
save('filter_results','RTable','MTable','unpruned_RTable');
