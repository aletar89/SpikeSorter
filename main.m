total_timer = tic;

preprocess = @(raw_data) bandpass(double(raw_data'), [250, 6000], 20000)';
detection = @(clean_data) my_first_detector(clean_data,4.5,1.05,100);
feature_extraction = @(clean_data,spike_times) spike_energy(clean_data,spike_times, 16);
clustering = @(features) kmeans(squeeze(features)',15,'Distance', 'cityblock', 'Replicates',5, 'MaxIter',1000);

S = SpikeSorter(preprocess, detection, feature_extraction, clustering);
tic
clean_data = S.pre_process(sh1_30(:,:));
disp("Finished cleaning data")
toc
tic
spike_times = S.detection(clean_data);
disp("Finished detecting_spikes")
toc
tic
true_spike_times = res1_30(res1_30 < size(clean_data,2));
margin = 10;
detection_rating = S.test_detection(spike_times, true_spike_times, margin);
disp(sprintf("Detection rating is %.1f%%", detection_rating*100))
toc
tic
features = S.feature_extraction(clean_data, spike_times);
disp("Finished extracting features")
toc
tic
clusters = S.clustering(features);
disp("Finished clustering")
toc
tic
clustering_rating = S.test_clustering(spike_times, clusters, true_spike_times, clu1_30(1:length(true_spike_times)), margin);
clustering_rating = S.test_clustering(spike_times, clusters, spike_times, clusters2, margin);

disp(sprintf("Clustering rating is %.1f%%", clustering_rating*100))
toc
disp("Total time:")
toc(total_timer)