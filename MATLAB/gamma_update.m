function [ shape, scale ] = gamma_update( shape, scale, errors )
%GAMMA_UPDATE Find posterior shape and scale parameters of a gamma
%distribution given an array of Gaussian errors

K = length(errors);

shape = shape + K/2;
scale = 1/( 1/scale + 0.5*sum( errors.^2 ) );

end

