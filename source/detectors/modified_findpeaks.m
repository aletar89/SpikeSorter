function spike_times = modified_findpeaks(data, rms_threshold, inter_site_threshold, edge)
    if nargin==1
        rms_threshold = 4;
        inter_site_threshold = 1.05;
        edge = 100;
    end

    T = size(data,2);
    spikes = zeros(1,T);
    for i = 1:size(data,1)
        th = rms(data(i,:)) * rms_threshold;
        [pks,locs] = findpeaks(abs(data(i,:)), 'MinPeakHeight', th);
        spikes(locs) = spikes(locs) + pks;
    end
    smoothed_spikes = smooth(spikes);
    [~, spike_times] = findpeaks(smoothed_spikes);
    var = rms(data,1)./abs(mean(data,1));
    spike_times = spike_times(var(spike_times)>inter_site_threshold);
    spike_times = spike_times(spike_times>edge & spike_times<(size(data,2)-edge));
end

