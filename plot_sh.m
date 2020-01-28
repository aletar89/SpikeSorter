function plot_sh(data, dy)
%PLOT_SH Summary of this function goes here
%   Detailed explanation goes here
if nargin < 2
    dy = max(max(data,[],2)-min(data,[],2));
end
N = size(data,2);
max_y = (size(data,1) - 1) * dy;
disp_mat = repmat(0:-dy:-max_y,N,1);
disp_mat = cast(disp_mat,'like',data) ;
plot(data'+disp_mat)
ylim([-max_y-dy/2, dy/2]);
xticks(ceil(size(data,2)/2))
yticks(-max_y:dy:0)
grid on
end

