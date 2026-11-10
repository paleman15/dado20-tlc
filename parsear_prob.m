function v = parsear_prob(txt)
%PARSEAR_PROB Convierte texto a probabilidad en [0,1].
%   Acepta: '0.05', '1/20', '5%', '5 %', ' 3/60 '. Devuelve NaN si no es valido.
    if isnumeric(txt), v = double(txt); v = validar(v); return; end
    s = strtrim(char(txt));
    s = strrep(s, ',', '.');                 % admite coma decimal
    if isempty(s), v = NaN; return; end
    if s(end) == '%'
        v = str2double(strtrim(s(1:end-1))) / 100;
    elseif contains(s, '/')
        partes = strsplit(s, '/');
        if numel(partes) ~= 2, v = NaN; return; end
        num = str2double(partes{1}); den = str2double(partes{2});
        if den == 0, v = NaN; return; end
        v = num / den;
    else
        v = str2double(s);
    end
    v = validar(v);
end

function v = validar(v)
    if ~isscalar(v) || ~isfinite(v) || v < 0 || v > 1 + 1e-12
        v = NaN;
    else
        v = min(v, 1);
    end
end
