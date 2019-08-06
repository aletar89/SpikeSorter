function spike_forms = get_strongest_spikes(data, spike_times, half_width)
spike_forms = zeros(length(spike_times), half_width*2+1);
for i=1:length(spike_times)
    all_channels = data(:,spike_times(i)-half_width:spike_times(i)+half_width);
    [sample_max,channel_of_max] = max(abs(all_channels));
    [~, sample_of_max] = max(sample_max);
    best_spike_form = all_channels(channel_of_max(sample_of_max),:);
    spike_forms(i,:) = best_spike_form;
end
end