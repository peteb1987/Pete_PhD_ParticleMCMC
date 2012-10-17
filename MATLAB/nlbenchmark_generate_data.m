function [ state, observ ] = nlbenchmark_generate_data( model )
%NLBENCHMARK_GENERATE_DATA Generate data according to the benchmark
%nonlinear model

% Initialise arrays
state = zeros(1,model.K);
observ = zeros(1,model.K);

% First state
[state(1), ~] = nlbenchmark_stateprior(model);

% Loop through time
for kk = 1:model.K
    
    if kk > 1
        [state(kk), ~] = nlbenchmark_transition(model, kk-1, state(kk-1));
    end
    
    [observ(kk), ~] = nlbenchmark_observation(model, state(kk));
    
end

end

