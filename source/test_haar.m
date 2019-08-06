
half_width = 16;
if ~exist('D', 'var')
    D = load('data/mC41_33_shank_2.mat');
end
spike_times = D.true_spike_times;
data = double(D.clean_data);
spike_forms = get_strongest_spikes(data, spike_times, half_width);
spike_forms = spike_forms(:,2:end)';

[a,d] = haart(spike_forms,4);
h = [a; d{1}; d{2}; d{3}; d{4}];

unique_clusters = unique(D.true_clusters);
clster_mean = zeros(size(h,1), length(unique_clusters));
clster_std = zeros(size(h,1), length(unique_clusters));
for i = 1:size(h,1)
    for j = 1:length(unique_clusters)
        clster_mean(i,j) = mean(h(i,D.true_clusters==unique_clusters(j)));
        clster_std(i,j) = std(h(i,D.true_clusters==unique_clusters(j)));
    end
end

h_grade = zeros(1,32);
for i=1:size(h,1)
    for j = 1:length(unique_clusters)-2
        for k = 2:length(unique_clusters)
            dist = abs(clster_mean(i,j) - clster_mean(i,k));
            var = clster_std(i,j) + clster_std(i,k);
            ratio = dist/var;
            h_grade(i) = h_grade(i) + ratio;
        end
    end
end

[B,I] = sort(h_grade,'descend');

best_I = [2, 10, 23, 29, 32];
wavelets = zeros(size(h,1), length(best_I));
for i = 1:length(best_I)
    ih = zeros(size(h,1),1);
    ih(best_I(i)) = 1;
    ia = ih(1:2);
    id = {ih(3:3+16-1), ih(3+16:3+16+8-1), ih(3+16+8:3+16+8+4-1), ih(3+16+8+4:3+16+8+4+2-1)};
    wavelets(:,i) = ihaart(ia,id);
    stem(wavelets(:,i))
    title(best_I(i));
end

save('haar_wavelets.mat', 'wavelets')

