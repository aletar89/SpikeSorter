function [good_detections] = realign_detections(data,spike_times)
%REALIGN_DETECTIONS aligns the detections to the minimum of the channel
%with largest max-min in middle 17 samples
dead_time = 8; % samples;
good_detections = nan(size(spike_times));
good_ind = 1;
old_ind = 1;
while old_ind<length(spike_times)
    % disp(old_ind/length(spike_times)*100)
    if spike_times(old_ind)-15 < 1 || spike_times(old_ind)+16 > size(data,2)
        old_ind = old_ind + 1;
        continue
    end
    raw_sample = data(:,spike_times(old_ind)-15:spike_times(old_ind)+16);
    detrended_sample = mydetrend(raw_sample')';
    sample = detrended_sample(:,16-dead_time/2:16+dead_time/2);
    p2p = max(sample,[],2)-min(sample,[],2);
    [~,strongest_channel] = max(p2p);
    strongest_spike = sample(strongest_channel,:);
    extremum = find([false, abs(strongest_spike(2:end-1))>abs(strongest_spike(1:end-2))&abs(strongest_spike(2:end-1))>abs(strongest_spike(3:end)), false]);
    [~, ind] = max(abs(strongest_spike(extremum)));
    new_spike_time = spike_times(old_ind) + extremum(ind) - dead_time/2 - 1;
    if isempty(new_spike_time)
        [~, ind] = max(abs(strongest_spike));
        new_spike_time = spike_times(old_ind) + ind - dead_time/2 - 1;
    end
    if 0 && good_ind>1 && abs(new_spike_time - good_detections(good_ind-1))<8
        plot_sh(detrended_sample)
        title(16+new_spike_time - spike_times(old_ind))
        9;
    end
    good_detections(good_ind) = new_spike_time;
    old_ind = find(spike_times > spike_times(old_ind) + dead_time,1);
    good_ind = good_ind + 1;
end
good_detections(isnan(good_detections)) = [];
good_detections(good_detections-15<1 | good_detections+16 > size(data,2)) = [];
end

