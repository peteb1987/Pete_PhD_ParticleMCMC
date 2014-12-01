function [ A, Q, R ] = autoregressive_AQR( model )
%TRACKING_AQ

A = [model.arcoefs;
     eye(model.ds-1), zeros(model.ds-1,1)];

Q = zeros(model.ds);
Q(1,1) = model.sigx;

R = model.sigy;

end

