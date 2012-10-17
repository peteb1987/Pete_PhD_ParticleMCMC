% Algorithm parameters

algo.R = 50;                   % Number of MCMC steps
algo.N = 100;                  % Number of particles in PF
algo.M = 6;                   % Number of MH steps used by improved backward-simulation

algo.traje_sampling = 3;        % 1 = standard particle Gibbs
                                % 2 = particle Gibbs with backward-simulation
                                % 3 = particle Gibbs with improved backward-simulation
                                
algo.burn_in = 10;             % Length of burn in period in samples
algo.max_ac_delay = min(algo.R-algo.burn_in,100);    % maximum delay for autocorrelation calculation

% First parameter choices for Markov chain
algo.start_param.sigx = 10;
algo.start_param.sigy = 10;

% Hyperparameters for unknown parameter priors
algo.x_shape = 100;             % Gamma shape parameter on 1/sigx
algo.x_scale = 0.01;            % Gamma scale parameter on 1/sigx
algo.y_shape = 100;             % Gamma shape parameter on 1/sigy
algo.y_scale = 0.01;            % Gamma scale parameter on 1/sigy