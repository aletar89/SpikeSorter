function features = FSDE(clean_data,spike_times, half_width)
zero_column = zeros(size(clean_data,1),1);
FD = [zero_column, diff(clean_data, 1, 2)];
SD = [zero_column, diff(clean_data, 2, 2) ,zero_column];
if nargin == 2
    half_width = 16;
end
features = zeros(size(clean_data,1)*3,length(spike_times));
for i=1:length(spike_times)
    if (spike_times(i) - half_width >= 1 ) && (spike_times(i) + half_width <= size(clean_data,2))
        local_FD = FD(:,spike_times(i)-half_width:spike_times(i)+half_width);
        local_SD = SD(:,spike_times(i)-half_width:spike_times(i)+half_width);
        FDmax = max(local_FD,[],2);
        SDmax = max(local_SD,[],2);
        SDmin = min(local_SD,[],2);
        features(:,i) = [FDmax; SDmax; SDmin];
    end
end
end

