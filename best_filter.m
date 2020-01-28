tic
data_names = ["mC41_33", "mC41_12"];
shanks = (1:5)';
N_filters = 4;
N_results = (length(data_names) * length(shanks) - 3) * N_filters;
Results(1:N_results) = struct('data_name',[],'shank',[],...
            'algorithm',[],...
            'FNR',[],'FPR',[],'tree',[]);
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
        disp('Finished Loading')
        %% All X2 samples (64 splits)
        train_all_X2 = chained_spikes(X2_train,X2_train_detections);
        test_all_X2 = chained_spikes(X2_test,X2_test_detections);
        
        tree1 = fit_tree(1, 64, train_all_X2);
        rating1 = rate_tree(tree1, test_all_X2);
        Results(r_count) = struct('data_name',data_name,'shank',shank,...
            'algorithm','FNcost=1',...
            'FNR',rating1.FNR*100,'FPR',rating1.FPR*100,'tree',tree1);
        r_count = r_count + 1;

        tree10 = fit_tree(10, 64, train_all_X2);
        rating10 = rate_tree(tree10, test_all_X2);
        Results(r_count) = struct('data_name',data_name,'shank',shank,...
            'algorithm','FNcost=10',...
            'FNR',rating10.FNR*100,'FPR',rating10.FPR*100,'tree',tree10);
        r_count = r_count + 1;

        tree100 = fit_tree(100, 64, train_all_X2);
        rating100 = rate_tree(tree100, test_all_X2);
        Results(r_count) = struct('data_name',data_name,'shank',shank,...
            'algorithm','FNcost=100',...
            'FNR',rating100.FNR*100,'FPR',rating100.FPR*100,'tree',tree100);
        r_count = r_count + 1;
        
        offline_FPR = sum(test_clu==0 | test_clu==1)/numel(test_clu);
        Results(r_count) = struct('data_name',data_name,'shank',shank,...
            'algorithm','offline',...
            'FNR',0,'FPR',offline_FPR*100,'tree',[]);
        r_count = r_count + 1;
        disp(struct2table(Results))
        toc
    end
end
RTable = struct2table(Results);
RTable((strcmp(RTable.data_name, 'mC41_33') & RTable.shank == 5) | ...
    (strcmp(RTable.data_name, 'mC41_12') & RTable.shank == 3) | ...
    (strcmp(RTable.data_name, 'mC41_12') & RTable.shank == 5),:) = [];
toc
run add_stability
RTable_no_tree = RTable;
RTable_no_tree.tree = [];
MTable = summarize(RTable_no_tree);
save('filter_results','RTable','MTable');
