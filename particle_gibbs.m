function [ mc_param, mc_traje ] = particle_gibbs( display, algo, known, observ )
%PARTICLE_GIBBS Run particle gibbs algorithm to estimate parameters and
%states from observations.

mc_param = nlbenchmark_paramarray(algo.R);
mc_traje = nlbenchmark_trajearray(algo.R);

% Sample unknown parameters from prior
param = algo.start_param;

% Merge known and unknown parameters
model = 

% Run particle filter
pf = pf_standard(algo, known, param, observ);

% Sample a trajectory
traje = sample_trajectory(algo, known, param, observ);

% Store
mc_param(1) = param;
mc_traje(1) = traje;

% Markov chain
for rr = 1:algo.R
    
    if display.text
        fprintf(1, 'Markov Chain Iteration %u.', rr);
    end
    
    % Sample parameters
    param = nlbenchmark_paramconditional(algo, known, param, traje);
    
    % Run conditional particle filter
    pf = pf_conditional(algo, known, param, observ, traje);
    
    % Sample a trajectory
    traje = sample_trajectory(algo, known, param, observ);
    
    % Store
    mc_param(rr) = param;
    mc_traje(rr) = traje;
    
end

end

