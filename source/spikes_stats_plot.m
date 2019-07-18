% fig = spikes_stats_plot( sst, filebase, varargin )
%
% sst               required. can be a filebase instead, will then load [ filebase '.sst' ]
% filebase          if empty, will use sst.filebase
%
% optional:
% wavemode          {1}, plots using classify_waveform_plot
%                   0: plots using sst.pyr
% showrip           {1}
% showrippow        {0}
% pTH               {[]}
% graphics          {0}
% savetype          {'png'}
% keepGrps          {[]}
% ilevel            {'D'}
% shankclu0         {[]}
% ignoredChannels   {[]}

% 19-sep-13 ES

% revisions
% 10-sep-18 reclassifyWaves to input
%           colormap( myjet )

function [ fig riplevel sst ] = spikes_stats_plot( sst, filebase, varargin )%wavemode, showrip, pTH, graphics )

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% assumptions..
MAXLAG = 0.05;
CCHBS = 0.001;
%savetype = 'png';

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% arguments
nargs = nargin;
if nargs < 1 || isempty( sst )
    return
end
if nargs < 2 
    filebase = [];
end
if isa( sst, 'cell' )
    sst = sst{ 1 };
end
if isa( sst, 'char' ) && exist( fileparts( sst ), 'dir' )
    filebase = sst;
    sst = load( [ sst '.sst' ], '-mat' );
end
if isa( sst, 'struct' ) && isequal( fields( sst ), { 'sst' } )
    sst = sst.sst;
end
if isempty( filebase )
    filebase = sst.filebase;
end
% if nargs < 3 || isempty( wavemode )
%     wavemode = 1;
% end
% if nargs < 4 || isempty( showrip )
%     showrip = 1;
% end
% if nargs < 5 || isempty( pTH )
%     pTH = [];
% end
[ wavemode, showrip, showrippow, pTH, graphics, savetype, keepGrps, ilevel, shankclu0, ignoredChannels, flipSPK, flipLFP, reclassifyWaves, hpfUsed ] = ParseArgPairs(...
    { 'wavemode', 'showrip', 'showrippow', 'pTH', 'graphics', 'savetype', 'keepGrps', 'ilevel', 'shankclu0', 'ignoredChannels', 'flipSPK', 'flipLFP', 'reclassifyWaves', 'hpfUsed' }...
    , { 1, 1, 0, [], 0, 'png', [], 'D', [], [], 0, 0, 1, 0 }...
    , varargin{ : } );


if isempty( filebase )
    pathname = '';
    filename = 'unknown';
else
    if isa( filebase, 'char' ) && exist( fileparts( filebase ), 'dir' )
        [ pathname filename extname ] = fileparts( filebase );
        filename = [ filename extname ];
    elseif isa( sst.filebase, 'char' )
        [ pathname filename extname ] = fileparts( sst.filebase );
        filename = [ filename extname ];
    else
        pathname = '';
        filename = 'unknown';
    end
end
if isempty( pathname )
    figname = '';
else
    delim = strfind( filebase, '/dat/' );
    if isempty( delim ),
        figname = '';
    else
        figdir = [ filebase( 1 : delim ) 'figs' ];
        if ~exist( figdir, 'dir' )
            mkdir( fileparts( figdir ), 'figs' )
        end
        figname = [ figdir '/' filename '.sst' ];
    end
end

% new 21-may-14 - keep only a subset of relevant units:
if isempty( shankclu0 )
    shankclu0 = determine_units( filebase, [], ilevel );
end
sst = struct_select( sst, ismember( sst.shankclu, shankclu0( :, 1 : 2 ), 'rows' ) );



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% corrections for specific formats
swap23 = 0;
swap34 = 0;
% flipLFP = 0;
% flipSPK = 0;
if ismember( filename, { 'm100_1', 'm100_2', 'm101_1', 'm101_2', 'm101_3' } )
    swap34 = 1;
    flipLFP = 1;
    flipSPK = 0; % already flipped in sst file
