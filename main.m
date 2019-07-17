total_timer = tic;
addpath('source')
disp("Start")
tic
raw_data = load('data/mC41_33/sh1_30.mat'); raw_data = raw_data.sh1_30;
true_spike_times = load('data/mC41_33/res1_30.mat'); true_spike_times = true_spike_times.res1_30;
true_clusters = load('data/mC41_33/clu1_30.mat'); true_clusters = true_clusters.clu1_30;

last_data_ind = round(size(raw_data,2)/10);
raw_data = raw_data(:,1:last_data_ind);
true_spike_times = true_spike_times(true_spike_times < last_data_ind);
true_clusters = true_clusters(1:length(true_spike_times));

preprocess = @(raw_data) bandpass(double(raw_data'), [250, 6000], 20000)';
detection = @(clean_data) my_first_detector(clean_data,4.5,1.05,100);
feature_extraction = @(clean_data,spike_times) spike_energy(clean_data,spike_times, 16);
clustering = @(features) kmeans(squeeze(features)',15,'Distance', 'cityblock', 'Replicates',5, 'MaxIter',1000);

S = SpikeSorter(preprocess, detection, feature_extraction, clustering);
disp("Finished loading data"), toc

tic
clean_data = S.pre_process(raw_data);
disp("Finished cleaning data"), toc

tic
spike_times = S.detection(clean_data);
disp("Finished detecting_spikes"), toc

tic
margin = 10;
detection_rating = S.test_detection(spike_times, true_spike_times, margin);
disp(sprintf("Detection rating is %.1f%%", detection_rating*100)), toc

tic
features = S.feature_extraction(clean_data, spike_times);
disp("Finished extracting features"), toc

tic
clusters = S.clustering(features);
disp("Finished clustering"), toc

tic
clustering_rating = S.test_clustering(spike_times, clusters, true_spike_times, true_clusters, margin);
disp(sprintf("Clustering rating is %.1f%%", clustering_rating*100)), toc

disp(sprintf("Total time: %.2f seconds", toc(total_timer)))
