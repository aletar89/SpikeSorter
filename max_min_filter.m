function [maxmin] = max_min_filter(X2,spike_candidates)
    peak_max = max(abs(X2(:,spike_candidates)));
    peak_min = min(abs(X2(:,spike_candidates)));
    maxmin = (peak_max - peak_min)./(peak_max + peak_min);
    maxmin = maxmin(:);
end

