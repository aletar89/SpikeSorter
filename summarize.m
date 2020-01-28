function [MTable] = summarize(RTable)
algorithms = unique(RTable.algorithm);
var_names = RTable.Properties.VariableNames;
var_names(strcmp(var_names,'data_name')) = [];
var_names(strcmp(var_names,'shank')) = [];
var_names(strcmp(var_names,'algorithm')) = [];
var_names(strcmp(var_names,'stability')) = [];
MTable = table();
stability_options = ["stable","unstable"];
for s = 1:2
    for a = 1:length(algorithms)
        table_ind = a+(s-1)*length(algorithms);
        MTable.stability(table_ind) = stability_options(s);
        MTable.algorithm(table_ind) = algorithms(a);
        relevant = strcmp(RTable.algorithm,algorithms(a)) & strcmp(RTable.stability,stability_options(s));
        for v = 1:length(var_names)
            MTable.([var_names{v} '_mean'])(table_ind) = mean(RTable.(var_names{v})(relevant));
            MTable.([var_names{v} '_median'])(table_ind) = median(RTable.(var_names{v})(relevant));
        end
    end
end
end

