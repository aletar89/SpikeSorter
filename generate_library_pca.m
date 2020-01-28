ls = dir;
spike_shapes = [];
for f = 1:length(ls)
    if strfind(ls(f).name,'.sst')
        load(ls(f).name,'sst','-mat')
        is_good_cluster = check_cluster_quality( sst, 'b' );
        disp(sprintf("%s has %d good clusters", ls(f).name, sum(is_good_cluster)))
        for c = 1:length(sst.mean)
            if is_good_cluster(c)
                mean_spike = sst.mean{c};
                p2p = max(mean_spike,[],2)-min(mean_spike,[],2);
                [~,strongest_channel] = max(p2p);
                strongest_spike = mean_spike(strongest_channel,:);
                [~, ind] = max(abs(strongest_spike));
                if abs(ind-16)<5
                    clf
                    plot(strongest_spike)
                    strongest_spike = interp1(1:32,strongest_spike, ind-15:ind+16,[],'extrap');
                    hold on
                    plot(strongest_spike)
                end
                zero_mean_spike = strongest_spike - mean(strongest_spike);
                normalized_spike = zero_mean_spike./norm(zero_mean_spike);
                spike_shapes = [spike_shapes; normalized_spike];
            end
        end
        disp(sprintf("spike_shapes now has %d spikes", size(spike_shapes,1)))
    end
end

[coeff,score] = pca(spike_shapes, 'Centered', 'off');
lib_coeff = coeff(:,1:10);
% save('sst_library_PCA','lib_coeff');