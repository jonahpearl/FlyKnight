%% Knight Initiation
%
% Label the processing as in batch-processing mode
Knightmode = 1;

% Run through each experiment
for knight_index = 1 : size( run_list , 1 )
    % Get the file name
    filename = run_list{ knight_index , 1 };
    
    % Get the filepath
    filepath = run_list{ knight_index , 2 };
    
    % Get the number of videos
    num_vids = run_list{ knight_index , 3 };
    
    % Get the manual crop indices
    cropindex1_manual = run_list{ knight_index , 4 }( 1 );
    cropindex2_manual = run_list{ knight_index , 4 }( 2 );
    cropindex3_manual = run_list{ knight_index , 4 }( 3 );
    cropindex4_manual = run_list{ knight_index , 4 }( 4 );
    
    % Run fly master
    flymaster
end
%}
