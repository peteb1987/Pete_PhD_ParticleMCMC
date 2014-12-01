function [ y_mn ] = autoregressive_h( model, x )
%autoregressive_h Deterministic observation function. Saturation on first
%state only

y_mn = tanh(model.sat * x(1))/model.sat;

end
