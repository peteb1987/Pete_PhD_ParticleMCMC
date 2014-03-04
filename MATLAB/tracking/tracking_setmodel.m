function [ model, known ] = tracking_setmodel( test )

% Model parameters

% Using a 3D near constant velocity model and a
% bearing-elevation-range-rangerate observation model.

%%%%%%%%%%%%%%%%

% General things
model.K = 100;                  % Number of time points
model.ds = 6;                   % Dimension of the state
model.do = 3;                   % Dimension of the observations

model.T = 1;                          % Sampling period

% Parameters
model.sigx = 1;
model.decay = 0.02;                     % Motion decay
model.sigtheta = ( 1*(pi/180) )^2;   % Bearing covariance %0.25;5;
model.sigphi   = ( 1*(pi/180) )^2;   % Elevation covariance
model.sigr     = 1^2;                  % Range covariance %0.1;100
model.bias = 10;                           % Range bias

% x1 distribution
model.x1_mn = [-100 50 50 10 0 0]';
model.x1_vr = diag([10 10 10 1 1 1]);


% Names
model.param_names = {'sigx', 'decay', 'sigtheta', 'sigphi', 'sigr', 'bias'};

% Known parameters
% known = rmfield(model, {'sigx', 'decay', 'sigtheta', 'sigphi', 'sigr', 'bias'});
known = rmfield(model, {'sigx'});
% known = rmfield(model, {'bias'});
% known = rmfield(model, {'sigr'});
% known = model;


end
