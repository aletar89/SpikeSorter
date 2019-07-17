classdef SpikeSorter
    %SPIKESORTER Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        pre_process_function
        detection_function
        feature_extraction_function
        clustering_function
    end
    
    methods
        function obj = SpikeSorter(pre_process_handle,detection_handle, feature_extraction_handle, clustering_handle)
            %SPIKESORTER Construct an instance of this class
            %   Assign the function handles to the class properties
            obj.pre_process_function = pre_process_handle;
            obj.detection_function = detection_handle;
            obj.feature_extraction_function = feature_extraction_handle;
            obj.clustering_function = clustering_handle;
        end
     
        function clean_data = pre_process(obj,raw_data)
            clean_data = obj.pre_process_function(raw_data);
        end
        function spike_times = detection(obj,clean_data)
            spike_times = obj.detection_function(clean_data);
        end
        function features = feature_extraction(obj,clean_data, spike_times)
            features = obj.feature_extraction_function(clean_data, spike_times);
        end
        function clusters = clustering(obj,features)
            clusters = obj.clustering_function(features);
        end
        
        function [spike_times, clusters] = run(obj, raw_data)
            clean_data = obj.pre_process(raw_data);
            spike_times = obj.detection(clean_data);
            features = obj.feature_extraction(clean_data, spike_times);
            clusters = obj.clustering(features);
        end
        
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
        
        function rating = test_detection(obj, detected_times, ground_truth_times, margin)
            gt_times = obj.mutual_times(detected_times, ground_truth_times, margin);
            TP = sum(gt_times);
            rating = TP/(numel(detected_times)+numel(ground_truth_times) - TP);
        end
        
        function mat = same_cluster_matrix(obj, clusters)
            clusters = clusters(:);
            repeat_clusters = repmat(clusters,1,length(clusters));
            mat = (repeat_clusters == repeat_clusters');
        end
        
        function rating = test_clustering(obj, detected_times, calculated_clusters, ground_truth_times, ground_truth_clusters, margin)
            [gt_times, det_times] = obj.mutual_times(detected_times, ground_truth_times, margin);
            [~,~, mutual_calculated_clusters] = unique(calculated_clusters(det_times));
            [~,~, mutual_ground_truth_clusters] = unique(ground_truth_clusters(gt_times));
            rating = RandIndex(mutual_calculated_clusters, mutual_ground_truth_clusters);
        end
    end
end

