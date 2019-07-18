path='F:\stark_lab\data\mC41_33\mC41_33.dat';
m = memmapfile(path, 'format', 'int16' );                     % opening dat file in matlab
format compact
s=size(m.Data);
data=m.Data;
data=data(1:1*63*20000*60*30);
datamat = reshape( data, [ 63 s(1) / 63 ] );         % orgenizing m into a matrix...
                                                              %columns = channels rows = samples             

idx=(time(1)*60*20000:time(2)*60*20000);                      % choosing time of intrest un minutes
data = double(datamat(idx,chOfIntrest+1));