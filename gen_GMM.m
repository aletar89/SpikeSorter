function [cluster_ids, means, prescisions] = gen_GMM(clusters, features)
all_uniques = unique(clusters);
cluster_ids = [];
for i=1:length(all_uniques) %drop clusters with less spikes than there are features
        if sum(clusters==all_uniques(i)) > size(features,1)
            cluster_ids = [cluster_ids, all_uniques(i)];
        end
end
means = zeros(size(features,1),length(cluster_ids));
prescisions = zeros(size(features,1), size(features,1), length(cluster_ids));

for i = 1:length(cluster_ids)
    means(:,i) = mean(features(:,clusters == cluster_ids(i)),2);
    prescisions(:,:,i) = inv(cov(features(:,clusters == cluster_ids(i))'));
end
end

