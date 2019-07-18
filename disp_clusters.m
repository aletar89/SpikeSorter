half_width = 16;
spike_forms = zeros(size(S.clean_data,1), 2*half_width + 1, length(true_spike_times));
for i=1:length(true_spike_times)
    spike_forms(:,:,i) = S.clean_data(:,true_spike_times(i)-half_width:true_spike_times(i)+half_width);
end
for c = unique(true_clusters)'
    clf
    class_spikes = spike_forms(:,:,true_clusters == c);
    for i = 1:size(class_spikes,3)
        plot_sh(class_spikes(:,:,i))
        hold on
    end
    title(c)
end