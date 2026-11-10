function trabajo = lanzar_simulacion(p, N, n, semilla)
%LANZAR_SIMULACION Reparte la simulacion en bloques sobre varios nucleos.
%   Se modela una matriz X de N x n (N variables iid, n realizaciones c/u),
%   pero NUNCA se guarda completa: se divide por columnas (realizaciones) en
%   bloques que se generan en paralelo en backgroundPool (hilos, incluido en
%   MATLAB base, no requiere Parallel Computing Toolbox). Cada bloque devuelve
%   solo sus sumas, asi la memoria queda acotada aunque N*n sea enorme.
%
%   Devuelve un struct con los futuros; usar RECOGER_SIMULACION para unir.
%   La llamada no bloquea: la interfaz sigue respondiendo mientras se calcula.
    p = p(:).' / sum(p);
    K = numel(p);
    % discretize exige bordes estrictamente crecientes: se usan solo las caras
    % con p>0 y luego se mapea el indice a la cara real.
    caras = find(p > 0);
    bordes = [0, cumsum(p(caras))]; bordes(end) = 1;
    uniforme = max(abs(p - 1/K)) < 1e-12;

    maxElem = 2e6;                                 % ~16 MB por bloque
    m = max(1, min(n, floor(maxElem / N)));        % columnas por bloque
    nb = ceil(n / m);

    pool = backgroundPool;
    F(1:nb) = parallel.FevalFuture;
    for b = 1:nb
        c0 = (b-1)*m + 1;
        mb = min(m, n - c0 + 1);
        F(b) = parfeval(pool, @bloque, 3, semilla, b, N, mb, K, caras, bordes, uniforme);
    end
    trabajo = struct('F', F, 'N', N, 'n', n, 'K', K, 'p', p, 'tic', tic);
end

function [sumaVars, sumaReal, cuentasX1] = bloque(semilla, b, N, mb, K, caras, bordes, uniforme)
    % Subflujo independiente por bloque => resultado reproducible y sin
    % correlacion entre hilos, sin importar cuantos nucleos haya.
    rs = RandStream('threefry4x64_20', 'Seed', semilla);
    rs.Substream = b;
    if uniforme
        X = randi(rs, K, N, mb);                   % caso uniforme: directo
    else
        X = discretize(rand(rs, N, mb), bordes);   % metodo de la transformada inversa
        if numel(caras) < K, X = reshape(caras(X), N, mb); end
    end
    sumaVars  = sum(X, 1);                         % (c) suma a lo largo de las VAs   -> 1 x mb
    sumaReal  = sum(X, 2);                         % (e) suma a lo largo de realizac. -> N x 1 (parcial)
    cuentasX1 = accumarray(X(1, :).', 1, [K 1]);   % (1) realizaciones de X_1
end