elseif ismember( filename, { 'm200_1', 'm120_2', 'm201_1', 'm201_2', 'm201_3', 'm705_1', 'm706_1', 'm706_2', 'm706_3', 'm731_1', 'm731_2' } )
    swap23 = 1;
    flipLFP = 1;
    flipSPK = 1; % flipped sst file erroneously!!
elseif ismember( filename, { 'm704_1', 'm704_2', 'm622_1', 'm622_2', 'm624_1', 'm624_2', 'm629_1', 'm763_1', 'm763_2', 'm765_1' } )
    %ismember( filename, { 'm622_1', 'm622_2', 'm624_1', 'm624_2', 'm629_1', 'm704_1', 'm704_2', 'm763_1', 'm763_2', 'm765_1' } )
    flipLFP = 1;
    % August 2013 (except for 200, 201, 705, 706, 731 - 3 shank sessions - which are fine)
    %probe = sort( probe );
    %rprobe = flipud( probe );
    %rprobe = probe;
    % in these dates, the par file is reversed, and so are the site
    % numbers. for instance on shank 1, the order is [ 10 9 8 ... 1 ],
    % where 10 is for some reason the bottom (deepest) site...
    % m100_1: 1/1/2/6 - should be flipped!
elseif ismember( filename, { 'm001_s01', 'm003_s18' } )
    % flipped everything at *xml file for easy visualization... not a good idea!
    flipLFP = 1;
    flipSPK = 1;
elseif ~isempty( strfind( filename, '2009-09-' ) ) ...
        || ~isempty( strfind( filename, '2009-12-' ) ) ...
        || ~isempty( strfind( filename, '2011-04-' ) )
    % sebastien's data
    flipLFP = 1; % in any case - by par file
    flipSPK = 1; % if extracted by me.
    
elseif ~isempty( strfind( filename, 'YutaMouse' ) )
    % yuta's data
    %rprobe = flipud( probe );
    flipLFP = 1;
    flipSPK = 1;
end
%if mstrfind( sst.filebase, { 'm558r2', 'm520r2', 'm520r3',  '12mar12', '17mar12', '25mar12', '13mar12', '18mar12', '23mar12' } )
if mstrfind( sst.filebase, { 'm520r2', 'm520r3',  '12mar12', '13mar12', '18mar12' } )
    pTH0 = 0.1;
    linearize = 1;
    if isempty( keepGrps )
        keepGrps = 1 : 2;
    end
elseif mstrfind( sst.filebase, { '25mar12' } )
    pTH0 = 0.1;
    linearize = 1;
    if isempty( keepGrps )
        keepGrps = 1 : 4;
    end
elseif mstrfind( sst.filebase, { 'm558r2', '17mar12', '23mar12' } )
    pTH0 = 0.1;
    linearize = 1;
    if isempty( keepGrps )
        keepGrps = 1 : 3;
    end
else
    pTH0 = 0.05;
    linearize = 0;
end
if isempty( pTH )
    pTH = pTH0;
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% make some general preps and extensions
nans = isnan( sst.pyr );
if isfield( sst, 'pval' )
    nans( sst.pval > pTH ) = 1;
    sst.pyr = double( sst.pyr );
    sst.pyr( sst.pval > pTH ) = NaN;
end

if isempty( filebase ) || ~exist( pathname, 'dir' )
    riplevel = [];
    return
