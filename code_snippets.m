
cla
spike_times = S.test_spike_times;
[gt_times, det_times] = S.mutual_times(spike_times(:), no_noise_times, 10);
%var = max(data,[],1)-min(data,[],1);
minmax = max(data,[],1)-min(data,[],1);
var = rms(data,1)./abs(mean(data,1));
scatter(mNEO(spike_times(~det_times)), var(spike_times(~det_times)),'filled','markerfacealpha',0.05, 'markerfacecolor',[0,0,1])
hold on
scatter(mNEO(spike_times(det_times)), var(spike_times(det_times)),'filled','markerfacealpha',0.05, 'markerfacecolor',[0,1,0])
scatter(mNEO(no_noise_times(~gt_times)), var(no_noise_times(~gt_times)),'filled','markerfacealpha',0.05, 'markerfacecolor',[1,0,0])


scatter(minmax(spike_times(~det_times)), var(spike_times(~det_times)),'filled','markerfacealpha',0.05, 'markerfacecolor',[0,0,1])
hold on
scatter(minmax(spike_times(det_times)), var(spike_times(det_times)),'filled','markerfacealpha',0.05, 'markerfacecolor',[0,1,0])
scatter(minmax(no_noise_times(~gt_times)), var(no_noise_times(~gt_times)),'filled','markerfacealpha',0.05, 'markerfacecolor',[1,0,0])



figure
ax1 = subplot(2,1,1);
display_spike_times(data(:,1:50000), S.test_spike_times, det_times)
ax2 = subplot(2,1,2);
display_spike_times(data(:,1:50000), no_noise_times, gt_times)
linkaxes([ax1, ax2],'xy')

scatter(mNEO(no_noise_times(gt_times)), var(no_noise_times(gt_times)),'filled','markerfacealpha',0.01, 'markerfacecolor',[0,0,1])

figure
histogram(mNEO(spike_times(det_times)),'normalization','count','facecolor',[0,1,0])
hold on
histogram(mNEO(spike_times(~det_times)),'normalization','count','facecolor',[1,0,0])


figure
histogram(var(spike_times(det_times)),'normalization','count','facecolor',[0,1,0])
hold on
histogram(var(spike_times(~det_times)), 'normalization','count','facecolor',[1,0,0])





clusters = OSort(S.features,80, 10,30);
unique_clusters = unique(clusters);
spikes_per_cluster = sum(clusters == unique_clusters');
[~,count_sort] = sort(spikes_per_cluster,'descend');
most_spikes = unique_clusters(count_sort(1:5));
big_clusters = clusters;
for d = 1:length(db)
    if ~any(most_spikes==d)
        big_clusters(big_clusters == d) = 0;
    end
end
display_clustering(data,S.true_spike_times,features, big_clusters, 16)
S.rate_clustering(S.true_spike_times(1:1E4),clusters, S.true_spike_times(1:1E4), S.true_clusters(1:1E4),10)


all_means = cell2mat({db.mean})';
all_inds = zeros(size(db));
first_ind = zeros(size(db));
for j = 1:length(db)
    all_inds(j) = length(db(j).inds);
    first_ind(j) = db(j).inds(1);
end
cefs = pca(all_means);
pc1 = all_means*cefs(:,1);
pc2 = all_means*cefs(:,2);
figure
scatter(pc1, pc2,all_inds)

%% Dispaly clustering of the ground truth
display_clustering(S.clean_data, S.true_spike_times,[], S.true_clusters,16);

%% Dispaly clustering of the ground truth with calculated features
display_clustering(S.clean_data, S.true_spike_times,S.features, S.true_clusters,16);

%% Display clustering result without features
display_clustering(S.clean_data, S.test_spike_times,[], S.test_clusters,16);

%% Show histogram of distanses between random features
N=500;
p = randperm(size(S.features,2),N);
dists = nan(N);
for i = 1:length(p)-1
    for j=i+1:length(p)
        dists(i,j) = sum(abs(S.features(:,p(i))-S.features(:,p(j))))/size(S.features,1);
    end
end
dists = dists(:);
dists(isnan(dists))=[];
hist(dists,100)

%% Normalize feature variance
s = std(S.features,[],2);
S.features = S.features./ repmat(s,1, size(S.features,2));

%% Show NEO value
zero_column = zeros(size(data,1),1);
NEO_of_data = [zero_column data(:,2:end-1).^2 - data(:,1:end-2).*data(:,3:end) zero_column];
max_neo = zeros(size(spike_times));
max_abs = zeros(size(spike_times));
for i = 1:length(spike_times)
    NEO_of_spikes = NEO_of_data(:,spike_times(i)-half_width:spike_times(i)+half_width);
    all_channels = data(:,spike_times(i)-16:spike_times(i)+16);
    [channel_max, max_sample] = max(abs(all_channels),[],2);
    [~, channel_of_max] = max(channel_max);
    max_abs(i) = max_sample(channel_of_max);
    [channel_max, max_sample] = max(abs(NEO_of_spikes),[],2);
    [~, channel_of_max] = max(channel_max);
    max_neo(i) = max_sample(channel_of_max);
end
edges = 11.5:20.5;
h = histogram(max_neo,edges);
neo_hist = h.Values;
h = histogram(max_abs,edges);
abs_hist = h.Values;
bar((12:20)-16,[abs_hist', neo_hist'])
legend('max abs','max neo');
title('histogram of sample number')



    
    
    