function features = FSDE(data,spike_times)
zero_column = zeros(size(data,1),1);
features = zeros(size(data,1)*3,length(spike_times));
for i=1:length(spike_times)
    if (spike_times(i) - 15 >= 1 ) && (spike_times(i) + 16 <= size(data,2))
        sample = data(:,spike_times(i)-15:spike_times(i)+16);
        sample = mydetrend(single(sample)')';
        FD = [zero_column, diff(sample, 1, 2)];
        SD = [zero_column, diff(sample, 2, 2) ,zero_column];
        FDmax = max(FD,[],2);
        SDmax = max(SD,[],2);
        SDmin = min(SD,[],2);
        features(:,i) = [FDmax; SDmax; SDmin];
    end
end
end

