function [ true_model, known_model ] = set_model_autoregressive( test )

% Model parameters

% Autoregressive model

%%%%%%%%%%%%%%%%

% General things
true_model.K = 100;                  % Number of time points
true_model.ds = 5;                   % Dimension of the state
true_model.do = 1;                   % Dimension of the observations
true_model.dn = 1;                   % Rank of the state covariance matrix/
                                     % dimension of the noise variables

% Parameters
true_model.sigx = 1^2;              % State variance
true_model.sigy = 0.5^2;              % Observation variance
true_model.arcoefs = [0.9 -0.8 0.7 -0.6 0.5];
true_model.sat = 0.5;                 % Saturation level
true_model.dof = 3;                 % Degrees of freedom of observation noise (student-t)

% x1 distribution
true_model.x1_mn = zeros(true_model.ds,1);
true_model.x1_vr = 3*eye(true_model.ds);

% Names
true_model.param_names = {'sigx', 'sigy', 'arcoefs', 'sat', 'dof'};

% Function Handles
addpath('autoregressive')
true_model.stateprior = @autoregressive_stateprior;
true_model.transition = @autoregressive_transition;
true_model.observation = @autoregressive_observation;
true_model.stateproposal = @autoregressive_stateproposal;
true_model.paramconditional = @autoregressive_paramconditional;
true_model.paramproposal = @autoregressive_paramproposal;
true_model.paramprior = @autoregressive_paramprior;
true_model.blockproposal = @autoregressive_blockproposal;

% Known parameters
% known_model = rmfield(true_model, {'sat'});
known_model = true_model;

% First parameter choices for Markov chain
known_model.start_param = struct;
if ~isfield(known_model, 'sigx'), known_model.start_param.sigx = 4; end
if ~isfield(known_model, 'sigy'), known_model.start_param.sigy = 4; end
if ~isfield(known_model, 'arcoefs'), known_model.start_param.arcoefs = zeros(1,true_model.ds); end
if ~isfield(known_model, 'sat'), known_model.start_param.sigy = 1; end
if ~isfield(known_model, 'dof'), known_model.start_param.sigy = 1; end

% MH proposal parameters
known_model.ppsl_sigx_vr = 0.05;

% Hyperparameters for unknown parameter priors
known_model.sigx_shape = 1/1000;
known_model.sigx_scale = 1000;
known_model.sigy_shape = 1/1000;
known_model.sigy_scale = 1000;
known_model.bias_mn = zeros(1,true_model.ds);
known_model.bias_vr = eye(true_model.ds);

end
