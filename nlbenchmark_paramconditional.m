function [ param ] = nlbenchmark_paramconditional( algo, known, param, traje, observ )
%NLBENCHMARK_PARAMCONDITIONAL Sample parameters conditional upon states for
%the nonlinear benchmark when the two variances are unknown

% Calculate transition state means
k_vec = 1:known.K-1;
x_mn = known.beta1 * traje.state(:,1:known.K-1) ...
     + known.beta2 * (traje.state(:,1:known.K-1)./(1+traje.state(:,1:known.K-1).^2)) ...
     + known.beta3 * cos(1.2*k_vec);

% Calculate parameters of posterior gamma distribution (on 1/sigx)
x_shape = algo.x_shape + (known.K-1)/2;
x_scale = 1/( 1/algo.x_scale + 0.5*sum( (traje.state(2:known.K) - x_mn).^2 ) );

% Sample
param.sigx = 1/gamrnd(x_shape, x_scale);

% Calculate observation means
y_mn = 0.05 * abs(traje.state).^known.alpha;

% Calculate parameters of posterior gamma distribution (on 1/sigx)
y_shape = algo.y_shape + known.K/2;
y_scale = 1/( 1/algo.y_scale + 0.5*sum( (observ - y_mn).^2 ) );

% Sample
param.sigy = 1/gamrnd(y_shape, y_scale);

end

