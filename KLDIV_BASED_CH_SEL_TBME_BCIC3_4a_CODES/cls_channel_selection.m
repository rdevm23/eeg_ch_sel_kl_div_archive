classdef cls_channel_selection
   
    properties (Access = public)
        % dataset_name: It is a flag will have 3 values
        %               a) 1 == for bcic3_4a
        %               b) 2 == for bcic4_2a
        %               c) 3 == for physionet
        dataset_name
        electrode_positions % a struct of array; set in self = import_positions(self)
        all_comb_of_chs % shall be set in min_shunting()
        all_loss_shunting % shall be set in min_dispshunting()
        
    end
    
    %% ===================== PUBLIC METHOD =========================
    methods (Access = public)
        % Functions
        % 1. 
        % 2. 
        function self = cls_channel_selection(dataset_name)
            self.dataset_name = dataset_name;
        end
        
        function self = import_positions(self)
            if self.dataset_name == 1
                table = readtable('ch_loc_bcic3_4a.csv');
                positions = table2array(table);
                [d_max, d_min] = d_max_d_min(self,positions);
                
                self.electrode_positions.pos = positions;
                self.electrode_positions.d_max = d_max;
                self.electrode_positions.d_min = d_min;
            elseif self.dataset_name == 2
                table = readtable('ch_loc_bcic4_2a.csv');
                positions = table2array(table);
                [d_max, d_min] = d_max_d_min(self,positions);
                
                self.electrode_positions.pos = positions;
                self.electrode_positions.d_max = d_max;
                self.electrode_positions.d_min = d_min;
            end
        end
        
        function self = min_shunting(self,n_iter_optimization,n_selected_chs)
            loss_itr = zeros(n_iter_optimization,1);
            
            N = size(self.electrode_positions.pos,1); % no of total channels, will act as max int for the combinations
            k = n_iter_optimization; % no of channels combinations
            p = n_selected_chs; % subset of the channels
            comb_of_chs = combing_all_k(self,N,k,p);
            all_pos = self.electrode_positions.pos;
            
            self.all_comb_of_chs = comb_of_chs; % storing the combinations
            for itr = 1: n_iter_optimization
                
                chs = comb_of_chs(itr,:)';
                positions = all_pos(chs,:);
                loss = loss_function(self,chs,positions);
                loss_itr(itr,1) = loss;
                % disp(itr)
                if mod(itr,10000) == 0
                    fprintf('At iteration %d...\n',k);
                end
            end
            self.all_loss_shunting = loss_itr;
        end
        
        function self = min_shunting_n_clust(self, n_clust)
            
        end
        
        
        function self = min_mutual_info(self)
            
            
            
        end
        
        
        
    end
    % ===============================================================
    
    %% ===================== PRIVATE METHOD =========================
    
    
    
    
    methods (Access = private)
        % Functions
        % 1. loss = loass_function(chs,positions)
        % 2. self = import_positions(self)
        
        
        
        function distri = find_the_distri(self,ch_all_sig)
             
        end
        
        
        
        function loss = loss_function(~,chs,positions)
            
            % chs : selection channels n*1, n is the number of channels
            % positions: positions of all the chs n*dim_of_position
            
            n_channels = size(chs,1);
            if n_channels ~= size(positions,1)
                error("number of chs and position are not same")
            end
            comb = nchoosek(1:n_channels,2); % all two combination of chs
            vect_i = positions(comb(:,1),:);
            vect_j = positions(comb(:,2),:);
            
            loss = 0.5*sum(sum((vect_i-vect_j).^2,2));
            
        end
        
        
        
        function [d_max, d_min] = d_max_d_min(~,positions)
            % positions: all the position of all the channels
            n_chs = size(positions,1);
            comb = nchoosek(1:n_chs,2); % all two combination of chs
            vect_i = positions(comb(:,1),:);
            vect_j = positions(comb(:,2),:);
            diff = 0.5*(sum((vect_i-vect_j).^2,2));
            d_max = max(diff);
            d_min = min(diff);
        end
        
        function output = combing_all_k(~,N,k,p)
            
            % N = 10; % Max integer value the data can have.
            % k = 40; % Number of rows you want in the final output
            % p = 3;  % Number of columns
            % Make a k-by-p array of values from 1 to N
            % Make more rows than we need because we may throw out some if they're duplicates.
            
            
%             output = zeros(k,p);
%             
%             for i = 1:p
%                 
%             end
%             
            
            
            
            
            
            
            rows = 6 * k;
            data = randi(N, rows, p);
            
            
            
            
            
            
            
            
            
            
            % Now we have sample data, and we can begin.....
            % First go down row-by-row throwing out any lines with duplicated numbers like [1, 1, 4]
            goodRows = []; % Keep track of good rows.
            % Bad rows will have unique() be less than the number of elements in the row.
            for row = 1 : rows
                thisRow = data(row, :);
                if length(unique(thisRow)) == length(thisRow)
                    goodRows = [goodRows, row];
                end
            end
            if ~isempty(goodRows)
                data = data(goodRows,:);
            end
            % Sort row-by-row with columns going in ascending order
            [~, sortIndexes] = sort(data, 2);
            % Get the list of rows all scrambled up
            [uniqueRows, ia, ~] = unique(data, 'rows', 'stable');
            % ia is the rows from A that we kept (extracted and stored in uniqueRows).
            % Extract those same rows from sortIndexes so we know how to "unsort" the rows
            sortIndexes2 = sortIndexes(ia,:);
            % Extract the first N rows.
            sortedOutput = uniqueRows(1:k,:);
            % Now "unsort" them if you want to do that.
            output = zeros(size(sortedOutput, 1),p);
            for row = 1 : size(sortedOutput, 1)
                output(row,:) = sortedOutput(row, sortIndexes2(row, :));
            end
            
            
        end

    end
end















