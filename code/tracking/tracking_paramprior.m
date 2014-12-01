function [ prob ] = tracking_paramprior(  algo, known, param )
%TRACKING_PARAMPRIOR Evaluate probabilites for parameter
%priors

if isfield(known, 'sigx'), sigx = known.sigx; else sigx = param.sigx; end
if isfield(known, 'decay'), decay = known.decay; else decay = param.decay; end
if isfield(known, 'sigtheta'), sigtheta = known.sigtheta; else sigtheta = param.sigtheta; end
if isfield(known, 'sigphi'), sigphi = known.sigphi; else sigphi = param.sigphi; end
if isfield(known, 'sigr'), sigr = known.sigr; else sigr = param.sigr; end
if isfield(known, 'bias'), bias = known.bias; else bias = param.bias; end

prob = zeros(length(fieldnames(param)));

if ~isfield(known, 'sigx')
    
    prob = log( gampdf(1/sigx, known.sigx_shape, known.sigx_scale) );
    
end

if ~isfield(known, 'decay')
end

if ~isfield(known, 'sigtheta')
end

if ~isfield(known, 'sigphi')
end

if ~isfield(known, 'sigr')
end

if ~isfield(known, 'bias')

end

end

