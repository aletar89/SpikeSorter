total_timer = tic;
addpath(genpath('source'))
disp("Start")
tic
if ~exist('D', 'var')
    D = load('data/mC41_33_shank_1.mat');
end

last_data_ind = round(size(D.clean_data,2)*0.8);
data = double(D.clean_data(:,1:last_data_ind));
true_spike_times = D.true_spike_times(D.true_spike_times < last_data_ind);
true_clusters = D.true_clusters(1:length(true_spike_times));
all_spike_times = D.all_spike_times(D.all_spike_times < last_data_ind);
all_clusters = D.all_clusters(1:length(all_spike_times));
S = SpikeSorter(data, true_spike_times, true_clusters);
disp(sprintf("Finished loading data. Elapsed %.1f sec.", toc))
%pre_process_handle = @(raw_data) bandpass(double(raw_data'), [250, 6000], 20000)';
S.pre_process(@(x)x);

tic
detection_margin = 10; %samples to each side
%detection_handle = @(clean_data) modified_findpeaks(clean_data,4.5,1.05,100);
%detection_handle = @(clean_data) NEO(clean_data,18E4,1.05,100);
%detection_handle = @(clean_data) NEO_max_min(clean_data,18E4,600,100);
detection_handle = @(clean_data) S.true_spike_times;       % Oracle
detection_rating = S.detect_and_rate(detection_handle, detection_margin);
disp(sprintf("Detection rating is %.1f%% compared to good units. Elapsed %.1f sec.", [detection_rating*100, toc]))
no_noise_times = all_spike_times(all_clusters ~= 0 & all_clusters ~= 1);
detection_rating2 = S.rate_detection(S.test_spike_times, no_noise_times, detection_margin);
disp(sprintf("Detection rating is %.1f%% compared to all units.", detection_rating2*100))


tic
%feature_extraction_handle = @(clean_data,spike_times) spike_energy(clean_data,spike_times, 16);
%feature_extraction_handle = @(clean_data,spike_times) FSDE(clean_data,spike_times, 16);
feature_extraction_handle = @(clean_data,spike_times) libPCA(clean_data,spike_times,10, 16);
S.extract_features(feature_extraction_handle);
disp(sprintf("Finished extracting features. Elapsed %.1f sec.", toc))

tic
clustering_handle = @(features) kmeans(features',3, 'Replicates',5, 'MaxIter',1000);
% merge_thresh = 80;
% history = 10;
% max_clusters = 30;
% clustering_handle = @(features) OSort(features, merge_thresh, history, max_clusters);
clustering_rating = S.cluster_and_rate(clustering_handle, detection_margin);
disp(sprintf("Clustering rating is %.1f%%. Elapsed %.1f sec.", [clustering_rating*100, toc]))

display_clustering(S.clean_data, S.test_spike_times, S.features, S.test_clusters,16);

disp(sprintf("Total time: %.1f seconds", toc(total_timer)))