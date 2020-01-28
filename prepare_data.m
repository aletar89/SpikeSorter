F_sampling = 20E3;
samples_in_15_min = 15*60*F_sampling;
samples_in_30_min = 30*60*F_sampling;
train_samples = samples_in_15_min+1 : samples_in_15_min+samples_in_30_min;
test_samples = samples_in_15_min+samples_in_30_min+1:samples_in_15_min+2*samples_in_30_min;
data_name = 'mC41_12';
data_path = ['D:/Alex/' data_name '/'];
% F_low = 250;
% F_high = 6E3;
% pre_process_handle = @(raw_data) bandpass(double(raw_data'), [F_low, F_high], F_sampling)';
m = memmapfile([data_path data_name '.dat'], 'format', 'int16' );
chNum =63;
datamat = reshape( m.Data, [ chNum , size(m.Data,1) / chNum ] );
electrodes = [10, 10, 10, 11, 10];
channel_index = [0, cumsum(electrodes)];
all_train_data = datamat(1:channel_index(end),train_samples);
all_test_data = datamat(1:channel_index(end),test_samples);
clear datamat
load([data_path data_name '.sst'], 'sst', '-mat');
is_c_cluster = check_cluster_quality( sst, 'c' );
disp('Finished Loading');
for shank = 1:length(electrodes)
    raw_train_data = all_train_data(channel_index(shank)+1:channel_index(shank+1),:);
    raw_test_data = all_test_data(channel_index(shank)+1:channel_index(shank+1),:);
    res = load([data_path data_name '.res.' num2str(shank)]);
    clu = load([data_path data_name '.clu.' num2str(shank)]);
    if length(clu)>length(res), clu(1) = []; end % The first value in the clu file is the number of clusters and not the cluster of the first spike
    train_spike_ids = find(res>min(train_samples) & res<max(train_samples));
    train_res = res(train_spike_ids) - min(train_samples)+1;
    train_clu = clu(train_spike_ids);
    test_spike_ids = find(res>min(test_samples) & res<max(test_samples));
    test_res = res(test_spike_ids) - min(test_samples)+1;
    test_clu = clu(test_spike_ids);
    c_cluster_labels = sst.shankclu(is_c_cluster & sst.shankclu(:,1) == shank,2);
    train_c_clusters = any(train_clu == c_cluster_labels',2);
    train_0_clusters = train_clu == 0 | train_clu == 1; %Sep 04 2019- fixed bug after running all the analysis
    test_c_clusters = any(test_clu == c_cluster_labels',2);
    test_0_clusters = test_clu == 0 | test_clu == 1; %Sep 04 2019- fixed bug after running all the analysis
    
    %% clean data with bandpass
    %     tic
    %     clean_data = int16(pre_process_handle(raw_data));
    %     toc
    %% save .mat file
    disp(sprintf('Strating save for shank %d/%d',shank,length(electrodes)))
    file_name = sprintf('%s%s%s_shank_%d_',data_path, 'MATLAB/', data_name,shank);
    save([file_name 'train'],'raw_train_data','train_res','train_clu',...
        'train_c_clusters', 'train_0_clusters', 'shank', 'data_name');
    save([file_name 'test'],'raw_test_data','test_res','test_clu',...
        'test_c_clusters', 'test_0_clusters',  'shank', 'data_name');
    disp(sprintf('Finished save for shank %d/%d',shank,length(electrodes)))
    
end

