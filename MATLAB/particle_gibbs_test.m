% Base script for running particle MCMC algorithms

% Structures
% display - display options while running
% algo - algorithm parameters
% model - model parameters
% known - known model parameters

%% Set Up

if ~exist('flags.batch', 'var') || (~test.batch)
    
    clup
    dbstop if error
    % dbstop if warning
    
    % Flags
    test.batch = false;
    test.model = 1;
    
    % DEFINE RANDOM SEED
    rand_seed = 0;
    
    % Function handles
    if test.model == 1
        
        addpath('nlbenchmark');
        
        fh.model = 'nlbenchmark_set_model';
        fh.algo = 'nlbenchmark_set_algo';
        fh.gendata = 'nlbenchmark_generate_data';
        fh.stateprior = 'nlbenchmark_stateprior';
        fh.transition = 'nlbenchmark_transition';
        fh.observation = 'nlbenchmark_observation';
        fh.stateproposal = 'nlbenchmark_stateproposal';
        fh.paramconditional = 'nlbenchmark_paramconditional';
        
    elseif test.flag_model == 2
        
        addpath('tracking')
        
    end

    
    % Set model and algorithm parameters
    [model, known] = feval(fh.model, test);
    algo = feval(fh.algo, test, known);
    
    % Set display options
    display.text = true;
    display.plot = true;
    
end

%% Generate some data

% Set random seed
rng(rand_seed);

[state, observ] = feval(fh.gendata, model);

%% Run the particle MCMC algorithm

% Set random seed
rng(rand_seed);

[mc_param, mc_state] = particle_gibbs(fh, display, algo, known, observ);

%% Evaluation

%% Plot graphs

if (~test.batch) && display.plot
    
    fields = fieldnames(mc_param);
    
    % Loop through parameters
    for ii = 1:length(fields)
        
         p = fields{ii};
        
        % Get chain values and truth
        p_arr = cat(2,mc_param.(p));
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
            figure, hold on, plot([delay(1) delay(end)], [0 0]); plot(delay, ac); title(p);
        end
        
    end
    
end
