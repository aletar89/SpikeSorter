function [features] = calc_features(raw_data, X2,X2_detections,lib_coeff, nPC, nbits)
%CALC_FEATURES Summary of this function goes here
%   Detailed explanation goes here
X2_abs = max(abs(X2(:,X2_detections))); X2_abs = X2_abs(:);
maxmin = max_min_filter(X2,X2_detections);

lib_coeff_quant = quantize(quantizer('mode','fixed','roundmode','Round','overflowmode','saturate','format',...
    [nbits nbits-1]),lib_coeff);
[max_snr, raw_p2p] = PCA_snr_filter(raw_data,X2_detections,lib_coeff_quant(:,1:nPC));

features = table(maxmin, raw_p2p, X2_abs, max_snr);
end

