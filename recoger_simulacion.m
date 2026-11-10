function r = recoger_simulacion(trabajo)
%RECOGER_SIMULACION Espera los bloques de LANZAR_SIMULACION y une resultados.
%   r.sumaVars  : 1 x n  -> Z_j = sum_i X_ij   (paso c, n sumas de N VAs)
%   r.sumaReal  : N x 1  -> W_i = sum_j X_ij   (paso e, N sumas de n realizaciones)
%   r.cuentasX1 : K x 1  -> conteo de las n realizaciones de X_1 (parte 1)
    [sv, sr, cx] = fetchOutputs(trabajo.F, 'UniformOutput', false);
    r.sumaVars  = [sv{:}];
    r.sumaReal  = sum([sr{:}], 2);
    r.cuentasX1 = sum([cx{:}], 2);
    r.N = trabajo.N; r.n = trabajo.n; r.K = trabajo.K; r.p = trabajo.p;
    r.segundos = toc(trabajo.tic);
end
