function [ mc_param, mc_traje ] = particle_gibbs( fh, display, algo, known, observ )
%PARTICLE_GIBBS Run particle gibbs algorithm to estimate parameters and
%states from observations.

% Initialise array for parameters in Markov chain
mc_param = repmat(struct, algo.R, 1);
for pp = 1:length(known.param_names)
    if ~isfield(known, known.param_names{pp})
        [mc_param.(known.param_names{pp})] = deal(0);
    end
end

% Initialse array for state trajectories
mc_traje = struct('state', cell(algo.R,1), 'index', cell(algo.R,1), 'weight', cell(algo.R,1));

% Sample unknown parameters from prior
param = algo.start_param;

% Merge known and unknown parameters
model = catstruct(known, param);

if display.text
    fprintf(1, 'Markov chain iteration 1.\n');
    tic
end

% Run particle filter
pf = pf_standard(fh, algo, model, observ);

% Sample a trajectory
traje = sample_trajectory(fh, algo, model, pf, observ);

% Store
mc_param(1) = param;
mc_traje(1) = traje;

% Markov chain
for rr = 2:algo.R
    
    if display.text
        fprintf(1, '     Iteration took %fs.\n', toc);
        fprintf(1, 'Markov chain iteration %u.\n', rr);
        tic
    end
    
    % Sample parameters
    param = feval(fh.paramconditional, algo, known, param, traje, observ);
    
    % Merge known and unknown parameters
    model = catstruct(known, param);
    
    % Run conditional particle filter
    pf = pf_conditional(fh, algo, model, observ, traje);
    
    % Sample a trajectory
    traje = sample_trajectory(fh, algo, model, pf, observ);
    
    % Store
    mc_param(rr) = param;
    mc_traje(rr) = traje;
    
end

if display.text
    fprintf(1, '     Iteration took %fs.\n', toc);
    fprintf(1, 'Markov chain complete.\n');
end

end