else
    % get the probe arrangement
    par = LoadXml( filebase );
    %probe = get_probe( par, [], 'keepGrps', keepGrps, 'linearize', 0 );
    probe0 = get_probe( par, [], 'linearize', 0 );
    probe = probe0;
    if ~isempty( keepGrps )
        probe = probe( :, intersect( 1 : size( probe, 2 ), keepGrps ) );
        probe( all( isnan( probe ), 2 ), : ) = [];
    end
    if ~mstrfind( filename, { '16mar12', '24mar12', '28mar12' } )
        probe( :, sum( ~isnan( probe ) ) == 1 ) = []; % remove single-channel 'shanks'
    end
    
    % LFP plot
    rprobe = probe;
    if ~isempty( ignoredChannels )
        rprobe( ismember( rprobe, ignoredChannels ) ) = NaN;
    end
    if linearize
        rprobe = rprobe( : );
        rprobe( isnan( rprobe ) ) = [];
    end
    if flipLFP
        rprobe = flipud( rprobe );
    end
    
    % get the spike locations
    if flipSPK
        x = [ sst.shankclu( :, 1 ) size( probe, 1 ) + 1 - sst.geo_com ];
    else
        x = [ sst.shankclu( :, 1 ) sst.geo_com ];
    end
    
    if ~isempty( keepGrps )
        rmvUnits = ~ismember( x( :, 1 ), keepGrps );
        x( rmvUnits, : ) = [];
    end

    if linearize
        nnans = probe0;
        nnans( :, setdiff( 1 : size( probe0, 2 ), keepGrps ) ) = NaN;
        nnans = ~isnan( nnans ); 
        a = reshape( cumsum( nnans( : ) ), size( nnans ) ); 
        cidx = intersect( 1 : size( probe0, 2 ), keepGrps );
        a = a( 1, : );
        a( 1, cidx ) = a( 1, cidx ) - 1;
        for i = unique( x( :, 1 ) )'
            x( x( :, 1 ) == i, 2 ) = x( x( :, 1 ) == i, 2 ) + a( i );
        end
        x( :, 1 ) = 1;
    end

    % correction for August2013 acute experiments
    if swap23
        % lfp
        rprobe( :, [ 2 3 ] ) = rprobe( :, [ 3 2 ] );
        % spk
        x0 = x;
        x( x0( :, 1 ) == 2, 1 ) = 3;
        x( x0( :, 1 ) == 3, 1 ) = 2;
    end
    if swap34
        % lfp
        rprobe( :, [ 3 4 ] ) = rprobe( :, [ 4 3 ] );
        % spk
        x0 = x;
        x( x0( :, 1 ) == 3, 1 ) = 4;
        x( x0( :, 1 ) == 4, 1 ) = 3;
    end
    
    % reorganize spike locations for linear probes
    if linearize
        grps = 1 : size( probe, 2 );
        kidx = ismember( x( :, 1 ), grps );
        sst = struct_select( sst, kidx );
        x = x( kidx, : );
        for grp = grps( 2 : end )
            idx = x( :, 1 ) == grp;
            x( idx, 2 ) = x( idx, 2 ) + probe( 1, grp ) - probe( 1, 1 );
            x( idx, 1 ) = probe( 1, 1 );
        end
        probe = probe( : );
    end
    
end

fig = figure;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% plot the spike waveforms by classifier. here, use the PV classifier
subplot( 2, 2, 1 ),
if wavemode
    %reclassifyWaves = 1;
    [ ign s ] = classify_waveform_plot( sst, [], [], [], reclassifyWaves, [], hpfUsed );
    % add if was not there
    if ~isfield( sst, 'pval')
        sst.pval = s.pval;
        sst.pyr = double( sst.pyr );
        sst.pyr( sst.pval > pTH ) = NaN;
    end
    nans = isnan( sst.pyr );
