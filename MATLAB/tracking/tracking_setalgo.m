function [ algo ] = tracking_setalgo( test, known )

% Algorithm parameters

algo.proposal = 2;              % 1 = bootstrap, 2 = alternative
algo.R = 5000;                   % Number of MCMC steps
algo.N = 100;                    % Number of particles in PF
algo.M = 20;                    % Number of MH steps used by improved backward-simulation

algo.traje_sampling = 3;        % 1 = standard particle Gibbs
                                % 2 = particle Gibbs with backward-simulation
                                % 3 = particle Gibbs with improved backward-simulation
algo.use_MH_with2 = false;      % If true, and traje_sampling==2, use MH to sample backwards weights
algo.use_MH_with3 = false;      % If true, and traje_sampling==3, use MH to sample backwards weights
                                
algo.burn_in = 1000;             % Length of burn in period in samples
algo.max_ac_delay = min(algo.R-algo.burn_in,100);    % maximum delay for autocorrelation calculation

% First parameter choices for Markov chain
if ~isfield(known, 'sigx'), algo.start_param.sigx = 2; end
if ~isfield(known, 'decay'), algo.start_param.decay = 0.05; end
if ~isfield(known, 'sigtheta'), algo.start_param.sigtheta = ( 4*(pi/180) )^2; end
if ~isfield(known, 'sigphi'), algo.start_param.sigphi = ( 4*(pi/180) )^2; end
if ~isfield(known, 'sigr'), algo.start_param.sigr = 0.1; end
if ~isfield(known, 'bias'), algo.start_param.bias = 0; end
if ~isfield(algo, 'start_param'), algo.start_param = struct; end

% MH proposal parameters

% Hyperparameters for unknown parameter priors
algo.sigx_shape = 1;
algo.sigx_scale = 1;
algo.bias_mn = 0;
algo.bias_vr = 10^2;
algo.sigr_shape = 1;
algo.sigr_scale = 1;

end
