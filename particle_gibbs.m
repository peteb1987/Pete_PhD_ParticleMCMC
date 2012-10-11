function [ mc_param, mc_traje ] = particle_gibbs( display, algo, known, observ )
%PARTICLE_GIBBS Run particle gibbs algorithm to estimate parameters and
%states from observations.

mc_param = nlbenchmark_paramarray(known, algo.R);
mc_traje = nlbenchmark_trajearray(known, algo.R);

if display.text
    fprintf(1, 'Markov chain iteration 1.\n');
    tic
end

% Sample unknown parameters from prior
param = algo.start_param;

% Merge known and unknown parameters
model = catstruct(known, param);

% Run particle filter
pf = pf_standard(algo, model, observ);

% Sample a trajectory
traje = sample_trajectory(algo, model, pf, observ);

% Store
mc_param(1) = param;
mc_traje(1) = traje;

% Plot
if display.plot
    figure(display.h_pf(1)); clf;
    hold on;
    plot(traje.state(1,:), 'b');
    drawnow; pause(0.1);
end

% Markov chain
for rr = 2:algo.R
    
    if display.text
        fprintf(1, '     Iteration took %fs.\n', toc);
        fprintf(1, 'Markov chain iteration %u.\n', rr);
        tic
    end
    
    % Sample parameters
    param = nlbenchmark_paramconditional(algo, known, param, traje, observ);
    
    % Merge known and unknown parameters
    model = catstruct(known, param);
    
    % Run conditional particle filter
    pf = pf_conditional(algo, model, observ, traje);
    
    % Sample a trajectory
    traje = sample_trajectory(algo, model, pf, observ);
    
    % Store
    mc_param(rr) = param;
    mc_traje(rr) = traje;
    
    % Plot
    if display.plot
        figure(display.h_pf(rem(rr+1,2)+1)); clf;
        hold on;
        plot(traje.state(1,:), 'b');
        drawnow; pause(0.1);
    end
    
end

if display.text
    fprintf(1, '     Iteration took %fs.\n', toc);
    fprintf(1, 'Markov chain complete.\n');
end

end

