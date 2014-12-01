function [ true_model, known_model ] = set_model_tracking( test )

% Model parameters

% Using a 3D near constant velocity model and a
% bearing-elevation-range-rangerate observation model.

%%%%%%%%%%%%%%%%

% General things
true_model.K = 100;                  % Number of time points
true_model.ds = 6;                   % Dimension of the state
true_model.do = 3;                   % Dimension of the observations

true_model.T = 1;                          % Sampling period

% Parameters
true_model.sigx = 1;
true_model.decay = 0.02;                     % Motion decay
true_model.sigtheta = ( 1*(pi/180) )^2;   % Bearing covariance %0.25;5;
true_model.sigphi   = ( 1*(pi/180) )^2;   % Elevation covariance
true_model.sigr     = 1^2;                  % Range covariance %0.1;100
true_model.bias = 10;                           % Range bias

% x1 distribution
true_model.x1_mn = [-100 50 50 10 0 0]';
true_model.x1_vr = diag([10 10 10 1 1 1]);

% Names
true_model.param_names = {'sigx', 'decay', 'sigtheta', 'sigphi', 'sigr', 'bias'};

% Function Handles
addpath('tracking')
true_model.stateprior = @tracking_stateprior;
true_model.transition = @tracking_transition;
true_model.observation = @tracking_observation;
true_model.stateproposal = @tracking_stateproposal;
true_model.paramconditional = @tracking_paramconditional;
true_model.paramproposal = @tracking_paramproposal;
true_model.paramprior = @tracking_paramprior;

% Known parameters
% known = rmfield(model, {'sigx', 'decay', 'sigtheta', 'sigphi', 'sigr', 'bias'});
known_model = rmfield(true_model, {'sigx'});
% known = rmfield(model, {'bias'});
% known = rmfield(model, {'sigr'});
% known = model;

% First parameter choices for Markov chain
if ~isfield(known_model, 'sigx'), known_model.start_param.sigx = 2; end
if ~isfield(known_model, 'decay'), known_model.start_param.decay = 0.05; end
if ~isfield(known_model, 'sigtheta'), known_model.start_param.sigtheta = ( 4*(pi/180) )^2; end
if ~isfield(known_model, 'sigphi'), known_model.start_param.sigphi = ( 4*(pi/180) )^2; end
if ~isfield(known_model, 'sigr'), known_model.start_param.sigr = 0.1; end
if ~isfield(known_model, 'bias'), known_model.start_param.bias = 0; end

% MH proposal parameters
known_model.ppsl_sigx_vr = 0.05;

% Hyperparameters for unknown parameter priors
known_model.sigx_shape = 1/1000;
known_model.sigx_scale = 1000;
known_model.bias_mn = 0;
known_model.bias_vr = 10^2;
known_model.sigr_shape = 1;
known_model.sigr_scale = 1;

end
