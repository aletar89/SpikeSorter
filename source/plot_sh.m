function plot_sh(data, seconds)
%PLOT_SH Summary of this function goes here
%   Detailed explanation goes here
if nargin > 1
    data = data(:,1:seconds*20000);
end
N = size(data,2);
dy = 2000;
max_y = (size(data,1)-1) * dy;
disp_mat = repmat(0:-dy:-max_y,N,1);
plot(data'+disp_mat)
end

