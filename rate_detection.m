function [rating] = rate_detection(detected_times, ground_truth_times, margin)
[gt_times, det_times] = mutual_times(detected_times, ground_truth_times, margin);
TP = sum(det_times);
FP = sum(~det_times);
FN = sum(~gt_times);
F1 = 2*TP/(2*TP + FP + FN);
FNR = FN./(FN + TP);
FPR = FP./(FP + TP);
if isnan(FPR)
    FPR = 0;
end

rating = struct('TP', TP, 'FP', FP, 'FN', FN, 'F1', F1, 'FNR', FNR, 'FPR', FPR,...
    'gt_times', gt_times, 'det_times', det_times);
end