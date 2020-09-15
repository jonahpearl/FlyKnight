function flyprint( inter_fly_dist_allvid_sorted, chains, nframe_allvid,...
    num_vids, n_arenas, FPS, nframe_allvid_cell, printresult, filename,...
    export_path, settings_file, PC_or_not )
% flyprint prints the interfly distances


disp('==================================')
disp('Plotting and Saving Data')

% Determine the distance threshold of copulations
% copulation_dist_threshold = settings_file{15};
% copulation_dist_threshold = str2double(copulation_dist_threshold(strfind(copulation_dist_threshold, ',')+1:end));
copulation_dist_threshold = settings_file.data(10);

% Find out how big the final plot is
% final_print_position = settings_file{18};
% final_print_position = str2num(final_print_position(strfind(final_print_position, ',')+1:end)); %#ok<ST2NM>
final_print_position = settings_file.textdata{18,2};
final_print_position = str2num(final_print_position);

% Label the video lengths with a line
vid_cut_off_lbls = cell2mat( nframe_allvid_cell );
vid_cut_off_lbls = vid_cut_off_lbls * tril( ones( str2double( num_vids{ 1 } ) ) )' / FPS / 60;

if printresult == 1
    % Subplot plan
    subplot_plan = [8 4 2];
    
    % Use plots_left to keep track of how many arenas are left to plot
    plots_left = n_arenas;
    
    
    for plot_num = 1 : ceil( n_arenas / subplot_plan( 1 ) )
        % Initiate the figure
        figure(101)
        set(gcf,'Position',final_print_position);
        
        % Go through the subplots
        for subplot_num = 1 : min( subplot_plan(1) , plots_left)
            
            % Subplot
            subplot( subplot_plan(2) , subplot_plan(3) , subplot_num)
            
            % Make the interfly distance plot
            plot( ( 1 : nframe_allvid ) / FPS / 60 , inter_fly_dist_allvid_sorted( : , ( plot_num - 1 ) * subplot_plan( 1 ) + subplot_num ) , '-' );
            
            % Determine if there is a chain
            if  sum( sum( chains{ ( plot_num - 1 ) * subplot_plan( 1 ) + subplot_num } ) ) > 0
                hold on
                
                % Plot each chain individually
                for chain_ind = 1 : size( chains{ ( plot_num - 1 ) * subplot_plan( 1 ) + subplot_num } , 1 )
                    
                    % Plot chain
                    plot( chains{ ( plot_num - 1 ) * subplot_plan( 1 ) + subplot_num }( chain_ind , : ) , [ copulation_dist_threshold, copulation_dist_threshold ] , 'r-' )
                    
                    % Write its length
                    text( 1 + ( chain_ind - 1 ) * 20 , 0.9 ,...
                        [ num2str( round( 10 * ( chains{ ( plot_num-1 ) * subplot_plan( 1 ) + subplot_num }( chain_ind , 2 ) -...
                        chains{ ( plot_num - 1 ) * subplot_plan( 1 ) + subplot_num }( chain_ind,1 ) ) ) / 10) , ' min' ] )
                end
                hold off
                
            end
            
            % Make the video transition lines
            hold on
            for vid_cutoff_ind = 1 : str2double( num_vids{ 1 } ) - 1
                plot( [ vid_cut_off_lbls( vid_cutoff_ind ) , vid_cut_off_lbls( vid_cutoff_ind ) ] , [0 1] , 'g' )
            end
            hold off
            
            % label y-axis
            ylabel('Inter-Fly Distance (cm)')
            
            %xlim([0 100])
            ylim([0 1])
            
            % Label subplot title
            title( [ filename( 1 : end - 5 ) , 'Arena ' , num2str( ( plot_num - 1 ) * subplot_plan( 1 ) + subplot_num ) ] )

        end
        
        % tighten the figure up
        tightfig;
        
        % Reset the position
        set(gcf,'Position',final_print_position,'Color',[1 1 1])
        
        % Refresh the number of plots left to do
        plots_left=plots_left-subplot_plan(1);
        
        % Print the figure
        if PC_or_not
            export_fig( fullfile( export_path, [ filename( 1 : end - 6 ) , '.pdf' ] ) , '-append' )
        else
            saveas(101,fullfile( export_path, [ filename( 1 : end - 5 ) , num2str(plot_num) , '.pdf' ] ) )
        end
        
        close 101
    end
end

end