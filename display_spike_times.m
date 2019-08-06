function display_spike_times(data,spike_times, clusters, half_width, dy)
if nargin < 5
    dy = 2000;
end
if nargin < 4
    half_width = 16;
end
if nargin < 3
   clusters = ones(size(spike_times));
end
on_edge = (spike_times - half_width < 1 ) | (spike_times + half_width > size(data,2));
spike_times(on_edge) = [];
clusters(on_edge) = [];

N = size(data,2);
max_y = (size(data,1)-1) * dy;
disp_mat = repmat(0:-dy:-max_y,N,1);
plot(data'+disp_mat,'color',[0.8,0.8,0.8])
hold on

colors = [1,0,0;
          0,1,0;
          0,0,1;
          0.5,0.5,0;
          0.5,0,0.5;
          0,0.5,0.5];
      
cluster_ids = unique(clusters);
for i=1:length(cluster_ids)
    c = cluster_ids(i);
    cluster_spikes = data;
    is_spike = false(1,size(data,2));
    for dt = -half_width:half_width
        is_spike(spike_times(clusters==c)+dt) = true;
    end
    cluster_spikes(:,~is_spike)=nan;
    plot(cluster_spikes'+disp_mat,'color',colors(i,:))
end

end

