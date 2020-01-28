function C = clusterconfusion(true_clusters, test_clusters )
true_clusters = true_clusters(:);
test_clusters = test_clusters(:);
unique_true = unique(true_clusters);
unique_test = unique(test_clusters);
C = zeros(length(unique_true),length(unique_test));
for i = 1:length(unique_true)
    for j = 1:length(unique_test)
        C(i,j) = sum(true_clusters == unique_true(i) & test_clusters == unique_test(j));
    end
end
end