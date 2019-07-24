function [features] = spike_energy(clean_data,spike_times, half_width)
if nargin == 2
    half_width = 16;
end
features = zeros(size(clean_data,1),length(spike_times));
for i=1:length(spike_times)
    if (spike_times(i) - half_width >= 1 ) && (spike_times(i) + half_width <= size(clean_data,2))
        local_spike_shape = clean_data(:,spike_times(i)-half_width:spike_times(i)+half_width);
        features(:,i) = sum(abs(local_spike_shape),2);
    end
end
end

