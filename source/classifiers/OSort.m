function [clusters] = OSort(features, threshold, averaging_n, max_clusters)
%OSORT Summary of this function goes here
%   Detailed explanation goes here
if nargin == 1
    threshold = 80;
    averaging_n = 10;
    max_clusters = 30;
end
Nspikes = size(features,2);
clusters = zeros(Nspikes,1);
db = struct('type','temp','mean',features(:,1),'all_spikes',features(:,1), 'inds', 1);
clusters(1) = 1;
for s = 2:Nspikes
    if mod(s,round(Nspikes/20)) == 0
        disp(round(s/Nspikes*100))
    end
    distances = zeros(size(db));
    for d = 1:length(db)
        distances(d) = mean(abs(features(:,s)-db(d).mean));
    end
    [min_val, min_ind] = min(distances);
    if min_val < threshold
        db(min_ind).all_spikes = [db(min_ind).all_spikes, features(:,s)];
        db(min_ind).inds = [db(min_ind).inds, s];
        spikes_in_cluster = min(length(db(min_ind).inds), averaging_n);
        db(min_ind).mean = db(min_ind).mean + (features(:,s) - db(min_ind).mean)/spikes_in_cluster;
        clusters(s) = min_ind;
    else
        clusters(s) = length(db)+1;
        db(length(db)+1) = struct('type','temp','mean',features(:,s),'all_spikes',features(:,s), 'inds', s);
        if length(db)> max_clusters
            for d=1:length(db)
                if length(db(d).inds)==1
                    db(d) = [];
                    clusters(clusters==d)=0;
                    break
                end
            end
        end
    end
    break_flag = true;
    while break_flag
        break_flag = false;
        for d1=1:length(db)-1
            for d2 = d1+1:length(db)
                dist = mean(abs(db(d1).mean-db(d2).mean));
                if dist < threshold
                    merged_mean = (db(d1).mean*length(db(d1).inds)+db(d2).mean*length(db(d2).inds))/(length(db(d1).inds)+length(db(d2).inds));
                    merged_spikes = [db(d1).all_spikes, db(d2).all_spikes];
                    merged_inds = [db(d1).inds, db(d2).inds];
                    db(d1) = struct('type','temp','mean',merged_mean,'all_spikes',merged_spikes, 'inds', merged_inds);
                    db(d2) = [];
                    clusters(clusters==d2)=d1;
                    break_flag = true;
                    break
                end
            end
            if break_flag
                break
            end
        end
    end
end

end

