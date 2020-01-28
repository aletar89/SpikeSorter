data_names = ["mC41_33", "mC41_12"];
shanks = (1:5)';
N_filters = 1;
N_results = (length(data_names) * length(shanks) - 3) * N_filters;
Results(1:N_results) = struct('data_name',[],'shank',[],...
            'FPR_train',[],'FPR_test',[]);
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
        FPR_train = sum(train_clu==0 | train_clu==1)/numel(train_clu)*100;
        FPR_test = sum(test_clu==0 | test_clu==1)/numel(test_clu)*100;
        Results(r_count) = struct('data_name',data_name,'shank',shank,...
            'FPR_train',FPR_train,'FPR_test',FPR_test);
        r_count = r_count + 1;
        disp(struct2table(Results))
    end
end
RTable = struct2table(Results);
run add_stability
RTable.algorithm = ["";"";"";"";"";"";""];
MTable = summarize(RTable);
save('ground_truth_FPR','RTable','MTable');
