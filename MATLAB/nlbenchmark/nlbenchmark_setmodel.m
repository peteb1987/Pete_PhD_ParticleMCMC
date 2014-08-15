function [ model, known ] = nlbenchmark_set_model( test )

% Model parameters

model.K = 100;      % Number of time points
model.ds = 2;       % Dimension of the states
model.do = 1;       % Dimension of the observations

% Parameters
model.beta1 = 0.5;
model.beta2 = 25;
model.beta3 = 8;
model.alpha = 2;
model.sigx = 1;
model.sigy = 10;

% x1 distribution
model.x1_mn = 0;
model.x1_vr = 5;

% Names
model.param_names = {'sigx', 'beta1', 'beta2', 'beta3', 'sigy', 'alpha'};

% Known parameters
% known = rmfield(model, {'beta1', 'beta2', 'beta3', 'sigx'});
known = rmfield(model, {'sigx', 'sigy'});
% known = rmfield(model, {'beta1', 'beta2', 'beta3', 'alpha'});
% known = rmfield(model, {'sigx', 'beta1', 'beta2', 'beta3', 'sigy', 'alpha'});

end
