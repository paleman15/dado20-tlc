function actualizar_graficas(h, r)
%ACTUALIZAR_GRAFICAS Rellena las graficas con el resultado R de la simulacion.
    K = r.K; p = r.p(:).'; x = 1:K;
    mu = sum(x .* p);
    s2 = sum(x.^2 .* p) - mu^2;

    % ---- Parte 1: histograma normalizado (/n) vs pmf teorica ----
    frec = r.cuentasX1(:).' / r.n;
    set(h.bar(1),  'XData', x, 'YData', frec);
    set(h.exac(1), 'XData', x, 'YData', p);
    h.ax(1).XLim = [0.5 K+0.5];
    h.ax(1).YLim = [0 1.45*max([frec p])];   % espacio para texto y leyenda
    xr = (1:K) * r.cuentasX1(:) / r.n;
    vr = (x.^2) * r.cuentasX1(:) / r.n - xr^2;
    h.info(1).String = sprintf('n = %d realizaciones de X_1\nE[X]   teo %8.4f  sim %8.4f\nVar[X] teo %8.4f  sim %8.4f', ...
                               r.n, mu, xr, s2, vr);

    % ---- Paso c (n sumas de N VAs) y paso e (N sumas de n realizaciones) ----
    pintar_suma(h, 2, r.sumaVars, r.N, p, mu, s2, sprintf('n = %d sumas, cada una de N = %d VAs', r.n, r.N));
    pintar_suma(h, 3, r.sumaReal, r.n, p, mu, s2, sprintf('N = %d sumas, cada una de n = %d realizaciones', r.N, r.n));
    drawnow limitrate
end

function pintar_suma(h, k, datos, M, p, mu, s2, encabezado)
% datos: muestras de una suma de M terminos iid con pmf p.
    datos = double(datos(:));
    lo = min(datos); hi = max(datos);
    w = max(1, ceil((hi - lo + 1) / 60));            % ancho de clase (entero)
    bordes = (lo - 0.5) : w : (hi + 0.5 + w);
    nb = numel(bordes) - 1;
    cuentas = histcounts(datos, bordes);
    dens = cuentas / (numel(datos) * w);              % normalizado a densidad
    centros = bordes(1:end-1) + w/2;
    set(h.bar(k), 'XData', centros, 'YData', dens);

    % Convolucion exacta (via FFT) promediada sobre cada clase
    L = (numel(p) - 1) * M + 1;
    if L <= 2^22
        [pz, z] = pmf_suma(p, M);
        idx = floor((z - bordes(1)) / w) + 1;
        ok = idx >= 1 & idx <= nb;
        teo = accumarray(idx(ok).', pz(ok).', [nb 1]).' / w;
        set(h.exac(k), 'XData', centros, 'YData', teo);
    else
        teo = 0;
        set(h.exac(k), 'XData', NaN, 'YData', NaN);   % demasiado grande: solo Normal
    end

    % Aproximacion Normal por el Teorema del Limite Central
    m = M * mu; v = M * s2;
    if v > 0
        xs = linspace(bordes(1), bordes(end), 400);
        set(h.norm(k), 'XData', xs, 'YData', exp(-(xs - m).^2 / (2*v)) / sqrt(2*pi*v));
    else
        set(h.norm(k), 'XData', NaN, 'YData', NaN);
    end
    h.ax(k).XLim = [bordes(1) bordes(end)];
    h.ax(k).YLim = [0 1.35 * max([dens teo 1/sqrt(2*pi*max(v, eps))*(v>0)])];
    h.info(k).String = sprintf('%s   (\\Delta = %d)\nE   teo %12.2f  sim %12.2f\nVar teo %12.2f  sim %12.2f', ...
        encabezado, w, m, mean(datos), v, var(datos));
end
