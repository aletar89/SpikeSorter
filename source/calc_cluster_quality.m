% CALC_CLUSTER_QUALITY      for sorted waveforms
%
% CALL                      [ CLUS, NUMS, ID, SNR, ISI, LRATIO ] = CALC_CLUSTER_QUALITY( ADATE, FNUM, SHANKNUM )
%
% GETS                      ADATE, FNUM, SHANKNUM
%
% RETURNS                   CLUS, NUMS      cluster number and number of spikes (after noise removal)
%                           ID              isolation distance of cluster from others (Harris et al., 2001)
%                           SNR             mean SNR of waveforms (cluster homogeneity) (Ozen et al., 2010)
%                           ISI             temporal isolation index (Fee et al., 1996)
%                           LRATIO          L-ratio (separation measure)

% 21-mar-11 ES


function [ clus, nums, id, snr, isi, lratio ] = calc_cluster_quality( adate, fnums, shanknum )

nargs = nargin;

% sampling
P2PVs = 4;
A2DU = 2 ^ 15;
Fs = 20000;
NSPK = 32;
% cleaning
SNR_TH = 1.5; % median of gaussian noise, max over 8 channels
peakTH = 0; % 0.05; % mV
PRE_TRIG_DT = 0; % do not remove causal spikes
%POST_TRIG_DT = 0.25e-3 * Fs; % 0.25 ms after onset/offset
POST_TRIG_DT = 1e-3 * Fs; % 0.25 ms after onset/offset

% temporal statistics
ISI1 = 0.002; % (sec) count number of ISIs smaller than 2 ms
ISI2 = 0.020; % (sec) out of ISIs smaller than 20 ms
DT = 8 / Fs; % (sec) detection dead time
CF = ( ISI2 - DT ) / ( ISI1 - DT );

% GET PARAMETES
params = get_date_parameters( adate );
datdir = sprintf( '%s/%s/dat', params.drive, adate );
matdir = sprintf( '%s/%s/mat', params.drive, adate );

% GO OVER FILES
for fnum = fnums
    % LOAD
    fprintf( 1, 'file %d, shank %d... ', fnum, shanknum )
    if fnum < 10
        filebase = sprintf( '%s/es%s.00%d/es%s.00%d', datdir, adate, fnum, adate, fnum );
    else
        filebase = sprintf( '%s/es%s.0%d/es%s.0%d', datdir, adate, fnum, adate, fnum );
    end
    clufname = sprintf( '%s.clu.%d', filebase, shanknum );
    %spkfname = sprintf( '%s.spk.%d', filebase, shanknum );
    snrfname = sprintf( '%s.snr.%d', filebase, shanknum );
    %resfname = sprintf( '%s.res.%d', filebase, shanknum );
    fetfname = sprintf( '%s.fet.%d', filebase, shanknum );
    %spk0 = LoadSpk( spkfname,params.nchans( shanknum ), NSPK ) / A2DU * P2PVs;
    if ~exist( snrfname )
        compute_spk_snrs( adate );
    end
    snr0 = load( snrfname );
    fet0 = LoadFet( fetfname );
    clu0 = load( clufname );
    %res0 = load( resfname );
    res0 = fet0( :, end ); % the last feature in the fet file is time (in samples)
    nspks_orig( shanknum ) = length( clu0 );
    fprintf( 1, '%d loaded...', nspks_orig( shanknum ) );
    clu0( 1 ) = [];
    
    % REMOVE low SNR, low peak, and post onset/offset spike
    matfname = sprintf( '%s/%s_f%d_f%d.mat', matdir, adate, params.fnums( 1 ), params.fnums( end ) );
    if exist( matfname, 'file' )
        L = load( matfname );
        matc = L.matc;
    else
        matc = [];
    end
    % remove by SNR, peak
    %s0 = calc_spk_snrs( spk0 )';
    %mv = squeeze( max( max( abs( spk0 ), [], 2 ) ) );% any sample
    %spk0 = [];
    s0 = snr0( :, 1 );
    mv = snr0( :, 2 ) / A2DU * P2PVs; % convert from A2DU to volts
    ridx0 = s0 <= SNR_TH;
    ridx1 = mv <= peakTH;
    ridx = ridx0 | ridx1;
    fprintf( 1, 'to remove: s/p: %d/%d; ', sum( ridx0 ), sum( ridx1 & ~ridx0 ) )
    % remove by post onset/offset
    trigchans = params.trigchans;
    if ~isempty( matc )
        for k = 1 : length( trigchans )
            ridxk = false( size( res0 ) ) ;
            mat = matc{ fnum, k };
            if isa( mat, 'cell' )
                continue
            end
            potential_spk_times = mat( : );         % onset/offset
            for si = 1 : length( potential_spk_times )
                ridxk = ridxk | ( res0 >= potential_spk_times( si ) - PRE_TRIG_DT & res0 <= potential_spk_times( si ) + POST_TRIG_DT );
            end
            fprintf( 1, 't%d: %d(%d); ', trigchans( k ), sum( ridxk ), sum( ridxk & ~ridx ) )
            ridx = ridx | ridxk;
        end
    end
    % actually remove
    % spk( :, :, ridx ) = [];
    clu0( ridx ) = [];
    res0( ridx ) = [];
    fet0( ridx, : ) = [];
    s0( ridx ) = [];
    fprintf( 1, '%d (%0.3g%%) left\n', length( res0 ), length( res0 ) / nspks_orig( shanknum ) * 100 )
    
    % accumulate
    if fnum == fnums( 1 )
        clu = clu0;
        res = res0;
        fet = fet0;
        s = s0;
    else
        clu = [ clu; clu0 ];
        res = [ res; res0 + res( end ) ];
        fet = [ fet; fet0 ];
        s = [ s; s0 ];
    end
