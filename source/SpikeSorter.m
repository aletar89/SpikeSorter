classdef SpikeSorter < handle
    %SPIKESORTER Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        pre_process_function
        detection_function
        feature_extraction_function
        clustering_function
        raw_data
        true_spike_times
        true_clusters
        clean_data
        test_spike_times
        features
        test_clusters
    end
    
    methods
        %Class construction function:
        function obj = SpikeSorter(raw_data,true_spike_times, true_clusters)
            %SPIKESORTER Construct an instance of this class
            %   Assign the function handles to the class properties
            obj.raw_data = raw_data;
            obj.true_spike_times = true_spike_times;
            obj.true_clusters = true_clusters;
        end
        
        %Spike sorting process fuctions:
        function pre_process(obj, pre_process_handle)
            obj.pre_process_function = pre_process_handle;
            obj.clean_data = obj.pre_process_function(obj.raw_data);
        end
        function rating = detect_and_rate(obj, detection_handle, margin)
            obj.detection_function = detection_handle;
            obj.test_spike_times = obj.detection_function(obj.clean_data);
            rating = obj.rate_detection(obj.test_spike_times, obj.true_spike_times, margin);
        end
        function extract_features(obj, feature_extraction_handle)
            obj.feature_extraction_function = feature_extraction_handle;
            obj.features = obj.feature_extraction_function(obj.clean_data, obj.test_spike_times);
        end
        function rating = cluster_and_rate(obj, clustering_handle, margin)
            obj.clustering_function = clustering_handle;
            obj.test_clusters = obj.clustering_function(obj.features);
            rating = obj.rate_clustering(obj.test_spike_times, obj.test_clusters, obj.true_spike_times, obj.true_clusters, margin);
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
        function rating = rate_detection(obj, detected_times, ground_truth_times, margin)
            gt_times = obj.mutual_times(detected_times, ground_truth_times, margin);
            TP = sum(gt_times);
            rating = TP/(numel(detected_times)+numel(ground_truth_times) - TP);
        end
        function rating = rate_clustering(obj, detected_times, calculated_clusters, ground_truth_times, ground_truth_clusters, margin)
            [gt_times, det_times] = obj.mutual_times(detected_times, ground_truth_times, margin);
            [~,~, mutual_calculated_clusters] = unique(calculated_clusters(det_times));
            [~,~, mutual_ground_truth_clusters] = unique(ground_truth_clusters(gt_times));
            rating = RandIndex(mutual_calculated_clusters, mutual_ground_truth_clusters);
        end
    end
end

