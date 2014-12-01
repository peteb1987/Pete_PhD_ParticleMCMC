% Base test script for running particle MCMC algorithms

% Structures
% test - test configuration variables
% display - display options while running
% algo - algorithm parameters
% model - model parameters
% known - known model parameters

%% Set Up

if ~exist('test', 'var') || ~isfield(test,'batch') || (~test.batch)
    
    clup
    dbstop if error
    % dbstop if warning
    
    test.batch = false;

    %%%%%% TEST SETTINGS %%%%%%
    % Model?
    test.model_flag = 2;        % 1=tracking, 2=autoregressive
    
    % Define algorithms to run. Make sure these are all the same length
    test.mcmc_type = [1];
    test.ppsl_type = [1];
    test.ref_traj_type = [4];
    test.anc_samp_type = [NaN];
    test.filter_particles = [20];
    
    test.num_mc_iterations = 5000;
    
    % Set display options
    display.text = true;
    display.plot = true;
    
    % Filename
    filenameroot = 'PGBS_AR';
    
    % Random seed
    rand_seed = 1;
    %%%%%%%%%%%%%%%%%%%%%%%%%%%
    
end

% Set up model
if test.model_flag == 1
    [true_model, known_model] = set_model_tracking;
elseif test.model_flag == 2
    [true_model, known_model] = set_model_autoregressive;
end

%% Generate some data
rng(rand_seed+100000); % DON'T USE THE SAME SEED TO GENERATE DATA AS TO RUN ALGORITHMS
[state, observ] = generate_data(true_model);

if display.plot
    
    if test.model_flag == 1
        figure, hold on, plot(state(1,:), state(2,:))
        figure, hold on, plot(hypot(state(3,:), state(4,:)))
        drawnow;
        pause(0.1);
    elseif test.model_flag == 2
        figure, hold on, plot(state(1,:)), plot(observ, 'r')
        drawnow;
        pause(0.1);
    end
end

%% Run samplers
num_algs = length(test.mcmc_type);
mc = cell(num_algs,1);
rt = zeros(num_algs,1);

for aa = 1:num_algs
    
    rng(rand_seed);
    
    % Algorithm paramters
    algo = set_algo(test.mcmc_type(aa), ...
                    test.ref_traj_type(aa), ...
                    test.anc_samp_type(aa), ...
                    test.ppsl_type(aa), ...
                    test.filter_particles(aa), ...
                    test.num_mc_iterations);
    
    % Run it
    t0 = cputime;
    if algo.mcmc_type == 1
        [mc{aa}] = particle_gibbs_backward_simulation(display, algo, known_model, observ);
    elseif algo.mcmc_type == 2
        [mc{aa}] = particle_metropolishastings(display, algo, known_model, observ);
    elseif algo.mcmc_type == 3
        [mc{aa}] = particle_gibbs_ancestor_sampling(display, algo, known_model, observ);
    end
    rt(aa) = cputime-t0;
    
    % Save results
    mc_aa = mc{aa};
    if num_algs > 1
        filename = [filenameroot '_' num2str(aa) '.mat'];
    else
        filename = filenameroot;
    end
    save(filename, 'rand_seed', 'display', 'test', 'algo', ...
        'true_model', 'known_model', ...
        'state', 'observ', 'mc_aa');

end

%% Evaluation

if (~test.batch) && display.plot
    
    for aa = 1:length(mc)
        
        fields = fieldnames(mc{1}.param);
        
        % Loop through parameters
        for ii = 1:length(fields)+1
            
            % Get chain values and truth
            if ii <= length(fields)
                p = fields{ii};
                p_arr = cat(2,mc{aa}.param.(p));
                p_true = true_model.(p);
            else
                p = 'chosen state';
                p_arr = [mc{aa}.state1{:}];
                p_true = state(:,algo.which_state);
            end
            
            % Calculate autocorrelation
            [ delay, ac ] = parameter_autocorrelation_onedimensional( algo, p_arr(1,:) );
            
            % Plot things
            figure, hold on, plot([1 algo.R], p_true*ones(1,2), ':k'); plot(p_arr'); title(p);
            if algo.R > algo.B
                figure, hold on, hist(p_arr(1,algo.B+1:end),30); title(p);
                figure, hold on, plot([delay(1) delay(end)], [0 0], 'k', 'linewidth', 2); plot(delay, ac(1,:)); title(p);
            end
            
        end
        
    end
    
    figure, hold on
    for aa = 1:length(mc)
        plot(mean(cat(1,mc{aa}.bess{:}),1),'linewidth',2,'color',0.5+0.5*[rand rand rand]);
    end
    
    figure, hold on
    for aa = 1:length(mc)
        plot(mean(cat(1,mc{aa}.change{:}),1),'linewidth',2,'color',0.5+0.5*[rand rand rand]);
    end
    
end
