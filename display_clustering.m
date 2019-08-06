function display_clustering(data,spike_times,features, clusters, half_width)
if nargin == 3
    half_width = 16;
end
%% Prepare data
on_edge = (spike_times - half_width < 1 ) | (spike_times + half_width > size(data,2));
spike_times(on_edge) = [];
clusters(on_edge) = [];
if ~isempty(features)
    features(:,on_edge) = [];
end
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
while length(cluster_ids)>6
    spikes_per_cluster = sum(clusters == cluster_ids');
    [~,count_sort] = sort(spikes_per_cluster);
    least_spikes = cluster_ids(count_sort(1));
    spike_times(clusters==least_spikes) = [];
    if ~isempty(features)
        features(:,clusters==least_spikes) = [];
    end
    clusters(clusters==least_spikes) = [];
    cluster_ids = unique(clusters);
end
chained_spikes = reshape(permute(spike_forms,[2,1,3]),[size(spike_forms,1)*size(spike_forms,2), size(spike_forms,3)])';
if isempty(features)
    [coeff,score,~,~,~,mu] = pca(chained_spikes);
else
    [coeff,score,~,~,~,mu] = pca(features');
end

%% PCA scatters
figure
max_points = 1000;
for i = 1:length(cluster_ids)
    c = cluster_ids(i);
    points = find(clusters==c);
    if length(points)>max_points
        selected = round(length(points)*rand(1,max_points));
        while min(selected)==0
            selected = round(length(points)*rand(1,max_points));
        end
        points = points(selected);
    end
    subplot(2,2,1)
    scatter(score(points,1), score(points,2),[],colors(i,:),'filled','markerfacealpha',0.1)
    xlabel('PC1');
    ylabel('PC2');
    hold on
    subplot(2,2,2)
    scatter(score(points,1), score(points,3),[],colors(i,:),'filled','markerfacealpha',0.1)
    xlabel('PC1');
    ylabel('PC3');
    hold on
    subplot(2,2,3)
    scatter(score(points,1), score(points,4),[],colors(i,:),'filled','markerfacealpha',0.1)
    xlabel('PC1');
    ylabel('PC4');
    hold on
    subplot(2,2,4)
    scatter(score(points,1), score(points,5),[],colors(i,:),'filled','markerfacealpha',0.1)
    xlabel('PC1');
    ylabel('PC5');
    hold on
end
legend( num2str(unique(clusters)))

%% Spike shapes
figure
max_points = 500;
for i = 1:length(cluster_ids)
    c = cluster_ids(i);
    points = find(clusters==c);
    if length(points)>max_points
        selected = round(length(points)*rand(1,max_points));
        while min(selected)==0
            selected = round(length(points)*rand(1,max_points));
        end
        points = points(selected);
    end
    alpha = max(min(15/length(points),1),0.03);
    ax1 = subplot(1,5,1:3);
    plot(chained_spikes(points,:)','color',[colors(i,:), alpha])
    hold on
    plot(mean(chained_spikes(points,:)),'color',colors(i,:),'linewidth',3);
    ax2 = subplot(1,5,4:5);
    plot(chained_spikes(points,:)'-i*2500,'color',[colors(i,:), alpha])
    hold on
end
linkaxes([ax1, ax2],'x')

end


