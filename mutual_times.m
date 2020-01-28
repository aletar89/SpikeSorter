function [gt_times, det_times] = mutual_times(detected_times, ground_truth_times, margin)
detected_times = detected_times(:);
ground_truth_times = ground_truth_times(:);
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