function [max_snr, raw_p2p] = PCA_snr_filter(raw_data,spike_candidates,lib_coeff)

    max_snr = zeros(size(spike_candidates));
    raw_p2p = zeros(size(spike_candidates));
    for t = 1:length(spike_candidates)
        if spike_candidates(t)-15<1 || spike_candidates(t)+16>length(raw_data)
            max_snr(t) = 0;
            raw_p2p(t) = 0;
            continue
        end
        sample = raw_data(:,spike_candidates(t)-15:spike_candidates(t)+16);
        sample = mydetrend(single(sample)')';
        sample_norm = sqrt(sum(sample.^2,2));
        normalized_sample = sample./repmat(sample_norm,1,size(sample,2));
        pc = normalized_sample*lib_coeff;
        max_snr(t) = max(sum(pc.^2,2)./(1-sum(pc.^2,2)));
        
        raw_p2p(t) = max(max(sample,[],2)-min(sample,[],2));
    end
    
    raw_p2p = raw_p2p(:);
    max_snr = max_snr(:);
end

