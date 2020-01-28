function [new_spike_times] = realign_ground_truth(data,spike_times)
%REALIGN_GROUND_TRUTH Summary of this function goes here
%   Detailed explanation goes here
dead_time = 8;
new_spike_times = spike_times;
for i = 1:length(spike_times)
    if spike_times(i)-15<1 || spike_times(i)+16> size(data,2)
        continue
    end
    raw_sample = data(:,spike_times(i)-15:spike_times(i)+16);
    detrended_sample = mydetrend(raw_sample')';
    if i>1 && new_spike_times(i)-new_spike_times(i-1) < 2*dead_time
        from_ind = 16 - (new_spike_times(i)-new_spike_times(i-1)-dead_time+1);
        if 0
            plot_sh(detrended_sample);
            title(from_ind)
            9;
        end
    else
        from_ind = 16 - dead_time;
    end
    sample = detrended_sample(:,from_ind:16+dead_time);
    p2p = max(sample,[],2)-min(sample,[],2);
    [~,strongest_channel] = max(p2p);
    strongest_spike = sample(strongest_channel,:);
    extremum = find([false, abs(strongest_spike(2:end-1))>abs(strongest_spike(1:end-2))&abs(strongest_spike(2:end-1))>abs(strongest_spike(3:end)), false]);
    [~, ind] = max(abs(strongest_spike(extremum)));
    new_spike_time = spike_times(i) + extremum(ind) - (16-from_ind) - 1;
    if isempty(new_spike_time)
        [~, ind] = max(abs(strongest_spike));
        new_spike_time = spike_times(i) + ind - (16-from_ind) - 1;
    end
    new_spike_times(i) = new_spike_time;
    if 0 && abs(new_spike_times(i) - spike_times(i))>2
        raw_sample = data(:,new_spike_times(i)-15:new_spike_times(i)+16);
        detrended_sample = mydetrend(raw_sample')';
        plot_sh(detrended_sample)
        title(new_spike_times(i) - spike_times(i));
        9;
    end
end
end

