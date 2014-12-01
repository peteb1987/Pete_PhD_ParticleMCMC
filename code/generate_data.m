function [ state, observ ] = generate_data( model )
%generatedata Generate a data set for the model.

% Initialise arrays
state = zeros(model.ds, model.K);
observ = zeros(model.do, model.K);

% First state
[state(:,1), ~] = model.stateprior(model);

% Loop through time
for kk = 1:model.K
    
    if kk > 1
        [state(:,kk), ~] = model.transition(model, state(:,kk-1));
    end
    
    [observ(:,kk), ~] = model.observation(model, state(:,kk));
    
end

end

