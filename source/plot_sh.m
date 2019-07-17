function plot_sh(data)
%PLOT_SH Summary of this function goes here
%   Detailed explanation goes here
N = size(data,2);
dy = 600;
max_y = (size(data,1)-1) * dy;
disp_mat = repmat(0:-dy:-max_y,N,1);
plot(data'+disp_mat)
end

