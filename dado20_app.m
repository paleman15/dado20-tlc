function dado20_app()
%DADO20_APP Interfaz ligera: dado de 20 caras (uniforme discreta) y TLC.
%   - Elegir N (numero de VAs iid) y n (realizaciones por VA).
%   - Editar la probabilidad de cualquier cara (ej. 0.1, 1/10 o 10%); el resto
%     de caras se reescala automaticamente para que la suma siga siendo 1.
%   - "Simular" corre en segundo plano en varios nucleos (backgroundPool) y
%     la ventana sigue respondiendo mientras tanto.
%
%   Usa figure + uicontrol clasicos (mas livianos que App Designer) y los
%   objetos graficos se crean una sola vez; cada simulacion solo actualiza datos.

    K = 20;
    st.p = ones(1, K) / K;
    st.fijas = false(1, K);     % caras que el usuario fijo (no se reescalan)
    st.trabajo = [];

    fig = figure('Name', 'Dado de 20 caras - Suma de VAs y TLC', 'NumberTitle', 'off', ...
                 'MenuBar', 'none', 'ToolBar', 'figure', 'Color', 'w', ...
                 'Units', 'pixels', 'Position', [80 60 1200 760], ...
                 'CloseRequestFcn', @cerrar);

    % ---------------- Panel de controles (izquierda) ----------------
    pnl = uipanel(fig, 'Units', 'normalized', 'Position', [0 0 0.24 1], ...
                  'BackgroundColor', [0.96 0.96 0.96], 'BorderType', 'none');
    fila = @(y) [0.06 y 0.88 0.03];
    uicontrol(pnl, 'Style', 'text', 'Units', 'normalized', 'Position', fila(0.955), ...
              'String', 'Parametros', 'FontWeight', 'bold', 'HorizontalAlignment', 'left', 'BackgroundColor', pnl.BackgroundColor);
    edN    = campo('N  (numero de VAs iid)',       '1000',  0.915);
    edn    = campo('n  (realizaciones por VA)',    '10000', 0.845);
    edSeed = campo('Semilla',                      '1',     0.775);

    btnSim = uicontrol(pnl, 'Style', 'pushbutton', 'Units', 'normalized', 'Position', [0.06 0.69 0.42 0.04], ...
                       'String', 'Simular', 'FontWeight', 'bold', 'Callback', @simular);
    uicontrol(pnl, 'Style', 'pushbutton', 'Units', 'normalized', 'Position', [0.52 0.69 0.42 0.04], ...
              'String', 'Uniforme (1/20)', 'Callback', @resetUniforme);
    txtEstado = uicontrol(pnl, 'Style', 'text', 'Units', 'normalized', 'Position', [0.06 0.645 0.88 0.035], ...
                          'String', 'Listo.', 'HorizontalAlignment', 'left', 'BackgroundColor', pnl.BackgroundColor);

    uicontrol(pnl, 'Style', 'text', 'Units', 'normalized', 'Position', [0.06 0.59 0.88 0.05], ...
              'String', 'Probabilidades (0.1, 1/10 o 10%). Editadas = fijas', 'FontWeight', 'bold', ...
              'HorizontalAlignment', 'left', 'BackgroundColor', pnl.BackgroundColor);
    tabla = uitable(pnl, 'Units', 'normalized', 'Position', [0.04 0.075 0.92 0.51], ...
                    'ColumnName', {'Cara', 'Fraccion', '%', 'Fija'}, 'RowName', [], ...
                    'ColumnEditable', [false true true true], 'ColumnFormat', {'numeric', 'char', 'char', 'logical'}, ...
                    'ColumnWidth', {45, 80, 80, 40}, 'CellEditCallback', @editarProb);
    txtSuma = uicontrol(pnl, 'Style', 'text', 'Units', 'normalized', 'Position', [0.06 0.005 0.88 0.065], ...
                        'HorizontalAlignment', 'left', 'BackgroundColor', pnl.BackgroundColor);

    % ---------------- Graficas (derecha) ----------------
    ax = gobjects(3, 1);
    alto = 0.25; y0 = [0.715 0.395 0.075];
    for k = 1:3
        ax(k) = axes(fig, 'Units', 'normalized', 'Position', [0.30 y0(k) 0.67 alto], 'FontSize', 8);
    end
    h = crear_graficas(ax);

    refrescarTabla();
    % Calienta el pool de hilos mientras el usuario mira la ventana
    try, parfeval(backgroundPool, @() 0, 1); catch, end

    % ======================= Callbacks =======================
    function ed = campo(etiqueta, valor, y)
        uicontrol(pnl, 'Style', 'text', 'Units', 'normalized', 'Position', fila(y), ...
                  'String', etiqueta, 'HorizontalAlignment', 'left', 'BackgroundColor', pnl.BackgroundColor);
        ed = uicontrol(pnl, 'Style', 'edit', 'Units', 'normalized', 'Position', fila(y - 0.032), ...
                       'String', valor, 'BackgroundColor', 'w');
    end

    function refrescarTabla()
        d = cell(K, 4);
        for i = 1:K
            d{i, 1} = i;
            d{i, 2} = strtrim(rats(st.p(i)));
            d{i, 3} = sprintf('%.4f %%', 100 * st.p(i));
            d{i, 4} = st.fijas(i);
        end
        tabla.Data = d;
        x = 1:K; mu = x * st.p(:);
        txtSuma.String = sprintf('Suma = %.8f\nE[X] = %.4f   Var[X] = %.4f', sum(st.p), mu, (x.^2) * st.p(:) - mu^2);
    end

    function editarProb(~, ev)
        i = ev.Indices(1); col = ev.Indices(2);
        if col == 4                                % casilla Fija
            st.fijas(i) = logical(ev.NewData);
            refrescarTabla(); return
        end
        txt = strtrim(char(ev.NewData));
        if col == 3 && ~isempty(txt) && txt(end) ~= '%'
            txt = [txt '%'];                       % columna % : numero = porcentaje
        end
        v = parsear_prob(txt);
        if isnan(v)
            txtEstado.String = sprintf('Valor invalido para la cara %d: "%s"', i, txt);
        else
            [pNueva, ok, msg] = rebalancear_prob(st.p, i, v, st.fijas);
            if ok
                st.p = pNueva; st.fijas(i) = true;
                txtEstado.String = sprintf('Cara %d = %.6g (fija); las libres se reescalaron.', i, v);
            else
                txtEstado.String = msg;
            end
        end
        refrescarTabla();
    end

    function resetUniforme(~, ~)
        st.p = ones(1, K) / K;
        st.fijas = false(1, K);
        refrescarTabla();
        txtEstado.String = 'Probabilidades uniformes (1/20).';
    end

    function simular(~, ~)
        N = round(str2double(edN.String));
        n = round(str2double(edn.String));
        semilla = round(str2double(edSeed.String));
        if ~(N >= 1 && N <= 1e6 && n >= 1 && n <= 1e7 && isfinite(semilla) && semilla >= 0)
            txtEstado.String = 'Revisar: 1<=N<=1e6, 1<=n<=1e7, semilla>=0.';
            return
        end
        if N * n > 2e9
            txtEstado.String = sprintf('N*n = %.3g es demasiado (max 2e9).', N * n);
            return
        end
        btnSim.Enable = 'off';
        txtEstado.String = sprintf('Simulando %.3g valores en %d hilos...', N * n, backgroundPool().NumWorkers);
        drawnow
        try
            st.trabajo = lanzar_simulacion(st.p, N, n, semilla);
            % Cuando terminen TODOS los bloques, se actualiza la GUI (no bloquea).
            afterAll(st.trabajo.F, @(~) terminado(), 0, 'PassFuture', true);
        catch err
            btnSim.Enable = 'on';
            txtEstado.String = ['Error: ' err.message];
        end
    end

    function terminado()
        if ~isvalid(fig), return; end
        try
            r = recoger_simulacion(st.trabajo);
            txtEstado.String = sprintf('Simulacion lista en %.2f s. Graficando...', r.segundos);
            drawnow
            actualizar_graficas(h, r);
            txtEstado.String = sprintf('Listo: %.3g valores en %.2f s.', r.N * r.n, r.segundos);
        catch err
            txtEstado.String = ['Error: ' err.message];
        end
        btnSim.Enable = 'on';
    end

    function cerrar(~, ~)
        if ~isempty(st.trabajo), try, cancel(st.trabajo.F); catch, end, end
        delete(fig);
    end
end
