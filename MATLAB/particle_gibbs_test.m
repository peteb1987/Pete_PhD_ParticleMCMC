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
    
    figure, hold on, plot([1 algo.R], sqrt(model.sigx)*ones(1,2), ':k'); plot(sqrt(cat(2,mc_param.sigx))); ylim([0,5]);
    figure, hold on, plot([1 algo.R], sqrt(model.sigy)*ones(1,2), ':k'); plot(sqrt(cat(2,mc_param.sigy))); ylim([0,5]);
    
end