else
    subplot( 2, 2, 1 ),
    x = [ sst.tp 1000./sst.fmax ];
    ph = plot( x( sst.pyr == 1, 1 ), x( sst.pyr == 1, 2 ), '.r'...
        , x( sst.pyr == 0, 1 ), x( sst.pyr == 0, 2 ),'.b'...
        , x( nans, 1 ), x( nans, 2 ),'og' );
    if length( ph ) == 3
        set( ph( 3 ), 'color', [ 0 0.7 0 ] )
    end
    %xx = [ 0.1 0.9 ]; yy = [ 0.6 1.4 ];
    xx = minmax( [ x( :, 1 ); [ 0.1 0.9 ]' ] );
    yy = minmax( [ x( :, 2 ); [ 0.6 1.4 ]' ] );
    xlim( xx );
    ylim( yy );
    %     hold on
    %     [ ign ign fsep ] = classify_waveform( [ 1 1 ], 0 );
    %     fh = ezplot( fsep, [ xx yy ] );
    %     set( fh, 'color', [ 0 0 0 ] );
    %     title( '' )
    xlabel( 'Trough-to-peak [ms]' ), ylabel( 'Spike width [ms]' )
    set( gca, 'box', 'off', 'tickdir', 'out' )
end
title( sprintf( 'INT: %d, PYR: %d; unc: %d', sum( sst.pyr == 0 ), sum( sst.pyr == 1 ), sum( nans ) ) )
%title( sprintf( 'all units: INT: %d, PYR: %d', sum( ~sst.pyr ), sum( sst.pyr ) ) )


% subplot( 2, 2, 2 ),
% sstB = struct_select( sst, check_cluster_quality( sst, 'B' ) );
% classify_waveform_plot( sstB );
% title( sprintf( 'class B: INT: %d, PYR: %d', sum( ~sstB.pyr ), sum( sstB.pyr ) ) )

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% plot all ACH, sorted by timing and by cell type
subplot( 2, 2, 3 )
if isfield( sst, 'achbins' )
    achbins = sst.achbins;
else
    achbins = ( -( MAXLAG / CCHBS ) : 1 : ( MAXLAG / CCHBS ) );
end
[ hh ah ] = imagescbar( achbins, 1 : size( sst.nspks )...
    , sst.ach( :, [ find( sst.pyr == 0 ); find( sst.pyr == 1); find( nans ) ] ) );
subplot( ah( 2 ) )%, axis( 'off' )
set( ah( 2 ), 'yticklabel', '' )
alines( [ sum( sst.pyr == 0 ) sum( ~nans ) ] + 0.5, 'y', 'color', [ 1 0 0 ] );
set( ah( 2 ), 'box', 'off', 'tickdir', 'out' )
subplot( ah( 1 ) )
xlabel( 'Time lag [ms]' ), ylabel( 'Unit #' ), title( 'ACH' )
alines( [ sum( sst.pyr == 0 ) sum( ~nans ) ] + 0.5, 'y', 'color', [ 1 0 0 ] );
set( ah( 1 ), 'box', 'off', 'tickdir', 'out' )

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% plot all firing rate stats, sorted in the same manner as the ACHs
subplot( 2, 2, 4 )
[ hh ah ] = imagescbar( [ 1 : size( sst.frateb, 1 ) ] / size( sst.frateb, 1 )...
    , 1 : size( sst.nspks )...
    , sst.frateb( :, [ find( sst.pyr == 0 ); find( sst.pyr == 1 ); find( nans ) ] ) );
subplot( ah( 2 ) )%, axis( 'off' )
set( ah( 2 ), 'yticklabel', '' )
set( ah( 2 ), 'box', 'off', 'tickdir', 'out' )
alines( [ sum( sst.pyr == 0 ) sum( ~nans ) ] + 0.5, 'y', 'color', [ 1 0 0 ] );
subplot( ah( 1 ) )
xlabel( 'Session time' ), ylabel( 'Unit #' ), title( 'Firing rate' )
alines( [ sum( sst.pyr == 0 ) sum( ~nans ) ] + 0.5, 'y', 'color', [ 1 0 0 ] );
set( ah( 1 ), 'box', 'off', 'tickdir', 'out' )

textf( 0.5, 0.975, replacetok( filebase, '\_', '_' ) );


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% plot all firing rate stats, sorted in the same manner as the ACHs

subplot( 2, 2, 2 )

% add the ripple profile (flipped if needed. the sst should always be proper!)
if showrip && exist( [ filebase '.sps' ], 'file' )
    sps = load( [ filebase '.sps' ], '-mat' );
    if swap23
        sps.vote( [ 2 3 ] ) = sps.vote( [ 3 2 ] );
    end
    if swap34
        sps.vote( [ 3 4 ] ) = sps.vote( [ 4 3 ] );
    end
    %     [ riplevel shanknum ] = find( ismember( rprobe, sps.vote ) );
    %     ripPow = sps.stats( ismember( sps.stats( :, 2 ), rprobe( ismember( rprobe, sps.vote ) ) ), 7 );
    [ riplevel0 shanknum ] = find( ismember( rprobe, sps.vote ) );
    
    if showrippow
        mSD = NaN * ones( size( rprobe ) );
        for i = 1 : numel( probe ), 
            if isnan( rprobe( i ) )
                continue
            end
            ripsI( i ) = plotHFOs( filebase, rprobe( i ) );
            mSD( i ) = mean( ripsI( i ).sd ); 
        end
        imagesc( mSD )
        axis xy
        hcolorbar( [], 0 );
        colormap( myjet )
        hold on
    end
%    mSD = flipud( reshape( mSD, size( probe ) ) );
    if isempty( shanknum )
        riplevel = [];
    else
        if linearize
            riplevel = riplevel0;
            shanknum = ones( size( riplevel ) );
            xrip = 1 + [ -1 1 ] * 0.5;
            for i = 1 : length( riplevel )
                patch_band( xrip, riplevel( i ) * ones( 1, 2 ), 0.5 * ones( size( 1, 2 ) ), [ 0 0.7 0 ] );
            end
        else
            riplevel = 0 * ones( max( shanknum ), 1 );
            riplevel( shanknum ) = riplevel0;
            
            ripPow0 = sps.stats( ismember( sps.stats( :, 2 ), rprobe( ismember( rprobe, sps.vote ) ) ), 7 );
            ripPow = 0 * ones( max( shanknum ), 1 );
            ripPow( shanknum ) = ripPow0;
            
            %     if flipAll
            %         riplevel = size( rprobe, 1 ) + 1 - riplevel;
            %     end
            %[ yrip xrip ] = connectdots( 2 * [ 0.5 1 : size( probe, 2 ) size( probe, 2 ) + 0.5 ], [ NaN riplevel( : )' NaN ] );
            %[ yrip xrip ] = connectdots( 2 * [ 0.5 1 : length( shanknum ) length( shanknum ) + 0.5 ], [ NaN riplevel( : )' NaN ] );
            [ yrip xrip ] = connectdots( 2 * [ 0.5 1 : max( shanknum ) max( shanknum ) + 0.5 ], [ NaN riplevel( : )' NaN ] );
            xrip = xrip / 2;
            %yrip( ismember( xrip, bsxfun( @plus, find( riplevel == 0 ), ( -0.5 : 0.5 : 0.5 ) ) ) ) = NaN;
            
            % win = triang( 3 );
            % win = win / sum( win );
            % riplevel = firfilt( riplevel, win );
            % line( xrip, yrip + 0.5, 'color', [ 0 0 0 ] );
            % line( xrip, yrip - 0.5, 'color', [ 0 0 0 ] );
            %
            %patch_band( xrip, yrip, 0.5 * ones( size( yrip ) ), [ 0 0.7 0 ] );
            ripPowHat = clipmat( ripPow - 5, 0, inf ) / 2;
            ripPowHat( isnan( ripPowHat ) ) = 0;
            sd = connectdots( 2 * [ 0.5 1 : max( shanknum ) max( shanknum ) + 0.5 ], [ NaN ripPowHat( : )' NaN ] );
            sd = clipmat( sd, 0, inf );
            %         sd = zeros( size( xrip ) );
            %         sd( ismember( yrip, riplevel ) ) = ripPowHat;
            %         sd( sd == 0 ) = min( sd( ismember( yrip, riplevel ) ) );
            %sd = 10 * ( sd - min( sd ) );
            patch_band( xrip, yrip, sd, [ 0 0.7 0 ] );
        end
        riplevel = [ shanknum riplevel0 ];
    end
else
    riplevel = [];
end

%hold on
% plot the probe:
for i = 1 : size( probe, 2 )
    shank = probe( :, i );
    % plot the shank
    shank = 1 : length( shank );
    xx = [ i - 0.2 i i + 0.2 i + 0.2 i - 0.2 ];
    yy = [ min( shank ) + [ 0.5 -1 0.5 ] max( shank ) + 0.5 * [ 1 1 ] ];
    lh( i ) = line( xx( [ 1 : end 1 ] ), yy( [ 1 : end 1 ] ), 'linestyle', '--', 'color', [ 0 0 0 ] );
    % add the rec sites
    dx = repmat( [ 0.1 -0.1 ]', [ ceil( length( shank ) / 2 ) 1 ] );
    dx = dx( 1 : min( [ length( dx ) length( shank ) ] ) );
    line( i + dx, shank( : ), 'marker', '.', 'linestyle', 'none', 'markersize', 20, 'color', [ 0 0 0 ] );
end
% plot the units
%ph0 = plot( x( pidx == 0, 1 ) - 0.1, x( pidx == 0, 2 ) - 0.1, 'ob' );
%ph1 = plot( x( pidx == 1, 1 ) + 0.1, x( pidx == 1, 2 ) + 0.1, 'vr' );
pidx = sst.pyr;
if ~isempty( keepGrps )
    pidx( rmvUnits, : ) = [];
    nans( rmvUnits, : ) = [];
end

line( x( pidx == 0, 1 ) - 0.1, x( pidx == 0, 2 ) - 0.1, 'marker', 'o', 'linestyle', 'none', 'markersize', 12, 'color', [ 0 0   0.7 ] );
line( x( pidx == 1, 1 ) + 0.1, x( pidx == 1, 2 ) + 0.1, 'marker', 'v', 'linestyle', 'none', 'markersize', 12, 'color', [ 1 0   0   ] );
line( x( nans, 1 ) + 0,      x( nans, 2 ) + 0,      'marker', 'x', 'linestyle', 'none', 'markersize', 12, 'color', [ 1 0 1   ] );
% limits
ylim( [ -1 size( probe, 1 ) + 1 ] )
xlim( [ 0 size( probe, 2 ) + 1 ] )
% xlim( minmax( x( :, 1 ) ) + 0.5 * [ -1 1 ] )
% ylim( minmax( x( :, 2 ) ) + 0.5 * [ -1 1 ] )
axis off
if isfield( sst, 'opttag' )
    tidx = sst.opttag;
    colorLight = [ 1 0 1 ];
    line( x( tidx == 1 & pidx == 0, 1 ) - 0.1, x( tidx == 1 & pidx == 0, 2 ) - 0.1, 'marker', 'o', 'linestyle', 'none', 'markersize', 16, 'color', colorLight );
    line( x( tidx == 1 & pidx == 1, 1 ) + 0.1, x( tidx == 1 & pidx == 1, 2 ) + 0.1, 'marker', 'v', 'linestyle', 'none', 'markersize', 16, 'color', colorLight );
    line( x( tidx == 1 & nans, 1 ) + 0,        x( tidx == 1 & nans, 2 ) + 0,        'marker', 'o', 'linestyle', 'none', 'markersize', 12, 'color', colorLight );
end

colormap( myjet )
%%%%%%%%%%
if graphics && ~isempty( figname ) && ~all( isnan( savetype ) )
    fig_out( fig, 1, [ figname '.' savetype ], savetype );
end

return

% EOF

sstB = struct_select( sst, check_cluster_quality( sst, 'B' ) );

spikes_stats_plot( struct_select( sst, check_cluster_quality( sst, 'B' ) ), filebase );


