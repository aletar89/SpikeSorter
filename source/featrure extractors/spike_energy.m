function [features] = spike_energy(clean_data,spike_times, half_width)
    if nargin == 2
        half_width = 16;
    end
    features = zeros(size(clean_data,1),1,length(spike_times));
    for i=1:length(spike_times)
        local_spike_shape = clean_data(:,spike_times(i)-half_width:spike_times(i)+half_width);
        features(:,1,i) = sum(abs(local_spike_shape),2);
    end
end

