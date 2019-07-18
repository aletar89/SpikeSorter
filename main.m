total_timer = tic;
addpath(genpath('source'))
disp("Start")
tic
if ~exist('full_data', 'var')
    full_data = load('data/mC41_33/data2clean.mat');
    full_raw_data = full_data.sh2_30;
    full_true_spike_times = full_data.res2_30;
    full_true_clusters = full_data.clu2_30;
    good_clusters_ind = any(full_true_clusters == good_clusters('data/mC41_33/mC41_33.sst', 2)',2);
    full_true_clusters(~good_clusters_ind) = [];
    full_true_spike_times(~good_clusters_ind) = [];
end

last_data_ind = round(size(full_raw_data,2)/10);
raw_data = full_raw_data(:,1:last_data_ind);
true_spike_times = full_true_spike_times(full_true_spike_times < last_data_ind);
true_clusters = full_true_clusters(1:length(true_spike_times));
S = SpikeSorter(raw_data, true_spike_times, true_clusters);
disp(sprintf("Finished loading data. Elapsed %.1f sec.", toc))

if ~isfield(full_data, "sh2_30_clean")
    tic
    pre_process_handle = @(raw_data) bandpass(double(raw_data'), [250, 6000], 20000)';
    S.pre_process(pre_process_handle);
    disp(sprintf("Finished cleaning data. Elapsed %.1f sec.", toc))
else
    S.clean_data = double(full_data.sh2_30_clean(:,1:last_data_ind));
end

tic
detection_margin = 10; %samples to each side
detection_handle = @(clean_data) modified_findpeaks(clean_data,4.5,1.05,100);
detection_rating = S.detect_and_rate(detection_handle, detection_margin);
disp(sprintf("Detection rating is %.1f%%. Elapsed %.1f sec.", [detection_rating*100, toc]))

tic
%feature_extraction_handle = @(clean_data,spike_times) spike_energy(clean_data,spike_times, 16);
feature_extraction_handle = @(clean_data,spike_times) FSDE(clean_data,spike_times, 16);
S.extract_features(feature_extraction_handle);
disp(sprintf("Finished extracting features. Elapsed %.1f sec.", toc))

tic
clustering_handle = @(features) kmeans(features',15, 'Replicates',5, 'MaxIter',1000);
clustering_rating = S.cluster_and_rate(clustering_handle, detection_margin);
disp(sprintf("Clustering rating is %.1f%%. Elapsed %.1f sec.", [clustering_rating*100, toc]))

disp(sprintf("Total time: %.1f seconds", toc(total_timer)))

FSDE_clustering = S.test_clusters;
feature_extraction_handle = @(clean_data,spike_times) spike_energy(clean_data,spike_times, 16);
S.extract_features(feature_extraction_handle);
S.cluster_and_rate(clustering_handle, detection_margin);
energy_clustering = S.test_clusters;

S.rate_clustering(S.test_spike_times, energy_clustering, S.test_spike_times, FSDE_clustering, detection_margin)


