function [clusters, dists] = given_means(features, means, prescisions)
number_of_means = size(prescisions,3);
dists = zeros(number_of_means,size(features,2));
for i = 1:number_of_means
    y_m = features-repmat(means(:,i),1,size(features,2));
    dists(i,:) = sum(y_m .* (prescisions(:,:,i) * y_m));
end
[min_dist, clusters] = min(dists,[],1);
% in_thresh = dists < repmat(thresholds(:),1,size(dists,2));
%clusters(min_dist>60) = 0;
clusters = clusters(:);
end

