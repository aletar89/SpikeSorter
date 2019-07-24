total_timer = tic;
addpath(genpath('source'))
disp("Start")
tic
if ~exist('D', 'var')
    D = load('data/mC41_33_shank_2.mat');
end

last_data_ind = round(size(D.clean_data,2)*0.1);
data = double(D.clean_data(:,1:last_data_ind));
true_spike_times = D.true_spike_times(D.true_spike_times < last_data_ind);
true_clusters = D.true_clusters(1:length(true_spike_times));
S = SpikeSorter(data, true_spike_times, true_clusters);
disp(sprintf("Finished loading data. Elapsed %.1f sec.", toc))
%pre_process_handle = @(raw_data) bandpass(double(raw_data'), [250, 6000], 20000)';
S.pre_process(@(x)x);

tic
detection_margin = 10; %samples to each side
detection_handle = @(clean_data) modified_findpeaks(clean_data,4.5,1.05,100);
detection_rating = S.detect_and_rate(detection_handle, detection_margin);
disp(sprintf("Detection rating is %.1f%%. Elapsed %.1f sec.", [detection_rating*100, toc]))

if detection_rating<0.8
    S.test_spike_times = S.true_spike_times;
end

tic
%feature_extraction_handle = @(clean_data,spike_times) spike_energy(clean_data,spike_times, 16);
feature_extraction_handle = @(clean_data,spike_times) FSDE(clean_data,spike_times, 16);
%feature_extraction_handle = @(clean_data,spike_times) libPCA(clean_data,spike_times,3, 16);
S.extract_features(feature_extraction_handle);
disp(sprintf("Finished extracting features. Elapsed %.1f sec.", toc))

tic
clustering_handle = @(features) kmeans(features',2, 'Replicates',5, 'MaxIter',1000);
clustering_rating = S.cluster_and_rate(clustering_handle, detection_margin);
disp(sprintf("Clustering rating is %.1f%%. Elapsed %.1f sec.", [clustering_rating*100, toc]))

display_clustering(S.clean_data, S.test_spike_times, S.features, S.test_clusters,16);

disp(sprintf("Total time: %.1f seconds", toc(total_timer)))

display_clustering(S.clean_data, S.true_spike_times, [], S.true_clusters,16);


large_clusters_ind = D.true_clusters==9 | D.true_clusters==15 | ...
    D.true_clusters==18 | D.true_clusters==20 | D.true_clusters==21;
large_clusters = D.true_clusters(large_clusters_ind);
large_spike_times = D.true_spike_times(large_clusters_ind);

display_clustering(S.clean_data,large_spike_times, [], large_clusters,16);
