function features = libPCA(data,spike_times, nPC, half_width)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
if nargin == 3
    half_width = 16;
end
PCA = load('libraryPCA.mat');
features = zeros(nPC,length(spike_times));
for i=1:length(spike_times)
    if (spike_times(i) - half_width >= 1 ) && (spike_times(i) + half_width <= size(data,2))
        all_channels = data(:,spike_times(i)-half_width:spike_times(i)+half_width);
        [sample_max,channel_of_max] = max(abs(all_channels));
        [~, sample_of_max] = max(sample_max);
        best_spike_form = all_channels(channel_of_max(sample_of_max),:);
        local_features = (best_spike_form - PCA.mu) * PCA.coeff(:,1:nPC);
        features(:,i) = local_features(:);
    end
end
end

