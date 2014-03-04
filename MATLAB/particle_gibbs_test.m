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
    test.model = 2;
    test.algorithms = [1 2 3];
    
    % DEFINE RANDOM SEED
    rand_seed = 0;
    
    % Function handles
    if test.model == 1
        
        addpath('nlbenchmark');
        
        fh.model = 'nlbenchmark_setmodel';
        fh.algo = 'nlbenchmark_setalgo';
        fh.gendata = 'nlbenchmark_generatedata';
        fh.stateprior = 'nlbenchmark_stateprior';
        fh.transition = 'nlbenchmark_transition';
        fh.observation = 'nlbenchmark_observation';
        fh.stateproposal = 'nlbenchmark_stateproposal';
        fh.paramconditional = 'nlbenchmark_paramconditional';
        
    elseif test.model == 2
        
        addpath('tracking')
        
        fh.model = 'tracking_setmodel';
        fh.algo = 'tracking_setalgo';
        fh.gendata = 'tracking_generatedata';
        fh.stateprior = 'tracking_stateprior';
        fh.transition = 'tracking_transition';
        fh.observation = 'tracking_observation';
        fh.stateproposal = 'tracking_stateproposal';
        fh.paramconditional = 'tracking_paramconditional';
        
    end
    
    
    % Set model and algorithm parameters
    [model, known] = feval(fh.model, test);
    algo = feval(fh.algo, test, known);
    
    % Set display options
    display.text = true;
    display.plot = true;
    
end

%% Generate some data

rng(rand_seed);
[state, observ] = feval(fh.gendata, model);


%% Run samplers

num_algs = length(test.algorithms);
mc_param = cell(num_algs,1);
mc_state = cell(num_algs,1);
rt = zeros(num_algs,1);

for aa = 1:num_algs

    algo.traje_sampling = test.algorithms(aa);

    rng(rand_seed);

    tic;
    [mc_param{aa}, mc_state{aa}] = particle_gibbs(fh, display, algo, known, observ);
    rt(aa) = toc;

end

%% Evaluation

if (~test.batch) && display.plot
    
    for aa = 1:num_algs
        
        fields = fieldnames(mc_param{aa});
        
        % Loop through parameters
        for ii = 1:length(fields)
            
            p = fields{ii};
            
            % Get chain values and truth
            p_arr = cat(2,mc_param{aa}.(p));
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
    
end
