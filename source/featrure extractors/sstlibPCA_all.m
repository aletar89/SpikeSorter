function features = sstlibPCA_all(data,spike_times, nPC)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
PCA = load('sst_library_PCA.mat');
features = zeros((nPC+1)*size(data,1),length(spike_times));
for i=1:length(spike_times)
    if (spike_times(i) - 15 >= 1 ) && (spike_times(i) + 16 <= size(data,2))
        all_channels = data(:,spike_times(i)-15:spike_times(i)+16);
        pc_score = all_channels * PCA.lib_coeff(:,1:nPC);
        spike_reconstruction = pc_score * PCA.lib_coeff(:,1:nPC)';
        residual = all_channels - spike_reconstruction;
        snr = sqrt(sum(spike_reconstruction.^2,2)./sum(residual.^2,2));
        features(:,i) = [pc_score(:); snr(:)];
    end
end
end

