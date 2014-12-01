function [ delay, ac ] = parameter_autocorrelation( algo, p_arr )
%PARAMETER_AUTOCORRELATION Calculate autocorrelation of parameter samples
%from Markov chain

delay = (0:algo.D);
ac = zeros(size(delay));

for ii = 1:length(delay)
    
    dd = delay(ii);
    
    est_mn = sum(p_arr(algo.B:end))/(algo.R - algo.B);
    est_vr = sum((p_arr(algo.B:end)-est_mn).^2)/(algo.R - algo.B);
    ac(ii) = sum( (p_arr(algo.B+dd+1:end)-est_mn).*(p_arr(algo.B+1:end-dd)-est_mn) )/((algo.R - dd - algo.B)*est_vr);
        
end

end

