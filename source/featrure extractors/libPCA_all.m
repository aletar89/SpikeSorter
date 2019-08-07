function features = libPCA_all(data,spike_times, nPC, half_width)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
if nargin == 3
    half_width = 16;
end
PCA = load('libraryPCA.mat');
features = zeros(nPC*size(data,1),length(spike_times));
for i=1:length(spike_times)
    if (spike_times(i) - half_width >= 1 ) && (spike_times(i) + half_width <= size(data,2))
        all_channels = data(:,spike_times(i)-half_width:spike_times(i)+half_width);
        local_features = (all_channels - repmat(PCA.mu,size(all_channels,1),1)) * PCA.coeff(:,1:nPC);
        features(:,i) = local_features(:);
    end
end
end

