sst = importdata('data/mC41_33/mC41_33.sst');
shank1 = sst.shankclu(:,1)==1;
clusters = sst.shankclu(shank1,2);
ID = sst.ID(shank1);
Lratio = sst.Lratio(shank1);
ISI = sst.ISIratio(shank1);
snr = sst.snr(shank1);
loose = (ID > 45 | Lratio < 0.1) & ISI <0.1 & snr > 2.25;
medium = (ID > 50 | Lratio < 0.05) & ISI <0.05 & snr > 3;
strict = (ID > 55 | Lratio < 0.01) & ISI <0.01 & snr > 4;
disp([loose, medium, strict])