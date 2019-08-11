classdef SpikeSorter < handle
    %SPIKESORTER Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        pre_process_function
        detection_function
        feature_extraction_function
        clustering_function
        spike_times
        clusters
        clean_data
        features
        detection_rating
        clustering_rating
    end
    
    methods
        %Class construction function:
        function obj = SpikeSorter(D, last_data_ind)
            %SPIKESORTER Construct an instance of this class
            %   Assign the function handles to the class properties
            obj.clean_data = double(D.clean_data(:,1:last_data_ind));
            all_clusters = D.all_clusters(D.all_spike_times<last_data_ind);
            all_spike_times = D.all_spike_times(D.all_spike_times<last_data_ind);
            cluster_quality = D.cluster_quality(D.all_spike_times<last_data_ind,:);
            obj.spike_times = struct('all', all_spike_times,...
                'b', all_spike_times(cluster_quality(:,1)),...
                'c', all_spike_times(cluster_quality(:,2)),...
                'd', all_spike_times(cluster_quality(:,3)),...
                'test',[]);
            obj.clusters = struct('all', all_clusters,...
                'b', all_clusters(cluster_quality(:,1)),...
                'c', all_clusters(cluster_quality(:,2)),...
                'd', all_clusters(cluster_quality(:,3)),...
                'test',[]);
        end
        
        %Spike sorting process fuctions:
        function detect_and_rate(obj, detection_handle, margin)
            if nargin<3
                margin = 10;
            end
            tic
            obj.detection_function = detection_handle;
            obj.spike_times.test = obj.detection_function(obj.clean_data);
            rating_b = obj.rate_detection(obj.spike_times.test, obj.spike_times.b, margin);
            rating_c = obj.rate_detection(obj.spike_times.test, obj.spike_times.c, margin);
            rating_d = obj.rate_detection(obj.spike_times.test, obj.spike_times.d, margin);
            obj.detection_rating = struct('b',rating_b, 'c', rating_c, 'd', rating_d);
            disp(sprintf("Detection rating is [b: %.1f%%, c:%.1f%%, d:%.1f%%]. Elapsed %.1f sec.",...
                [rating_b.F1*100, rating_c.F1*100, rating_d.F1*100, toc]))
        end
        function extract_features(obj, feature_extraction_handle)
            tic
            obj.feature_extraction_function = feature_extraction_handle;
            obj.features = obj.feature_extraction_function(obj.clean_data, obj.spike_times.test);
            disp(sprintf("Finished extracting features. Elapsed %.1f sec.", toc))
        end
        function cluster_and_rate(obj, clustering_handle, margin)
            if nargin<3
                margin = 10;
            end
            tic
            obj.clustering_function = clustering_handle;
            obj.clusters.test = obj.clustering_function(obj.features);
            result_b = obj.rate_clustering(obj.spike_times.test, obj.clusters.test, obj.spike_times.b, obj.clusters.b, margin);
            result_c = obj.rate_clustering(obj.spike_times.test, obj.clusters.test, obj.spike_times.c, obj.clusters.c, margin);
            result_d =  obj.rate_clustering(obj.spike_times.test, obj.clusters.test, obj.spike_times.d, obj.clusters.d, margin);
            obj.clustering_rating = struct('b',result_b, 'c', result_c, 'd', result_d);
            
            disp(sprintf("Clustering rating is [b: %.1f%%, c:%.1f%%, d:%.1f%%]. Elapsed %.1f sec.",...
                [result_b.rating*100, result_c.rating*100, result_d.rating*100, toc]))
        end
        
        %Internal functions
        function [gt_times, det_times] = mutual_times(obj, detected_times, ground_truth_times, margin)
            lags = [0, reshape([1:margin;-1:-1:-margin], 1, [])];  % = 0, 1, -1, 2, -2, ... , margin, -margin
            gt_times = false(size(ground_truth_times));
            det_times = false(size(detected_times));
            for lag = lags
                [~,ia,ib] = intersect(ground_truth_times, detected_times + lag);
                untouched = (gt_times(ia) == 0 & det_times(ib) == 0);
                gt_times(ia) = gt_times(ia) | untouched;
                det_times(ib) =  det_times(ib) | untouched;
            end
        end
        function [rating] = rate_detection(obj, detected_times, ground_truth_times, margin)
            [gt_times, det_times] = obj.mutual_times(detected_times, ground_truth_times, margin);
            TP = sum(det_times);
            FP = sum(~det_times);
            FN = sum(~gt_times);
            F1 = 2*TP/(2*TP + FP + FN);
            rating = struct('TP', TP, 'FP', FP, 'FN', FN, 'F1', F1);
        end
        function result = rate_clustering(obj, detected_times, calculated_clusters, ground_truth_times, ground_truth_clusters, margin)
            [gt_times, det_times] = obj.mutual_times(detected_times, ground_truth_times, margin);
            [~,~, mutual_calculated_clusters] = unique(calculated_clusters(det_times));
            [~,~, mutual_ground_truth_clusters] = unique(ground_truth_clusters(gt_times));
            rating = RandIndex(mutual_calculated_clusters, mutual_ground_truth_clusters);
            confusion = obj.clusterconfusion(ground_truth_clusters(gt_times), calculated_clusters(det_times));
            result = struct('rating', rating, 'confusion', confusion);
        end
        function C = clusterconfusion(obj,true_clusters, test_clusters )
            unique_true = unique(true_clusters);
            unique_test = unique(test_clusters);
            C = zeros(length(unique_true),length(unique_test));
            for i = 1:length(unique_true)
                for j = 1:length(unique_test)
                    C(i,j) = sum(true_clusters == unique_true(i) & test_clusters == unique_test(j));
                end
            end
        end
    end
end

