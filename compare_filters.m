data_name = "mC41_12";
shank = 4;
test_filename = sprintf("D:/Alex/%s/MATLAB/%s_shank_%d_test.mat",data_name,data_name,shank);
load(test_filename)
extremum = @(x)logical([0 abs(x(2:end-1))>abs(x(1:end-2)) & abs(x(2:end-1))>abs(x(3:end)) 0]);
plot_sh(single(raw_test_data(:,1:3000)))
time = (1:3000)/20E3;
raw_data = single(raw_test_data(7,1:3000));
res = test_res(1:6)+1;
figure;
subplot(5,1,1)
plot(time,raw_data);
legend('Recorded raw data')

%%
minus_d = 6; plus_d = 9;
mod2der = single([zeros(1,minus_d),...
    (-0.5)*raw_data(1:end-(minus_d+plus_d))+...
    raw_data(minus_d+1:end-plus_d)+...
    (-0.5)*raw_data(minus_d+plus_d+1:end),...
    zeros(1,plus_d)]);
subplot(5,1,2)
plot(time, mod2der)
legend('Modified second derivative')
%%
F_low = 250;
F_high = 6E3;
F_sampling = 20E3;
bp = bandpass(single(raw_test_data(7,1:6000)), [F_low, F_high], F_sampling);
bp = bp(1:3000);
subplot(5,1,3)
plot(time,bp)
legend('Bandpass filter [250,6000]Hz')
%%
back = raw_data(1:end-2);
fwd = raw_data(3:end);
middle = raw_data(2:end-1);
neo = [0, middle.^2 - back.*fwd, 0];
subplot(5,1,4)
plot(time,neo)
legend('NEO')
%% 
mod_back = raw_data(1:end-(minus_d+plus_d));
mod_fwd = raw_data(minus_d+plus_d+1:end);
mod_middle = raw_data(minus_d+1:end-plus_d);
mod_neo = [zeros(1,minus_d), mod_middle.^2 - mod_back.*mod_fwd, zeros(1,plus_d)];
subplot(5,1,5)
plot(time,mod_neo)
legend('Modified NEO')
