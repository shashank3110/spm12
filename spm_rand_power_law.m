function [y] = spm_rand_power_law(csd,Hz,dt,N)
% generates random variates with a power law spectral density
% FORMAT [y] = spm_rand_power_law(csd,Hz,dt,N)
% G   - spectral densities (one per row)
% Hz  - frequencies
% dt  - sampling interval
% N   - number of time bins
%
% see also: spm_rand_mar; spm_Q
%__________________________________________________________________________
% Copyright (C) 2012 Wellcome Trust Centre for Neuroimaging
 
% Karl Friston
% $Id: spm_rand_power_law.m 5892 2014-02-23 11:00:16Z karl $
 

% create random process
%==========================================================================

% create AR representation and associated convolution kernels
%--------------------------------------------------------------------------
p     = fix(length(Hz) - 1);
for i = 1:size(csd,2);
    ccf    = spm_csd2ccf(csd(:,i),Hz,dt);
    mar    = spm_ccf2mar(ccf,p);
    A      = [1 -mar.a'];
    P      = spdiags(ones(N,1)*A,-(0:p),N,N);
    y(:,i) = P\randn(N,1)*sqrt(max(ccf));    
end

return

% cNB: alternative scheme - create random process
%==========================================================================
[m n] = size(G);
w     = (0:(N - 1))/dt/N;
dHz   = Hz(2) - Hz(1);
g     = zeros(N,n);
for i = 1:m
    j      = find(w > Hz(i),1);
    s      = sqrt(G(i,:)).*(randn(1,n) + 1j*randn(1,n));
    g(j,:) = s;
    j      = N - j + 2;
    g(j,:) = conj(s);
    
end
y     = real(ifft(g));
y     = y*sqrt(mean(sum(G)*dHz)/mean(var(y)));
