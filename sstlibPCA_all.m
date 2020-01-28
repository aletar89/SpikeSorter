function features = sstlibPCA_all(data,spike_times, nPC)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
PCA = load('sst_library_PCA.mat');
lib_coeff = PCA.lib_coeff(:,1:nPC);
features = zeros(nPC*size(data,1),length(spike_times));
for i=1:length(spike_times)
    if (spike_times(i) - 15 >= 1 ) && (spike_times(i) + 16 <= size(data,2))
        sample = data(:,spike_times(i)-15:spike_times(i)+16);
        sample = mydetrend(single(sample)')';
        pc_score = sample*lib_coeff;
        signal_norm = sum(sample.^2,2);
        residual = sqrt(signal_norm-sum(pc_score.^2,2));
        features(:,i) = pc_score(:);
    end
end
end

