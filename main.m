total_timer = tic;
addpath(genpath('source'))
disp("Start")
tic
if ~exist('full_raw_data', 'var')
    full_raw_data = load('data/mC41_33/sh1_30.mat'); full_raw_data = full_raw_data.sh1_30;
    full_true_spike_times = load('data/mC41_33/res1_30.mat'); full_true_spike_times = full_true_spike_times.res1_30;
    full_true_clusters = load('data/mC41_33/clu1_30.mat'); full_true_clusters = full_true_clusters.clu1_30;
    full_true_clusters(1) = [];
    full_true_spike_times(end) = [];
    bad_clusters = (full_true_clusters == 0 | full_true_clusters == 1);
    full_true_clusters(bad_clusters) = [];
    full_true_spike_times(bad_clusters) = [];
end

last_data_ind = round(size(full_raw_data,2)/2);
raw_data = full_raw_data(:,1:last_data_ind);
true_spike_times = full_true_spike_times(full_true_spike_times < last_data_ind);
true_clusters = full_true_clusters(1:length(true_spike_times));
S = SpikeSorter(raw_data, true_spike_times, true_clusters);
disp(sprintf("Finished loading data. Elapsed %.1f sec.", toc))

tic
pre_process_handle = @(raw_data) bandpass(double(raw_data'), [250, 6000], 20000)';
S.pre_process(pre_process_handle);
disp(sprintf("Finished cleaning data. Elapsed %.1f sec.", toc))

tic
detection_margin = 10; %samples to each side
detection_handle = @(clean_data) modified_findpeaks(clean_data,4,1.05,100);
detection_rating = S.detect_and_rate(detection_handle, detection_margin);
disp(sprintf("Detection rating is %.1f%%. Elapsed %.1f sec.", [detection_rating*100, toc]))

tic
feature_extraction_handle = @(clean_data,spike_times) spike_energy(clean_data,spike_times, 16);
S.extract_features(feature_extraction_handle);
disp(sprintf("Finished extracting features. Elapsed %.1f sec.", toc))

tic
clustering_handle = @(features) kmeans(squeeze(features)',15,'Distance', 'cityblock', 'Replicates',5, 'MaxIter',1000);
clustering_rating = S.cluster_and_rate(clustering_handle, detection_margin);
disp(sprintf("Clustering rating is %.1f%%. Elapsed %.1f sec.", [clustering_rating*100, toc]))

disp(sprintf("Total time: %.1f seconds", toc(total_timer)))
