% Base script for running particle MCMC algorithms

% Structures
% display - display options while running
% algo - algorithm parameters
% model - model parameters
% known - known model parameters

%% Set Up

if ~exist('flags.batch', 'var') || (~flags.batch)
    
    clup
    dbstop if error
    % dbstop if warning
    
    % DEFINE RANDOM SEED
    rand_seed = 0;
    
    % Set random seed
    s = RandStream('mt19937ar', 'seed', rand_seed);
    RandStream.setDefaultStream(s);
    
    % Set flag to non-batch
    flags.batch = false;
    
    % Set model and algorithm parameters
    nlbenchmark_set_model;
    nlbenchmark_set_algo;
    
    % Set display options
    display.text = true;
    display.plot_during = false;
    if display.plot_during
        display.h_pf(1) = figure;
        display.h_pf(2) = figure;
    end
    display.plot_after = true;
    
    
end

%% Generate some data
[state, observ] = nlbenchmark_generate_data(model);

%% Run the particle MCMC algorithm
[mc_param, mc_state] = particle_gibbs(display, algo, known, observ);

%% Evaluation

%% Plot graphs

if (~flags.batch) && display.plot_after
    
    fields = fieldnames(mc_param);
    
    % Loop through parameters
    for ii = 1:length(fields)
        
         p = fields{ii};
        
        % Get chain values
        p_arr = cat(2,mc_param.(p));
        
        % Plot things
        figure, hold on, plot([1 algo.R], model.(p)*ones(1,2), ':k'); plot(p_arr); title(p);
        figure, hold on, hist(p_arr(algo.burn_in+1:end),30); title(p);
        
    end
    
end
