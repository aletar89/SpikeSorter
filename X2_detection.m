function [X2_train_detections,X2_test_detections, X2_train, X2_test] = X2_detection(raw_train_data,raw_test_data)


N_electrodes = size(raw_train_data,1);

% modified second derivative handle
minus_d = 6; plus_d = 9;
mod2der_func = @(data) single([zeros(N_electrodes,minus_d),...
    (-0.5)*data(:,1:end-(minus_d+plus_d))+...
    data(:,minus_d+1:end-plus_d)+...
    (-0.5)*data(:,minus_d+plus_d+1:end),...
    zeros(N_electrodes,plus_d)]);
% detection handle
detection_func = @(data, threshold) find(any([false(N_electrodes,1),...
    abs(data(:,2:end-1))>abs(data(:,1:end-2))&...
    abs(data(:,2:end-1))>abs(data(:,3:end))&...
    abs(data(:,2:end-1))>repmat(threshold,1,size(data,2)-2),...
    false(N_electrodes,1)]));

X2_train = mod2der_func(raw_train_data);
X2_test = mod2der_func(raw_test_data);

detection_threshold = 4;
X2_threshold = zeros(N_electrodes,1);
for e = 1:N_electrodes
    X2_threshold(e) = detection_threshold * std(X2_train(e,X2_train(e,:)<detection_threshold * std(X2_train(e,:))));
end

X2_train_detections = realign_detections(raw_train_data, detection_func(X2_train, X2_threshold));
X2_test_detections = realign_detections(raw_test_data, detection_func(X2_test, X2_threshold));
end

