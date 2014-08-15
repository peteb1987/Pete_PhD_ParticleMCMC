function [ param ] = nlbenchmark_paramconditional( algo, known, param, traje, observ )
%NLBENCHMARK_PARAMCONDITIONAL Sample parameters conditional upon states for
%the nonlinear benchmark when the two variances are unknown

state = traje.state(1,:);
K = known.K;

if isfield(known, 'beta1'), beta1 = known.beta1; else beta1 = param.beta1; end
if isfield(known, 'beta2'), beta2 = known.beta2; else beta2 = param.beta2; end
if isfield(known, 'beta3'), beta3 = known.beta3; else beta3 = param.beta3; end
if isfield(known, 'alpha'), alpha = known.alpha; else alpha = param.alpha; end
if isfield(known, 'sigx'), sigx = known.sigx; else sigx = param.sigx; end
if isfield(known, 'sigy'), sigy = known.sigy; else sigy = param.sigy; end
    

if ~isfield(known, 'beta1')
    
    k_vec = 1:K-1;
    
    z1 = state(1:K-1);
    u1 = state(2:K) - beta2*(state(1:K-1)./(1+state(1:K-1).^2)) - beta3*cos(1.2*k_vec);
    
    sumzsquared = sum(z1.^2);
    sumztimesu = sum(z1.*u1);
    beta1_mn = sumztimesu/sumzsquared;
    beta1_vr = sigx/sumzsquared;
    
    % Sample
    beta1 = mvnrnd(beta1_mn, beta1_vr);
    param.beta1 = beta1;
    
end

if ~isfield(known, 'beta2')
    
    k_vec = 1:K-1;
    
    z2 = (state(1:K-1)./(1+state(1:K-1).^2));
    u2 = state(2:K) - beta1*state(1:K-1) - beta3*cos(1.2*k_vec);
    
    sumzsquared = sum(z2.^2);
    sumztimesu = sum(z2.*u2);
    beta2_mn = sumztimesu/sumzsquared;
    beta2_vr = sigx/sumzsquared;
    
    % Sample
    beta2 = mvnrnd(beta2_mn, beta2_vr);
    param.beta2 = beta2;
    
end

if ~isfield(known, 'beta3')
    
    k_vec = 1:K-1;
    
    z3 = cos(1.2*k_vec);
    u3 = state(2:K) - beta1*state(1:K-1) - beta2*(state(1:K-1)./(1+state(1:K-1).^2));
    
    sumzsquared = sum(z3.^2);
    sumztimesu = sum(z3.*u3);
    beta3_mn = sumztimesu/sumzsquared;
    beta3_vr = sigx/sumzsquared;
    
    % Sample
    beta3 = mvnrnd(beta3_mn, beta3_vr);
    param.beta3 = beta3;
    
end

if ~isfield(known, 'alpha')
    
    % Calculate old probability
    y_mn = 0.05 * abs(state).^alpha;
    old_errors = observ - y_mn;
    old_sumerrorssquared = sum(old_errors.^2);
    old_prob = loggausspdf(0,old_sumerrorssquared,sigy);
    
    % Propose a new value of alpha
    ppsl_alpha = -inf;
    while (ppsl_alpha < algo.alpha_min)||(ppsl_alpha > algo.alpha_max)
        ppsl_alpha = mvnrnd(alpha, algo.alpha_ppsl_vr);
    end
    
    % Calculate new probability
    y_mn = 0.05 * abs(state).^ppsl_alpha;
    new_errors = observ - y_mn;
    new_sumerrorssquared = sum(new_errors.^2);
    new_prob = loggausspdf(0,new_sumerrorssquared,sigy);
    
    % Acceptance probability
    ap = new_prob - old_prob;
    if log(rand) < ap
        alpha = ppsl_alpha;
        param.alpha = alpha;
    end
    
end

if ~isfield(known, 'sigx')
    
    % Calculate transition state means
    k_vec = 1:K-1;
    x_mn = beta1 * state(:,1:K-1) ...
         + beta2 * (state(:,1:K-1)./(1+state(:,1:K-1).^2)) ...
         + beta3 * cos(1.2*k_vec);
    errors = state(2:K) - x_mn;
    
    [x_shape, x_scale] = gamma_update(algo.x_shape, algo.x_scale, errors);
    
    % Sample
    param.sigx = 1/gamrnd(x_shape, x_scale);
    
end

if ~isfield(known, 'sigy')
    
    % Calculate observation means
    y_mn = 0.05 * abs(state).^alpha;
    errors = observ - y_mn;
    
    [y_shape, y_scale] = gamma_update(algo.y_shape, algo.y_scale, errors);
    
    % Sample
    param.sigy = 1/gamrnd(y_shape, y_scale);
    
end

end

