function [ delay, ac ] = parameter_autocorrelation( algo, p_arr )
%PARAMETER_AUTOCORRELATION Calculate autocorrelation of parameter samples
%from Markov chain

delay = (0:algo.max_ac_delay);
ac = zeros(size(delay));

for ii = 1:length(delay)
    
    dd = delay(ii);
    
    est_mn = sum(p_arr(algo.burn_in:end))/(algo.R - algo.burn_in);
    est_vr = sum((p_arr(algo.burn_in:end)-est_mn).^2)/(algo.R - algo.burn_in);
    ac(ii) = sum( (p_arr(algo.burn_in+dd+1:end)-est_mn).*(p_arr(algo.burn_in+1:end-dd)-est_mn) )/((algo.R - dd - algo.burn_in)*est_vr);
        
end


end

