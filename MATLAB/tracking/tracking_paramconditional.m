function [ param ] = tracking_paramconditional( algo, known, param, traje, observ )
%TRACKING_PARAMCONDITIONAL Sample parameters conditional upon states for
%the tracking model

state = traje.state;
K = known.K;

if isfield(known, 'sigx'), sigx = known.sigx; else sigx = param.sigx; end
if isfield(known, 'decay'), decay = known.decay; else decay = param.decay; end
if isfield(known, 'sigtheta'), sigtheta = known.sigtheta; else sigtheta = param.sigtheta; end
if isfield(known, 'sigphi'), sigphi = known.sigphi; else sigphi = param.sigphi; end
if isfield(known, 'sigr'), sigr = known.sigr; else sigr = param.sigr; end
if isfield(known, 'bias'), bias = known.bias; else bias = param.bias; end


if ~isfield(known, 'sigx')
    
    a = decay;
    T = known.T;
    
    A = [exp(-a*T) 0 0 (1-exp(-a*T))/a 0 0;
         0 exp(-a*T) 0 0 (1-exp(-a*T))/a 0;
         0 0 exp(-a*T) 0 0 (1-exp(-a*T))/a;
         0 0 0 1 0 0;
         0 0 0 0 1 0;
         0 0 0 0 0 1 ];
    
    Q = [T^3/3  0      0      T^2/2  0      0    ;
         0      T^3/3  0      0      T^2/2  0    ;
         0      0      T^3/3  0      0      T^2/2;
         T^2/2  0      0      T      0      0    ;
         0      T^2/2  0      0      T      0    ;
         0      0      T^2/2  0      0      T    ];
    
    state_diff = state(:,2:K) - A*state(:,1:K-1);
    state_factor = 0;
    for kk = 1:K-1
        state_factor = state_factor + state_diff(:,kk)'*(Q\state_diff(:,kk));
    end
    
    sigx_shape = algo.sigx_shape + 0.5*known.ds*(K-1);
    sigx_scale = 1/( 1/algo.sigx_scale + 0.5*state_factor);
    
    sigx = 1/gamrnd(sigx_shape, sigx_scale);
    param.sigx = sigx;
    
end

if ~isfield(known, 'decay')
end

if ~isfield(known, 'sigtheta')
end

if ~isfield(known, 'sigphi')
end

if ~isfield(known, 'sigr')

    r = sqrt( state(1,:).^2 + state(2,:).^2 + state(3,:).^2 );
    dr = observ(3,:) - r - bias;

    sigr_shape = algo.sigr_shape + K/2;
    sigr_scale = 1/(1/algo.sigr_scale + 0.5*sum(dr.^2));

    sigr = 1/gamrnd(sigr_shape, sigr_scale);
    param.sigr = sigr;

end

if ~isfield(known, 'bias')
    
    r = sqrt( state(1,:).^2 + state(2,:).^2 + state(3,:).^2 );
    dr = observ(3,:) - r;
    
    bias_vr = 1/( K/sigr + 1/algo.bias_vr );
    bias_mn = bias_vr * sum(dr)/sigr;
    
    % Sample
    bias = mvnrnd(bias_mn, bias_vr);
    param.bias = bias;
    
end

end

