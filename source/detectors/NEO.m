function spike_times = NEO(data, threshold, edge)
    if nargin==1
        threshold = 2E4;
        edge = 100;
    end

    zero_column = zeros(size(data,1),1);
    NEO_of_data = [zero_column data(:,2:end-1).^2 - data(:,1:end-2).*data(:,3:end) zero_column];
    mNEO = max(NEO_of_data);
    [~,spike_times] = findpeaks(mNEO, 'MinPeakHeight', threshold);
    spike_times = spike_times(spike_times>edge & spike_times<(size(data,2)-edge));
    spike_times = spike_times(:);
end

