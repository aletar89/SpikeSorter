D = load('data/mC41_33_shank_2.mat');

half_width = 16;
spike_times = D.true_spike_times;
clusters = D.true_clusters;
data = double(D.clean_data);

spike_forms = zeros(length(spike_times), half_width*2+1);
taken_from_channel = zeros(length(spike_times),1);
for i=1:length(spike_times)
    all_channels = data(:,spike_times(i)-half_width:spike_times(i)+half_width);
    [sample_max,channel_of_max] = max(abs(all_channels));
    [~, sample_of_max] = max(sample_max);
    best_spike_form = all_channels(channel_of_max(sample_of_max),:);
    spike_forms(i,:) = best_spike_form;
    taken_from_channel(i) = channel_of_max(sample_of_max);
end

coef = pca(spike_forms);
pca_space = spike_forms*coef;
n = 10;
N = size(pca_space,1);
for i=0:n-1
    inds = ceil(N*i/n+1):floor(N*(i+1)/n);
    scatter(pca_space(inds,1), pca_space(inds,3),'filled', 'markerfacealpha',0.1)
    xlim([min(pca_space(:,1)), max(pca_space(:,1))]);
    ylim([min(pca_space(:,3)), max(pca_space(:,3))]);
    pause
end
scatter(pca_space(:,1), pca_space(:,2),'filled', 'markerfacealpha',0.05)
pause
clf
cluster_ids = unique(clusters);
for i = 1:length(cluster_ids)
    c = cluster_ids(i);
    scatter3(pca_space(clusters==c,1), pca_space(clusters==c,2), pca_space(clusters==c,3),[],'filled', 'markerfacealpha',0.1)
    hold all
    pause
end

part = 1000000;
data_part = data(7,1:part);
pca_data1 = zeros(size(data_part));
pca_data2 = zeros(size(data_part));
for i = 1:10
    p1 = xcorr(data(i,1:part),coef(:,1));
    pca_data1(i,:) = p1(part:end);
    p2 = xcorr(data(i,1:part),coef(:,2));
    pca_data2(i,:) = p2(part:end);
end

p1 = xcorr(data(7,1:part),coef(:,1));
p1 = p1(part:end);
p2 = xcorr(data(4,1:part),coef(:,2));
p2 = p2(part:end);
clf
hold on
plot(p1,p2,'color',[0,0,1,0.1])
scatter(pca_space(:,1), pca_space(:,2),[],'filled', 'markerfacealpha',0.1, 'markerfacecolor',[1,0,0])
