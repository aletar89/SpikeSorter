function features = haar_all(data,spike_times)
%HAAR_FEATURES Summary of this function goes here
%   Detailed explanation goes here
H = load('haar_wavelets.mat');
features = zeros(size(H.wavelets,2)*size(data,1),length(spike_times));
for i=1:length(spike_times)
    if (spike_times(i) - 15 >= 1 ) && (spike_times(i) + 16 <= size(data,2))
        all_channels = data(:,spike_times(i)-15:spike_times(i)+16);
        local_features = all_channels * H.wavelets;
        features(:,i) = local_features(:);
    end
end
end

