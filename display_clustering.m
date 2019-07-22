function display_clustering(data,spike_times, clusters, half_width)
%% Prepare data
on_edge = (spike_times - half_width < 1 ) | (spike_times + half_width > size(data,2));
spike_times(on_edge) = [];
clusters(on_edge) = [];
spike_forms = zeros(size(data,1), 2*half_width + 1, length(spike_times));
% % % commented out detrending, uncoment lines 7-15 to use detrended data
%slope = repmat(linspace(0,1,33),size(data,1),1);
for i=1:length(spike_times)
%     first_val = mean(data(:,spike_times(i)-half_width:spike_times(i)-half_width+2),2);
%     first_val = repmat(first_val, 1, 2*half_width+1);
%     lsat_val = mean(data(:,spike_times(i)+half_width-2:spike_times(i)+half_width),2);
%     last_val = repmat(lsat_val, 1, 2*half_width+1);
%     detrend = first_val - slope.*last_val;
    spike_forms(:,:,i) = data(:,spike_times(i)-half_width:spike_times(i)+half_width);
%     spike_forms(:,:,i) = spike_forms(:,:,i) - detrend;
end

colors = [1,0,0;
          0,1,0;
          0,0,1;
          0.5,0.5,0;
          0.5,0,0.5;
          0,0.5,0.5];
cluster_ids = unique(clusters);
chained_spikes = reshape(permute(spike_forms,[2,1,3]),[size(spike_forms,1)*size(spike_forms,2), size(spike_forms,3)])';
coef = pca(chained_spikes);
pca_space = chained_spikes*coef;

%% 3D PCA scatter
figure(1)
for i = 1:length(cluster_ids)
    c = cluster_ids(i);
    scatter3(pca_space(clusters==c,1), pca_space(clusters==c,2), pca_space(clusters==c,3),[],colors(i,:),'.')
    hold all
end
legend( num2str(unique(clusters)))

%% Spike shapes
figure(2); clf(2)
for i = 1:length(cluster_ids)
    c = cluster_ids(i);
    alpha = min(15/sum(clusters==c),1);
    ax1 = subplot(1,5,1:3);
    plot(chained_spikes(clusters==c,:)','color',[colors(i,:), alpha])
    hold on
    plot(mean(chained_spikes(clusters==c,:)),'color',colors(i,:),'linewidth',3);
    ax2 = subplot(1,5,4:5);
    plot(chained_spikes(clusters==c,:)'-i*2500,'color',[colors(i,:), alpha])
    hold on
end
linkaxes([ax1, ax2],'x')

end


