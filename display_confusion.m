function display_confusion(C, true_cluster_ids, test_cluster_ids)
figure
subplot(1,4,1)
imagesc(C)
colormap('jet')
colorbar
xlabel('Test Clusters')
ylabel('True Clusters')
xticks(1:size(C,2))
xticklabels(test_cluster_ids)
yticks(1:size(C,1))
yticklabels(true_cluster_ids)
title('Number Of Spikes')
set(gca,'position',[0.0300    0.1039    0.20    0.7536]);

C_test = C./repmat(sum(C,1),size(C,1),1)*100;
subplot(1,4,2)
imagesc(C_test)
colormap('jet')
colorbar
xlabel('Test Clusters')
ylabel('True Clusters')
xticks(1:size(C,2))
xticklabels(test_cluster_ids)
yticks(1:size(C,1))
yticklabels(true_cluster_ids)
title('% in Test Cluster (Per Column)')
caxis([0,100])
set(gca,'position',[0.2800    0.1039    0.20    0.7536]);

C_true = C./repmat(sum(C,2),1,size(C,2))*100;
subplot(1,4,3)
imagesc(C_true)
colormap('jet')
colorbar
xlabel('Test Clusters')
ylabel('True Clusters')
xticks(1:size(C,2))
xticklabels(test_cluster_ids)
yticks(1:size(C,1))
yticklabels(true_cluster_ids)
title('% in True Cluster (Per Row)')
caxis([0,100])
set(gca,'position',[0.5300    0.1039    0.20    0.7536]);


subplot(1,4,4)
imagesc(2*C_true.*C_test./(C_true+C_test))
colormap('jet')
colorbar
xlabel('Test Clusters')
ylabel('True Clusters')
xticks(1:size(C,2))
xticklabels(test_cluster_ids)
yticks(1:size(C,1))
yticklabels(true_cluster_ids)
title('F1 score')
caxis([0,100])
set(gca,'position',[0.7800    0.1039    0.20    0.7536]);

end