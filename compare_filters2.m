tic
%raw_data = single(randn(1,36E6));
data_name = "mC41_12";
shank = 4;
test_filename = sprintf("D:/Alex/%s/MATLAB/%s_shank_%d_test.mat",data_name,data_name,shank);
load(test_filename)
raw_data = single(raw_test_data(7,:));
N = numel(raw_data);
%%
minus_d = 6; plus_d = 9;
mod2der = single([zeros(1,minus_d),...
    (-0.5)*raw_data(1:end-(minus_d+plus_d))+...
    raw_data(minus_d+1:end-plus_d)+...
    (-0.5)*raw_data(minus_d+plus_d+1:end),...
    zeros(1,plus_d)]);
%%
F_low = 250;
F_high = 6E3;
F_sampling = 20E3;
bp = bandpass(raw_data, [F_low, F_high], F_sampling);
%%
back = raw_data(1:end-2);
fwd = raw_data(3:end);
middle = raw_data(2:end-1);
neo = [0, middle.^2 - back.*fwd, 0];
%% 
mod_back = raw_data(1:end-(minus_d+plus_d));
mod_fwd = raw_data(minus_d+plus_d+1:end);
mod_middle = raw_data(minus_d+1:end-plus_d);
mod_neo = [zeros(1,minus_d), mod_middle.^2 - mod_back.*mod_fwd, zeros(1,plus_d)];
%%
med = movmedian(raw_data,[10,10]);
med_hp = raw_data - med;
%%
figure(1)
all_data = [raw_data; mod2der; bp; sqrt(abs(neo)); sqrt(abs(mod_neo)); med_hp];
all_names = {'No Filter', 'Mod. 2nd Der.', 'Bandpass', 'NEO', 'Mod. NEO', 'Median'};
n=10000;
for i=1:6
    for j=6
        disp([i,j])
        subplot(6,6,sub2ind([6,6],i,j))
        cla
        if i==j
            pwelch(all_data(1,:),N/n,[],[],20E3);
            hold on
            pwelch(all_data(i,:),N/n,[],[],20E3);
            c = get(gca,'children');
            set(c(2),'color',[1,0,0]);
            set(c(1),'color',[0,0.8,0]);
            ylabel({'Power/frequency', '[dB/Hz]'});
            set(gca,'xscale','log')
            title(all_names{i})
        else
            mscohere(all_data(i,:),all_data(j,:),N/n,[],[],20E3);
            ylabel({'Magnitude-Squared', 'Coherence'})
            ylim([-0.1,1.1])
            title([all_names{j} ' - ' all_names{i}])
            set(gca,'xscale','log')
        end
    end
end
for i=1:6
    subplot(6,6,sub2ind([6,6],i,i))
    ylim([-30 65])
end
toc