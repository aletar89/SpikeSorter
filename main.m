total_timer = tic;
addpath(genpath('source'))
disp("Start")
tic
data_name = 'mC41_33';
shank = 1;
file_name = sprintf("data/%s/%s_shank_%d.mat",data_name,data_name, shank);
if ~exist('D', 'var') || ~strcmp(D.data_name, data_name) || D.shank ~= shank
    D = load(file_name);
    D.data_name = data_name;
    D.shank = shank;
    D.cluster_quality = logical(D.cluster_quality);
end

last_data_ind = round(size(D.clean_data,2)*0.8);
S = SpikeSorter(D, last_data_ind);
disp(sprintf("Finished loading data. Elapsed %.1f sec.", toc))


%detection_handle = @(clean_data) modified_findpeaks(clean_data,4.5,1.05,100);
%detection_handle = @(clean_data) NEO(clean_data,18E4,100);
detection_handle = @(clean_data) NEOvar(clean_data,18E4,1.05,100);
%detection_handle = @(clean_data) NEO_max_min(clean_data,18E4,600,100);
detection_handle = @(clean_data) S.spike_times.c;       % Oracle
S.detect_and_rate(detection_handle);


%feature_extraction_handle = @(clean_data,spike_times) spike_energy(clean_data,spike_times, 16);
%feature_extraction_handle = @(clean_data,spike_times) FSDE(clean_data,spike_times, 16);
%feature_extraction_handle = @(clean_data,spike_times) libPCA(clean_data,spike_times,10, 16);
%feature_extraction_handle = @(clean_data,spike_times) libPCA_pos(clean_data,spike_times,3, 16);
%feature_extraction_handle = @(clean_data,spike_times) libPCA_all(clean_data,spike_times,3, 16);
feature_extraction_handle = @(clean_data,spike_times) sstlibPCA_all(clean_data,spike_times,3);
%feature_extraction_handle = @(clean_data,spike_times) haar_features(clean_data,spike_times);
%feature_extraction_handle = @(clean_data,spike_times) haar_all(clean_data,spike_times);

S.extract_features(feature_extraction_handle);

clustering_handle = @(features) kmeans(features',5, 'Replicates',5, 'MaxIter',1000);
% merge_thresh = 100;
% history = 10;
% max_clusters = 30;
% clustering_handle = @(features) OSort(features, merge_thresh, history, max_clusters);
S.cluster_and_rate(clustering_handle);

display_clustering(S.clean_data, S.spike_times.test, S.features, S.clusters.test,16);

disp(sprintf("Total time: %.1f seconds", toc(total_timer)))