function display_confusion(C)
figure
subplot(1,4,1)
imagesc(C)
colormap('jet')
colorbar
xlabel('Test Clusters')
ylabel('True Clusters')
title('Number Of Spikes')

C_test = C./repmat(sum(C,1),size(C,1),1)*100;
subplot(1,4,2)
imagesc(C_test)
colormap('jet')
colorbar
xlabel('Test Clusters')
ylabel('True Clusters')
title('% in Test Cluster (Per Column)')

C_true = C./repmat(sum(C,2),1,size(C,2))*100;
subplot(1,4,3)
imagesc(C_true)
colormap('jet')
colorbar
xlabel('Test Clusters')
ylabel('True Clusters')
title('% in True Cluster (Per Row)')

subplot(1,4,4)
imagesc(2*C_true.*C_test./(C_true+C_test))
colormap('jet')
colorbar
xlabel('Test Clusters')
ylabel('True Clusters')
title('F1 score')
end