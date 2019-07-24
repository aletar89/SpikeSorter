function features = libPCA(data,spike_times, nPC, half_width)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
if nargin == 3
    half_width = 16;
end
load('libraryPCA.mat','library_pca')
features = zeros(nPC*size(data,1),length(spike_times));
for i=1:length(spike_times)
    if (spike_times(i) - half_width >= 1 ) && (spike_times(i) + half_width <= size(data,2))
        local_spike_shape = data(:,spike_times(i)-half_width:spike_times(i)+half_width);
        local_features = local_spike_shape * library_pca(:,1:nPC);
        features(:,i) = local_features(:);
    end
end
end

