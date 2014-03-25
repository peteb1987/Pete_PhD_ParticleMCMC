function [ mc ] = particle_metropolishastings( fh, display, algo, known, observ )
%PARTICLE_METROPOLISHASTINGS Run particle MMH algorithm to estimate parameters and
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
param_prior = feval(fh.paramprior, algo, known, param);

% Merge known and unknown parameters
model = catstruct(known, param);

if display.text
    fprintf(1, 'Markov chain iteration 1.\n');
    t0 = cputime;
end

% Run particle filter
pf = pf_standard(fh, algo, model, observ);
lhood = sum([pf.marg_lhood]);

% Sample a trajectory
[traje, bess] = sample_trajectory(fh, algo, model, pf, observ);

% Store
mc.param(1) = param;
mc.traje(1) = traje;
mc.bess{1} = bess;

% Counter
acc_count = 0;

% Markov chain
for rr = 2:algo.R
    
    if display.text
        fprintf(1, '     Iteration took %fs.\n', cputime-t0);
        fprintf(1, 'Markov chain iteration %u.\n', rr);
        t0 = cputime;
    end
    
    % Propose new parameters
    [ppsl_param, ppsl_forw_prob, ppsl_back_prob] = feval(fh.paramproposal, algo, known, param, traje, observ);
    ppsl_param_prior = feval(fh.paramprior, algo, known, ppsl_param);
    
    % Merge known and unknown parameters
    ppsl_model = catstruct(known, ppsl_param);
    
    % Run conditional particle filter
    pf = pf_standard(fh, algo, ppsl_model, observ);
    
    % Calculate probabilities
    ppsl_lhood = sum([pf.marg_lhood]);

    % Calculate MH acceptance probability
    ap = (ppsl_lhood - lhood)...
         + sum(ppsl_param_prior - param_prior)...
         - sum(ppsl_forw_prob - ppsl_back_prob);
    
    % Accept?
    if log(rand) < ap
        
        param = ppsl_param;
        lhood = ppsl_lhood;
    
        % Sample a trajectory
        [traje, bess] = sample_trajectory(fh, algo, model, pf, observ);
        
        acc_count = acc_count + 1;
        
    end
    
    % Store
    mc.param(rr) = param;
    mc.traje(rr) = traje;
    mc.bess{rr} = bess;
    
end

mc.acc_count = acc_count;

if display.text
    fprintf(1, '     Iteration took %fs.\n', cputime-t0);
    fprintf(1, 'Markov chain complete.\n');
end

end

