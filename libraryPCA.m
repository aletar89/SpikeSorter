half_width = 16;

D = load('data/mC41_33_shank_1.mat');
spike_times = D.true_spike_times;
data = double(D.clean_data);
spike_forms1 = get_strongest_spikes(data, spike_times, half_width);

D = load('data/mC41_33_shank_2.mat');
spike_times = D.true_spike_times;
data = double(D.clean_data);
spike_forms2 = get_strongest_spikes(data, spike_times, half_width);

all_spike_forms = [spike_forms1; spike_forms2];
[coeff,score,~,~,~,mu] = pca(all_spike_forms);

save('libraryPCA.mat','coeff','mu')