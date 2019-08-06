function spike_times = NEO_max_min(data, threshold, inter_site_threshold, edge)
    if nargin==1
        threshold = 18E4;
        inter_site_threshold =350;
        edge = 100;
    end
    
    zero_column = zeros(size(data,1),1);
    NEO_of_data = [zero_column data(:,2:end-1).^2 - data(:,1:end-2).*data(:,3:end) zero_column];
    mNEO = max(NEO_of_data);
    [~,spike_times] = findpeaks(mNEO, 'MinPeakHeight', threshold);
    var = max(data,[],1)-min(data,[],1);
    spike_times = spike_times(var(spike_times)>inter_site_threshold);
%     min_var = 690E5./(mNEO(spike_times)) + 176;
%     spike_times = spike_times(var(spike_times)>min_var);
    spike_times = spike_times(spike_times>edge & spike_times<(size(data,2)-edge));
    spike_times = spike_times(:);
end