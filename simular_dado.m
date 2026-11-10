function r = simular_dado(p, N, n, semilla)
%SIMULAR_DADO Version sincrona (para scripts/informe): lanza y espera.
%   r = simular_dado(ones(1,20)/20, 1000, 10000, 1);
    if nargin < 4, semilla = 1; end
    r = recoger_simulacion(lanzar_simulacion(p, N, n, semilla));
end
