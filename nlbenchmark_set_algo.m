% Algorithm parameters

algo.R = 10;                   % Number of MCMC steps
algo.N = 100;                  % Number of particles in PF
algo.M = 100;                   % Number of MH steps used by improved backward-simulation

algo.traje_sampling = 2;        % 1 = standard particle Gibbs
                                % 2 = particle Gibbs with backward-simulation
                                % 3 = particle Gibbs with improved backward-simulation

% First parameter choices for Markov chain
algo.start_param.sigx = 10;
algo.start_param.sigy = 10;

% Hyperparameters for unknown parameter priors
algo.x_shape = 100;             % Gamma shape parameter on 1/sigx
algo.x_scale = 0.01;            % Gamma scale parameter on 1/sigx
algo.y_shape = 100;             % Gamma shape parameter on 1/sigy
algo.y_scale = 0.01;            % Gamma scale parameter on 1/sigy