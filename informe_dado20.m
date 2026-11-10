% INFORME_DADO20  Genera las figuras del informe sin interfaz grafica.
%   Edite p, N y n abajo; guarda figura_dado20.png en esta carpeta.
K = 20;
p = ones(1, K) / K;        % uniforme discreta en {1,...,20}
% p = rebalancear_prob(p, 20, 0.30);   % ejemplo: dado cargado en la cara 20
N = 1000;                  % numero de VAs iid
n = 10000;                 % realizaciones por VA

r = simular_dado(p, N, n, 1);
fprintf('Simulacion de %d valores en %.2f s\n', N*n, r.segundos);

f = figure('Color', 'w', 'Position', [100 100 900 1000]);
ax = gobjects(3, 1);
for k = 1:3, ax(k) = subplot(3, 1, k, 'Parent', f); end
h = crear_graficas(ax);
actualizar_graficas(h, r);
exportgraphics(f, fullfile(fileparts(mfilename('fullpath')), 'figura_dado20.png'), 'Resolution', 150);
