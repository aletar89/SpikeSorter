function [good] = good_clusters(sst_file, shank)
sst = importdata(sst_file);
shank_ind = sst.shankclu(:,1)==shank;
clusters = sst.shankclu(shank_ind,2);
good_ind = (sst.ID(shank_ind) > 45 | sst.Lratio(shank_ind) < 0.1) & ...
    sst.ISIindex(shank_ind) <0.1 & sst.snr(shank_ind) > 2.25;
good = clusters(good_ind);
end

