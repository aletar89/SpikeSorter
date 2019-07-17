clu1 = import_data('data/mF79_26/mF79_26.clu.2');
res1 = import_data('data/mF79_26/mF79_26.res.2');
clu1(1) = [];
bad1 = (clu1 == 0 | clu1 == 1);
res1(bad1) = [];
clu1(bad1) = [];

clu2 = import_data('data/mF79_26O/mF79_26.clu.2');
res2 = import_data('data/mF79_26O/mF79_26.res.2');
clu2(1) = [];
bad2 = (clu2 == 0 | clu2 == 1);
res2(bad2) = [];
clu2(bad2) = [];
S = SpikeSorter([],[],[]);
S.rate_detection(res1, res2, 10)
S.rate_clustering(res1, clu1, res2, clu2, 10)*100
