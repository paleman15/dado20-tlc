% PRUEBAS_DADO20  Verificaciones automaticas (correr: matlab -batch pruebas_dado20)
fprintf('--- Pruebas dado de 20 caras ---\n');
K = 20; tol = 1e-12;

% 1) parsear_prob: fraccion, porcentaje, decimal, invalidos
assert(abs(parsear_prob('1/10') - 0.1) < tol);
assert(abs(parsear_prob('10%') - 0.1) < tol);
assert(abs(parsear_prob('0,25') - 0.25) < tol);
assert(abs(parsear_prob(' 3 / 60 ') - 0.05) < tol);
assert(isnan(parsear_prob('abc')) && isnan(parsear_prob('2')) && isnan(parsear_prob('-1/5')) && isnan(parsear_prob('1/0')));
fprintf('ok parsear_prob\n');

% 2) rebalancear_prob: suma 1 y proporciones conservadas
p = rebalancear_prob(ones(1,K)/K, 20, 0.5);
assert(abs(sum(p) - 1) < tol && abs(p(20) - 0.5) < tol && max(abs(p(1:19) - 0.5/19)) < tol);
p2 = rebalancear_prob(p, 1, 0.1);                 % cara 20 sigue siendo 9.5x las otras
assert(abs(sum(p2) - 1) < tol && abs(p2(20)/p2(2) - p(20)/p(2)) < 1e-9);
p3 = rebalancear_prob(rebalancear_prob(p, 5, 1), 5, 0.2);   % todo en 0 -> reparte igual
assert(abs(sum(p3) - 1) < tol && max(abs(p3([1:4 6:20]) - 0.8/19)) < tol);
% caras fijas: fijo cara 20 en 0.3, luego cambio la 1 -> la 20 NO se mueve
fj = false(1,K);
p4 = rebalancear_prob(ones(1,K)/K, 20, 0.3, fj); fj(20) = true;
p5 = rebalancear_prob(p4, 1, 0.025, fj);
assert(abs(p5(20) - 0.3) < tol && abs(p5(1) - 0.025) < tol && abs(sum(p5) - 1) < tol);
[~, ok] = rebalancear_prob(p5, 1, 0.8, fj);         % 0.3 + 0.8 > 1 -> rechazar
assert(~ok);
[~, ok] = rebalancear_prob(p5, 1, 0.2, true(1,K));  % sin caras libres -> rechazar
assert(~ok);
fprintf('ok rebalancear_prob (incl. caras fijas)\n');

% 3) pmf_suma vs convolucion directa (conv repetida)
q = rand(1,K); q = q/sum(q);
ref = q; for i = 2:7, ref = conv(ref, q); end
[pz, z] = pmf_suma(q, 7);
assert(max(abs(pz - ref)) < 1e-14 && z(1) == 7 && z(end) == 140);
fprintf('ok pmf_suma (FFT == conv directa)\n');

% 4) Simulacion uniforme N=1000, n=10000: medias y varianzas
mu = 10.5; s2 = (K^2 - 1)/12;
t = tic; r = simular_dado(ones(1,K)/K, 1000, 10000, 1); fprintf('simulacion 1e7 valores: %.2f s\n', toc(t));
assert(numel(r.sumaVars) == 10000 && numel(r.sumaReal) == 1000 && sum(r.cuentasX1) == 10000);
assert(abs(mean(r.sumaVars) - 1000*mu) < 4*sqrt(1000*s2/10000));
assert(abs(var(r.sumaVars)/(1000*s2) - 1) < 0.05);
assert(abs(mean(r.sumaReal) - 10000*mu) < 4*sqrt(10000*s2/1000));
assert(abs(var(r.sumaReal)/(10000*s2) - 1) < 0.15);
fprintf('ok momentos (uniforme)\n');

% 5) Reproducibilidad y no-uniforme con caras de prob 0
pn = rebalancear_prob(ones(1,K)/K, 20, 0.5); pn(3) = 0; pn = pn/sum(pn);
a = simular_dado(pn, 200, 50000, 7); b = simular_dado(pn, 200, 50000, 7);
assert(isequal(a.sumaVars, b.sumaVars) && isequal(a.sumaReal, b.sumaReal));
assert(a.cuentasX1(3) == 0);
frec = a.cuentasX1.'/a.n;
assert(max(abs(frec - pn)) < 4*sqrt(0.25/a.n));
fprintf('ok no-uniforme, cara con p=0 y reproducibilidad\n');

% 6) Graficas sin pantalla (figura invisible)
f = figure('Visible', 'off'); ax = gobjects(3,1);
for k = 1:3, ax(k) = subplot(3,1,k, 'Parent', f); end
h = crear_graficas(ax); actualizar_graficas(h, r); close(f);
fprintf('ok graficas\n');

fprintf('--- TODAS LAS PRUEBAS PASARON ---\n');
