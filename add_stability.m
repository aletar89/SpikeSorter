stability = cell2table({'mC41_33', 1, 'unstable';
                         'mC41_33', 2, 'stable';
                         'mC41_33', 3, 'stable';
                         'mC41_33', 4, 'unstable';
                         'mC41_33', 5, 'bad';
                         'mC41_12', 1, 'unstable';
                         'mC41_12', 2, 'unstable';
                         'mC41_12', 3, 'bad';
                         'mC41_12', 4, 'stable';
                         'mC41_12', 5, 'bad'},'VariableNames',{'data_name', 'shank', 'stability'});
for i = 1:size(RTable,1)
    shank_ind = find(strcmp(RTable.data_name(i),stability.data_name) & RTable.shank(i)==stability.shank);
    RTable.stability(i) = stability.stability(shank_ind);
end