end

fet( :, size( fet, 2 ) + [ -4 : 0 ] ) = []; % remove non-PCA features
fidx = 1 : size( fet, 2 ); % consider those features only

% compute mahal distance for each (non-noise) cluster
% ignore artefactual (cluster 0) spikes
[ nums0 clus0 ] = uhist( clu );
id = NaN * ones( clus0( end ), 1 );
nums = id;
clus = id;
lratio = id;
r = id;
snr = id;
isi = id;
clus( clus0( clus0 >= 1 ) ) = clus0( clus0 >= 1 );
nums( clus0( clus0 >= 1 ) ) = nums0( clus0 >= 1 );
for clunum = clus( clus >= 1 )'
    cidx = clu == clunum;
    if sum( cidx ) < length( fidx )
        fprintf( 1, '%s: f%d, %d.%d - only %d spikes\n', adate, fnum, shanknum, clunum, sum( cidx ) )
        continue
    end
    % MORPHOLOGICAL STATISTICS
    % isolation quality
    if sum( clus > 1 )
        d2 = mahal( fet( clu ~= 0 & ~cidx, fidx ), fet( cidx, fidx ) );
        sd2 = sort( d2 ); 
        % isolation distance (d2 of N'th closest spike not in cluster)
        if sum( cidx ) < sum( ~cidx & clu ~= 0 )
            id( clunum ) = sd2( sum( cidx ) ); 
        end
        lratio( clunum ) = sum( 1 - chi2cdf( d2, length( fidx ) ) ) / sum( cidx );
    end
    % homogeneity quality
%     % cluster radius (95% percentile of d2 of spike in cluster)
%     d2 = mahal( fet( cidx, fidx ), fet( cidx, fidx ) );
%     sd2 = sort( d2 );
%     r( clunum ) = sd2( ceil( 0.95 * length( d2 ) ) );
    % SNR (max-min in middle third / SD(lateral 2-thirds) / log( length 2/3) )
    snr( clunum, : ) = mean( s( cidx ) );
    % TEMPORAL STATISTICS
    % ISI index (observed vs. expected spikes below ISI1)
    dt = diff( res( cidx ) ) / Fs;
    isi( clunum ) = CF * sum( dt < ISI1 ) / sum( dt < ISI2 );
end

% % PAIRWISE separation measure:
% % go over clusters and compute of all others from the center of that cluster
% for i = clus( clus >= 1 )'
%     Xidx = clu == i;
%     if sum( Xidx ) < length( fidx )
%         fprintf( 1, '%s: f%d, %d.%d - only %d spikes\n', adate, fnum, shanknum, i, sum( Xidx ) )
%         continue
%     end
%     X = fet( Xidx, fidx );
%     for j = clus( clus >= 1 )'
%         Yidx = clu == j;
%         if sum( Yidx ) < length( fidx )
%             fprintf( 1, '%s: f%d, %d.%d - only %d spikes\n', adate, fnum, shanknum, j, sum( Yidx ) )
%             continue
%         end
%         Y = fet( Yidx, fidx );
%         if sum( Yidx ) < sum( Xidx )
%             [ ign select ] = sort( rand( sum( Xidx ), 1 ) * sum( Xidx ) ); 
%             select = select( 1 : sum( Yidx ) );
%             d2 = mahal( Y, X( select, : ) );
%             pwid( i, j ) = max( d2 );
%         else
%             d2 = mahal( Y, X );
%             sd2 = sort( d2 );
%             pwid( i, j ) = sd2( sum( Xidx ) );
%         end
%     end
% end


return

% R < 50 (<45 is better)
% ID > R > 50 (isolation class A/B/C: >55/>50/>45)
% LRATIO < 0.1 (isolation class A/B/C: < 0.05/<0.1<0.15)clus = 1 : max
% ISI < 0.05 (isolation class A/B/C: <0.01/<0.05/<0.1)
% SNR > 3 (homogeneity class A/B/C: >4/>3.5/>3)
% =>
% inclusion criteria:
% loose:  ID > 45/LRATIO < 0.1,  ISI < 0.1,  SNR > 2.25
% medium: ID > 50/LRATIO < 0.05, ISI < 0.05, SNR > 3
% strict: ID > 55/LRATIO < 0.01, ISI < 0.01, SNR > 4
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
[ id, lratio, nums ] = calc_id_clean_spks( '15oct10', 6, 6 );
calc_id_clean_spks( '16oct10', 6, 5 ); % OK; noisy
calc_id_clean_spks( '22oct10', 4, 1 ); % OK; noisy
calc_id_clean_spks( '22oct10', 4, 2 ); % OK; noisy
[ id, lratio, nums ] = calc_id_clean_spks( '17sep10', 6, 2 ); % OK; nice
calc_id_clean_spks( '17sep10', 6, 3 );
calc_id_clean_spks( '22sep10', 4, 2 );
[ id, lratio, nums ] = calc_id_clean_spks( '01nov10', 5, 3 );
calc_id_clean_spks( '01mar11', 12, 4 );


adate = '24oct10';
fnums = 3 : 10; 
shanknum = 2;

% all files together (does not account for non-stationarities):
%[ clus, nums, id, snr, isi, lratio ] = calc_cluster_quality( adate, fnums, shanknum );
%keep.clus = clus; keep.nums = nums; keep.snr = snr; keep.isi = isi; keep.id = id; keep.lratio = lratio;
%[ keep.clus keep.nums keep.snr keep.isi keep.id keep.lratio ]

% file-by-file and then average:
uclus = []; 
for fnum = fnums; 
    [ clus{ fnum }, nums{ fnum }, id{ fnum }, snr{ fnum }, isi{ fnum }, lratio{ fnum } ] = calc_cluster_quality( '24oct10', fnum, shanknum ); 
    uclus = [ uclus; unique( clus{ fnum } ) ];
end
uclus = unique( uclus ); 
uclus = uclus( ~isnan( uclus ) )
aclus = NaN * ones( uclus( end ), 1 ); 
aclus( uclus ) = uclus;
anums = zeros( length( aclus ), length( fnums ) );
aid = anums;
asnr = anums;
aisi = anums;
alratio = anums;
for fnum = fnums
    idx1 = ismember( clus{ fnum }, aclus );
    idx2 = ismember( aclus, clus{ fnum } );
    anums( idx2, fnum ) = nums{ fnum }( idx1, : );
    aid( idx2, fnum ) = id{ fnum }( idx1, : );
    asnr( idx2, fnum ) = snr{ fnum }( idx1, : );
    aisi( idx2, fnum ) = isi{ fnum }( idx1, : );
    alratio( idx2, fnum ) = lratio{ fnum }( idx1, : );
end
nums = sum( anums, 2 );
id = nansum( aid .* anums, 2 ) ./ sum( ~isnan( aid ) .* anums, 2 );
snr = sum( asnr .* anums, 2 ) ./ sum( anums, 2 );
isi = sum( aisi .* anums, 2 ) ./ sum( anums, 2 );
lratio = sum( alratio .* anums, 2 ) ./ sum( anums, 2 );