function features = libPCA_pos(data,spike_times, nPC, half_width)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
if nargin == 3
    half_width = 16;
end
PCA = load('libraryPCA.mat');
features = zeros(nPC+2,length(spike_times));
for i=1:length(spike_times)
    if (spike_times(i) - half_width >= 1 ) && (spike_times(i) + half_width <= size(data,2))
        all_channels = data(:,spike_times(i)-half_width:spike_times(i)+half_width);
        channel_max = max(abs(all_channels),[],2);
        [~, channel_of_max] = max(channel_max);
        best_spike_form = all_channels(channel_of_max,:);
        local_pca = (best_spike_form - PCA.mu) * PCA.coeff(:,1:nPC);
        channels = 1:10;
        pos = (channels * channel_max)/sum(channel_max);
        spread = sqrt(sum(    (channels-pos*ones(size(channels))).^2.*channel_max'    )/(sum(channel_max)-1));
        features(:,i) = [local_pca(:); pos; spread];
    end
end
end

