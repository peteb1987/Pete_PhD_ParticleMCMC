% Model parameters

model.K = 500;      % Number of time points

% Parameters
model.beta1 = 0.5;
model.beta2 = 25;
model.beta3 = 8;
model.alpha = 2;
model.sigx = 10;
model.sigy = 1;

% x1 distribution
model.x1_mn = 0;
model.x1_vr = 5;




% Known parameters
known.K = model.K;
known.beta1 = model.beta1;
known.beta2 = model.beta2;
known.beta3 = model.beta3;
known.alpha = model.alpha;
known.sigx = model.sigx;
known.sigy = model.sigy;