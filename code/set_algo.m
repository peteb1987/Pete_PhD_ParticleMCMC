function [ algo ] = set_algo( mcmc, ref_traj, anc_samp, ppsl_type, N, R )
%SET_ALGO

% Algorithm options
algo.mcmc_type = mcmc;              % 1 = particle Gibbs, 2 = PMMH
algo.pf_proposal_type = ppsl_type;  % 1 = bootstrap, 2 = alternative
algo.ref_traj_type = ref_traj;      % 1 = standard particle Gibbs
                                    % 2 = particle Gibbs with backward-simulation
                                    % 3 = particle Gibbs with improved backward-simulation
algo.anc_samp_type = anc_samp;      % 2 = ordinary ancestor sampling
                                    % 3 = improved ancestor sampling

% Algorithm parameters
algo.R = R;                             % Number of MCMC steps
algo.N = N;                             % Number of particles in PF          
algo.L = 5-1;                           % Number of simultaneous states for backward simulation
algo.B = floor(R/5);                    % Length of burn in period in samples
algo.D = min((algo.R-algo.B)/2,100);    % maximum delay for autocorrelation calculation

algo.which_state = 1;          % State time index to keep for evaluation

end

