function features = haar_features(data,spike_times)
%HAAR_FEATURES Summary of this function goes here
%   Detailed explanation goes here
H = load('haar_wavelets.mat');
spike_forms = get_strongest_spikes(data, spike_times, 16);
spike_forms = spike_forms(:,2:end);
features = spike_forms * H.wavelets;
features = features';
end

