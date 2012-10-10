% Algorithm parameters

algo.R = 100;                   % Number of MCMC steps
algo.N = 100;                   % Number of particles in PF

algo.traje_sampling = 1;        % 1 = standard particle Gibbs
                                % 2 = particle Gibbs with backward-simulation
                                % 3 = particle Gibbs with improved backward-simulation

% First parameter choices for Markov chain
algo.start_param.sigx = 10;
algo.start_param.sigy = 10;