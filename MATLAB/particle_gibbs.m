function [ mc ] = particle_gibbs( fh, display, algo, known, observ )
%PARTICLE_GIBBS Run particle gibbs algorithm to estimate parameters and
%states from observations.

% Initialise array for parameters in Markov chain
mc.param = repmat(struct, algo.R, 1);
mc.bess =  cell(algo.R, 1);
for pp = 1:length(known.param_names)
    if ~isfield(known, known.param_names{pp})
        [mc.param.(known.param_names{pp})] = deal(0);
    end
end

% Initialse array for state trajectories
mc.traje = struct('state', cell(algo.R,1), 'index', cell(algo.R,1), 'weight', cell(algo.R,1));

% Sample unknown parameters from prior
param = algo.start_param;

% Merge known and unknown parameters
model = catstruct(known, param);

if display.text
    fprintf(1, 'Markov chain iteration 1.\n');
    t0 = cputime;
end

% Run particle filter
pf = pf_standard(fh, algo, model, observ);

% Sample a trajectory
[traje, bess] = sample_trajectory(fh, algo, model, pf, observ);

% Store
mc.param(1) = param;
mc.traje(1) = traje;
mc.bess{1} = bess;

% Markov chain
for rr = 2:algo.R
    
    if display.text
        fprintf(1, '     Iteration took %fs.\n', cputime-t0);
        fprintf(1, 'Markov chain iteration %u.\n', rr);
        t0 = cputime;
    end
    
    % Sample parameters
    param = feval(fh.paramconditional, algo, known, param, traje, observ);
    
    % Merge known and unknown parameters
    model = catstruct(known, param);
    
    % Run conditional particle filter
    pf = pf_conditional(fh, algo, model, observ, traje);
    
    % Sample a trajectory
    [traje, bess] = sample_trajectory(fh, algo, model, pf, observ);
    
    % Store
    mc.param(rr) = param;
    mc.traje(rr) = traje;
    mc.bess{rr} = bess;
    
end

if display.text
    fprintf(1, '     Iteration took %fs.\n', cputime-t0);
    fprintf(1, 'Markov chain complete.\n');
end

end

