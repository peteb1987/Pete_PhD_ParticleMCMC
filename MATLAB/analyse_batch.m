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
rr = 1;
for tt = 1:num_tests
    
    load(['test_results/' test_names{tt} num2str(rr)]);
    
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
rr = 1;
colors = 'kkbgr';
for tt = 3:5
    
    name = ['test_results/' test_names{tt} num2str(rr)];
    load(name);
    
    p = 'sigx';
    
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
    max_it = 200;
    figure(1), hold on, plot(p_arr(1:max_it), 'color', colors(tt));
    figure(2), hold on, plot(delay, ac, 'color', colors(tt)); ylim([0 1]);
    figure, hold on, hist(p_arr(algo.burn_in+1:end),100); plot(p_true*ones(1,2), [0 200], ':k');
    
end

figure(1)
plot([1 max_it], p_true*ones(1,2), ':k'); 
xlabel('Iteration Number')
ylabel('Parameter Value')
legend({'PG-BS (N=100)', 'PG-BS (N=200)', 'PG-RBS (N=100)'});
matlab2tikz('figurehandle', gcf, ...
    'filename', 'chain_init.tikz', ...
    'height', '5cm', ...
    'width', '5cm', ...
    'parseStrings', false);

figure(2)
plot([delay(1) delay(end)], [0 0]); 
xlabel('Offset')
ylabel('Sample Autocorrelation')
legend({'PG-BS (N=100)', 'PG-BS (N=200)', 'PG-RBS (N=100)'});
matlab2tikz('figurehandle', gcf, ...
    'filename', 'acf_plot.tikz', ...
    'height', '5cm', ...
    'width', '5cm', ...
    'parseStrings', false);

figure(3)
xlabel('Parameter Value')
matlab2tikz('figurehandle', gcf, ...
    'filename', 'hist_PGBS_100.tikz', ...
    'height', '5cm', ...
    'width', '5cm', ...
    'parseStrings', false);

figure(4)
xlabel('Parameter Value')
matlab2tikz('figurehandle', gcf, ...
    'filename', 'hist_PGBS_200.tikz', ...
    'height', '5cm', ...
    'width', '5cm', ...
    'parseStrings', false);

figure(5)
xlabel('Parameter Value')
matlab2tikz('figurehandle', gcf, ...
    'filename', 'hist_PGRBS_100.tikz', ...
    'height', '5cm', ...
    'width', '5cm', ...
    'parseStrings', false);

tt = 2;
name = ['test_results/' test_names{tt} num2str(rr)];
load(name);

p = 'sigx';

% Get chain values and truth
p_arr = cat(2,mc{aa}.param.(p));
p_true = model.(p);

if any(strcmp(p, {'sigx', 'sigy'}))
    p_arr = sqrt(p_arr);
    p_true = sqrt(p_true);
end
figure, hold on, plot(p_arr(1:max_it), 'b');
plot([1 max_it], p_true*ones(1,2), ':k'); 
xlabel('Iteration Number')
ylabel('Parameter Value')
legend({'PG (N=200)'});
matlab2tikz('figurehandle', gcf, ...
    'filename', 'chain_init_PG_200.tikz', ...
    'height', '5cm', ...
    'width', '5cm', ...
    'parseStrings', false);