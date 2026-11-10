function [pz, z] = pmf_suma(p, N)
%PMF_SUMA PMF exacta de Z = X_1 + ... + X_N (X_i iid con pmf p sobre 1..K).
%   La pmf de una suma de VAs independientes es la convolucion N-veces de p.
%   Se calcula en el dominio de la frecuencia: conv^N  <=>  FFT(p)^N,
%   que cuesta O(L log L) en lugar de O(N * L * K).
    p = p(:).';
    K = numel(p);
    z = N : K*N;                         % soporte de Z
    L = (K-1)*N + 1;                     % longitud exacta (sin aliasing)
    Lf = 2^nextpow2(L);
    pz = real(ifft(fft(p, Lf).^N));
    pz = pz(1:L);
    pz(pz < 0) = 0;                      % ruido numerico ~1e-17
    pz = pz / sum(pz);
end
