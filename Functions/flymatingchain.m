function [ chains ] = flymatingchain( inter_fly_dist_allvid_sorted, n_arenas, FPS, settings_file )
%flymatingchain finds the episodes of copulations and calculate their
%lengths
%   Detailed explanation goes here

% Determine the distance threshold of copulations
% copulation_dist_threshold = settings_file{15};
% copulation_dist_threshold = str2double(copulation_dist_threshold(strfind(copulation_dist_threshold, ',')+1:end));
copulation_dist_threshold = settings_file.data(10);

% Determine the time threshold of a chain break
% chain_break_threshold = settings_file{16};
% chain_break_threshold = str2double(chain_break_threshold(strfind(chain_break_threshold, ',')+1:end));
chain_break_threshold = settings_file.data(11);

% Determine the time threshold of a chain
% chain_length_thresh_min = settings_file{17};
% chain_length_thresh_min = str2double(chain_length_thresh_min(strfind(chain_length_thresh_min, ',')+1:end));
chain_length_thresh_min = settings_file.data(12);

% Prime the chain cell
chains = cell( n_arenas , 1 );

for arena_num = 1 : n_arenas
    % Find the frames in which the distance threshold passes
    threshed_frames=find(inter_fly_dist_allvid_sorted(:,arena_num)<copulation_dist_threshold);
    
    % Find all the chain starts using the chain break threshold
    chain_start_indices = find( [ 99 ; diff(threshed_frames ) ] > chain_break_threshold + 1 );
    
    % Find where the chains could stop
    chain_stop_indices = [ chain_start_indices( 2 : end) - 1 ; length( threshed_frames ) ];
    
    % Translate the chains to frame numbers
    chain_start = threshed_frames( chain_start_indices );
    chain_stop=threshed_frames(chain_stop_indices);
    
    % Find the chains that are sufficiently long
    chain_start_true = chain_start( chain_stop - chain_start >= chain_length_thresh_min * 60 * FPS );
    chain_stop_true = chain_stop( chain_stop - chain_start >= chain_length_thresh_min * 60 * FPS );
    
    % Output the chains in terms of time
    chains{ arena_num } = [ chain_start_true / FPS / 60 , chain_stop_true / FPS / 60 ];
end

end

