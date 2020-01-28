function [result] = get_result(alg_name, local_dFNR,local_dFPR2FPR, local_fit_tree,data_name,shank,find_cost_for_dFNR_is_1)
try
    [cost_found, dFNR_minus_1] = find_cost_for_dFNR_is_1(local_dFNR);
catch
    disp('fzero failed')
    try
        find_cost_for_dFNR_is_1 = @(dFNR_func) fzero(@(x) dFNR_func(x)-1,[0.1,1000],optimset('Display','iter','TolX',0.01));
        [cost_found, dFNR_minus_1] = find_cost_for_dFNR_is_1(local_dFNR);
    catch
        disp('fzero failed at 1000')
        cost_found = 1000;
        dFNR_minus_1 = local_dFNR(1000);
    end
end

out_tree = compact(local_fit_tree(cost_found, 64));
result = struct('data_name',data_name,'shank',shank,...
    'algorithm',alg_name,...
    'dFNR',dFNR_minus_1+1,'dFPR2FPR',local_dFPR2FPR(cost_found),'tree',out_tree);
end

