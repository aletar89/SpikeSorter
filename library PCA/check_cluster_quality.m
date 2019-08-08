% check_cluster_quality     from sst structure/file
%
% gidx = check_cluster_quality( filebase, ilevel, isiTH, idTH, lrTH, nsTH, pvTH, idTH2 )
%
% ilevel        determines logic
% parameters    defaulted to 'B'
%               default parameters (A, B+, B):
%                   ISI index: 0.2
%                   isolation distance: 50
%                   likelihood ratio: 0.05
%                   400 spikes
%                   Peak-to-peak amplitude: 0.04 (mV)
%               A requires all parameters to be satisfied
%               B requires temporal OR morphological isolation to be satisfied
%               B+ is like B but in addition idTH2 must be satistied (default, 15)
%               C is like be, but fixed to a permissive constant parameter set:
%                   ISI index: 0.4
%                   isolation distance: 25
%                   likelihood ratio: 0.2
%                   100 spikes
%                   Peak-to-peak amplitude: 0.04 (mV)
%               D ignores the parameters (but never includes noise cluster)

% 30-jan-12 ES

% revisions
% 06-jul-12 added ilevel 'd' for including all clusters
% 08-aug-19 dumbing down by Alex Tarnavsky

function [ gidx ] = check_cluster_quality( filebase, ilevel )

if isa( filebase, 'char' )
    LoadFn = [ filebase '.sst' ];
    if FileExists( LoadFn )
        load( LoadFn, 'sst', '-mat' )
    end
elseif isa( filebase, 'struct' )
    sst = filebase;
    clear filebase
end

if ~exist( 'sst', 'var' )
    error( 'input type mismatch' )
end
ilevel = lower( ilevel );
switch ilevel
    case 'd'
        gidx = true( size( sst.nspks ) ); %sst.nspks > 0;
        return
    case 'c'
        isiTH = 0.4; idTH = 25; lrTH = 0.2;  nsTH = 100; pvTH = 0.04;
    case { 'a', 'b', 'b+' }
        isiTH = 0.2; idTH = 50; lrTH = 0.05; nsTH = 400; pvTH = 0.04; idTH2 = 15;
    otherwise
        error( 'unrecognized ilevel' )
end
gidx1 = sst.nspks >= nsTH & sst.maxp2p >= pvTH;                     % number of spikes, amplitude
gidx2 = sst.ISIindex <= isiTH;                                      % temporal isolation
gidx3 = sst.ID >= idTH  | ( isnan( sst.ID ) & sst.Lratio <= lrTH ) | ( isnan( sst.ID ) & isnan( sst.Lratio ) ); % morphological isolation
switch ilevel
    case 'a'
        gidx = gidx1 & gidx2 & gidx3;
    case 'b+'
        gidx4 = sst.ID >= idTH2 | ( isnan( sst.ID ) & sst.Lratio <= lrTH ) | ( isnan( sst.ID ) & isnan( sst.Lratio ) ); % morphological isolation
        gidx = gidx1 & ( gidx2 | gidx3 ) & gidx4;
    case { 'b', 'c' }
        gidx = gidx1 & ( gidx2 | gidx3 );
    otherwise
        error( 'unrecognized ilevel' )
end

return

% EOF
