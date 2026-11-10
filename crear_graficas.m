function h = crear_graficas(ax)
%CREAR_GRAFICAS Crea UNA vez los objetos graficos de los 3 ejes.
%   Luego ACTUALIZAR_GRAFICAS solo cambia XData/YData (mucho mas rapido que
%   volver a llamar a bar/plot en cada simulacion).
    azul = [0.30 0.50 0.80]; rojo = [0.85 0.20 0.15]; negro = [0 0 0];
    titulos = {'Parte 1: pmf de X (un dado de 20 caras)', ...
               'Paso c/d: Z_j = \Sigma_{i=1}^{N} X_{ij}  (n sumas)', ...
               'Paso e: W_i = \Sigma_{j=1}^{n} X_{ij}  (N sumas)'};
    for k = 1:3
        a = ax(k);
        cla(a); hold(a, 'on'); box(a, 'on'); grid(a, 'on');
        h.bar(k)   = bar(a, NaN, NaN, 1, 'FaceColor', azul, 'EdgeColor', 'w', 'FaceAlpha', 0.75);
        h.exac(k)  = plot(a, NaN, NaN, 'o', 'Color', rojo, 'MarkerFaceColor', rojo, 'MarkerSize', 4);
        h.norm(k)  = plot(a, NaN, NaN, '-', 'Color', negro, 'LineWidth', 1.4);
        h.titulo(k) = title(a, titulos{k}, 'FontWeight', 'normal');
        h.info(k)  = text(a, 0.01, 0.97, '', 'Units', 'normalized', 'VerticalAlignment', 'top', ...
                          'FontName', 'monospaced', 'FontSize', 8, 'BackgroundColor', [1 1 1 0.8]);
        hold(a, 'off');
    end
    h.norm(1).Visible = 'off';
    h.bar(1).BarWidth = 0.7;               % pmf discreta: barras separadas
    legend(ax(1), [h.bar(1) h.exac(1)], {'Histograma / n', 'pmf teorica'}, 'Location', 'northeast');
    for k = 2:3
        legend(ax(k), [h.bar(k) h.exac(k) h.norm(k)], ...
               {'Histograma / (n_{sumas}\cdot\Delta)', 'Convolucion exacta', 'Normal (TLC)'}, 'Location', 'northeast');
    end
    xlabel(ax(1), 'cara'); ylabel(ax(1), 'probabilidad');
    xlabel(ax(2), 'z'); ylabel(ax(2), 'densidad');
    xlabel(ax(3), 'w'); ylabel(ax(3), 'densidad');
    h.ax = ax;
end
