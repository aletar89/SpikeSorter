tic
data_names = ["mC41_33"; "mC41_12"];
shanks = (1:5)';
N_results = (length(data_names) * length(shanks) - 3) * 4;
Results(1:N_results) = struct('data_name',[],'shank',[],'algorithm',[],'FNR',[],'FPR',[]);
r_count = 1;
for d = 1:length(data_names)
    data_name = data_names(d);
    for s = 1:length(shanks)
        shank = shanks(s);
        if (strcmp(data_name, 'mC41_33') && shank == 5) || ...
               (strcmp(data_name, 'mC41_12') && shank == 3) || ... 
               (strcmp(data_name, 'mC41_12') && shank == 5)
           continue
        end
        train_filename = sprintf("D:/Alex/%s/MATLAB/%s_shank_%d_train.mat",data_name,data_name,shank);
        test_filename = sprintf("D:/Alex/%s/MATLAB/%s_shank_%d_test.mat",data_name,data_name,shank);
        load(train_filename)
        N_electrodes = size(raw_train_data,1);
        % modified second derivative handle
        minus_d = 6; plus_d = 9;
        mod2der_func = @(data) single([zeros(N_electrodes,minus_d),...
            (-0.5)*data(:,1:end-(minus_d+plus_d))+...
            data(:,minus_d+1:end-plus_d)+...
            (-0.5)*data(:,minus_d+plus_d+1:end),...
            zeros(N_electrodes,plus_d)]);
        % bandpass handle
        F_low = 250;
        F_high = 6E3;
        F_sampling = 20E3;
        band_pass_func = @(data) bandpass(single(data'), [F_low, F_high], F_sampling)';
        % detection handle
        detection_func = @(data, threshold) find(any([false(N_electrodes,1),...
            abs(data(:,2:end-1))>abs(data(:,1:end-2))&...
            abs(data(:,2:end-1))>abs(data(:,3:end))&...
            abs(data(:,2:end-1))>repmat(threshold,1,size(data,2)-2),...
            false(N_electrodes,1)]));
        
        X2_train = mod2der_func(raw_train_data);
        BP_train = band_pass_func(raw_train_data);
        
        detection_threshold = 4;
        X2_threshold = zeros(N_electrodes,1);
        for e = 1:N_electrodes
            X2_threshold(e) = detection_threshold * std(X2_train(e,X2_train(e,:)<detection_threshold * std(X2_train(e,:))));
        end
        BP_threshold = zeros(N_electrodes,1);
        for e = 1:N_electrodes
            BP_threshold(e) = detection_threshold * std(BP_train(e,BP_train(e,:)<detection_threshold * std(BP_train(e,:))));
        end
        
        load(test_filename)
        X2_test = mod2der_func(raw_test_data);
        BP_test = band_pass_func(raw_test_data);
        
        X2_raw_detections = detection_func(X2_test, X2_threshold);
        X2_raw_rating = rate_detection(X2_raw_detections, test_res(test_c_clusters), 10);
        Results(r_count) = struct('data_name',data_name,'shank',shank,...
            'algorithm','X2 raw','FNR',X2_raw_rating.FNR*100,'FPR',X2_raw_rating.FPR*100);
        r_count = r_count + 1;
        X2_deadtime_detections = realign_detections(raw_test_data,X2_raw_detections);
        X2_deadtime_rating = rate_detection(X2_deadtime_detections, test_res(test_c_clusters), 10);
        Results(r_count) = struct('data_name',data_name,'shank',shank,...
            'algorithm','X2 dead time','FNR',X2_deadtime_rating.FNR*100,'FPR',X2_deadtime_rating.FPR*100);
        r_count = r_count + 1;
        
        BP_raw_detections = detection_func(BP_test, BP_threshold);
        BP_raw_rating = rate_detection(BP_raw_detections, test_res(test_c_clusters), 10);
        Results(r_count) = struct('data_name',data_name,'shank',shank,...
            'algorithm','BP raw','FNR',BP_raw_rating.FNR*100,'FPR',BP_raw_rating.FPR*100);
        r_count = r_count + 1;
        BP_deadtime_detections = realign_detections(raw_test_data,BP_raw_detections);
        BP_deadtime_rating = rate_detection(BP_deadtime_detections, test_res(test_c_clusters), 10);
        Results(r_count) = struct('data_name',data_name,'shank',shank,...
            'algorithm','BP dead time','FNR',BP_deadtime_rating.FNR*100,'FPR',BP_deadtime_rating.FPR*100);
        r_count = r_count + 1;
        disp(struct2table(Results))
    end
end
RTable = struct2table(Results);
RTable((strcmp(RTable.data_name, 'mC41_33') & RTable.shank == 5) | ...
    (strcmp(RTable.data_name, 'mC41_12') & RTable.shank == 3) | ...
    (strcmp(RTable.data_name, 'mC41_12') & RTable.shank == 5),:) = [];
toc
run add_stability
MTable = summarize(RTable);
save('detection_results','RTable','MTable');
