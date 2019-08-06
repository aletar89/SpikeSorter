
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
SF = zeros(1, size(h,1));
for i=1:length(SF)
    m = mean(h(i,:));
    s = std(h(i,:))^2;
    hist_obj = histogram(h(i,:),100,'normalization','pdf');
    x = (hist_obj.BinEdges(1:end-1) + hist_obj.BinEdges(2:end))/2;
    g = pdf(gmdistribution(m,s),x')';
    hold on
    plot(x,g)
    v = hist_obj.Values;
    SF(i) = sum(abs(v-g));
    title(i)
    clf
end


p = randperm(length(spike_times),1000);
candidates = [2,9,10,11,12,22,23,28,29,31,32];
N = length(candidates);
for i = 1:N
    for j = 1:N
        subplot(N,N,sub2ind([N,N],i,j))
        cand_i = candidates(i);
        cand_j = candidates(j);
        scatter(h(cand_i,p),h(cand_i,p),'fill','markerfacealpha',0.1)
    end
end
