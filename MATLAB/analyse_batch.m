%%
num_tests = 5;
num_rpts = 5;

test_names = {...
    'PGtests_1_100_',...
    'PGtests_1_200_',...
    'PGtests_2_100_',...
    'PGtests_2_200_',...
    'PGtests_3_100_'};



%%
close all
rr = 5;
for tt = 1:num_tests
    
    load(['test_results\' test_names{tt} num2str(rr)]);
    
    for aa = 1:length(mc)
        
        fields = fieldnames(mc{1}.param);
        
        % Loop through parameters
        for ii = 1:length(fields)
            
            p = fields{ii};
            
            % Get chain values and truth
            p_arr = cat(2,mc{aa}.param.(p));
            p_true = model.(p);
            
            if any(strcmp(p, {'sigx', 'sigy'}))
                p_arr = sqrt(p_arr);
                p_true = sqrt(p_true);
            end
            
            % Calculate autocorrelation
            [ delay, ac ] = parameter_autocorrelation( algo, p_arr );
            
            % Plot things
            figure, hold on, plot([1 algo.R], p_true*ones(1,2), ':k'); plot(p_arr); title(p);
            if algo.R > algo.burn_in
                figure, hold on, hist(p_arr(algo.burn_in+1:end),30); title(p);
                figure, hold on, plot([delay(1) delay(end)], [0 0]); plot(delay, ac); title(p); ylim([0 1]);
            end
            
        end
        
    end
end

%%
for tt = 1:num_tests
    for rr = 1:num_rpts
        
        name = ['test_results/' test_names{tt} num2str(num_tests*(rr-1)+1)];
        load(name);
        
        
        
    end
end

