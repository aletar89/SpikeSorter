minus_d = 6; plus_d = 9;
N_electrodes = 1;
mod2der_func = @(data) single([zeros(N_electrodes,minus_d),...
    (-0.5)*data(:,1:end-(minus_d+plus_d))+...
    data(:,minus_d+1:end-plus_d)+...
    (-0.5)*data(:,minus_d+plus_d+1:end),...
    zeros(N_electrodes,plus_d)]);

b = [-0.5, zeros(1,plus_d-1),1,zeros(1,minus_d-1),-0.5];
fvtool(b,1)

%% Test alignment
try_data = raw_train_data(5,:);
data1 = mod2der_func(try_data);
data2 = filter(b,1,try_data);
data2 = [data2(plus_d+1:end) zeros(1,plus_d)];
plot(data1(1:1000))
hold on
plot(data2(1:1000))