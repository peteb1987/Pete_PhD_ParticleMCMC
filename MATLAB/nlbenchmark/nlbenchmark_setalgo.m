function [ algo ] = nlbenchmark_set_algo( test, known )

% Algorithm parameters

algo.proposal = 2;              % 1 = bootstrap, 2 = alternative
algo.R = 100;                   % Number of MCMC steps
algo.N = 10;                    % Number of particles in PF
algo.M = 10;                    % Number of MH steps used by improved backward-simulation

algo.traje_sampling = 3;        % 1 = standard particle Gibbs
                                % 2 = particle Gibbs with backward-simulation
                                % 3 = particle Gibbs with improved backward-simulation
algo.use_MH_with2 = false;      % If true, and traje_sampling==2, use MH to sample backwards weights
                                
algo.burn_in = 50;             % Length of burn in period in samples
algo.max_ac_delay = min(algo.R-algo.burn_in,100);    % maximum delay for autocorrelation calculation

% First parameter choices for Markov chain
if ~isfield(known, 'sigx'), algo.start_param.sigx = 2; end
if ~isfield(known, 'beta1'), algo.start_param.beta1 = 0.4; end
if ~isfield(known, 'beta2'), algo.start_param.beta2 = 20; end
if ~isfield(known, 'beta3'), algo.start_param.beta3 = 6; end
if ~isfield(known, 'sigy'), algo.start_param.sigy = 11; end
if ~isfield(known, 'alpha'), algo.start_param.alpha = 1.8; end

% MH proposal parameters
algo.alpha_ppsl_vr = 0.004;     % Proposal density variance for alpha

% Hyperparameters for unknown parameter priors
algo.x_shape = 100;             % Gamma shape parameter on 1/sigx
algo.x_scale = 0.01;            % Gamma scale parameter on 1/sigx
algo.y_shape = 10;             % Gamma shape parameter on 1/sigy
algo.y_scale = 0.01;            % Gamma scale parameter on 1/sigy
algo.alpha_min = 1;             % Uniform minimum paramter for alpha
algo.alpha_max = 3;             % Uniform maximum paramter for alpha

end
