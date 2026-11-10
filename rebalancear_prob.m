function [p, ok, msg] = rebalancear_prob(p, k, nuevo, fijas)
%REBALANCEAR_PROB Fija p(k)=nuevo y reescala las caras libres para que sum(p)=1.
%   FIJAS (logico, opcional): caras que el usuario ya fijo y NO se tocan.
%   Las caras libres conservan sus proporciones relativas; si todas valian 0,
%   lo que falta se reparte en partes iguales entre ellas.
%   Si el cambio es imposible (no hay caras libres o las fijas suman > 1),
%   devuelve p sin cambios, ok=false y un mensaje.
    p = p(:).';
    if nargin < 4 || isempty(fijas), fijas = false(size(p)); end
    fijas = logical(fijas(:).');
    libres = ~fijas; libres(k) = false;
    otrasFijas = fijas; otrasFijas(k) = false;
    resto = 1 - nuevo - sum(p(otrasFijas));        % lo que deben sumar las libres
    ok = true; msg = '';
    if resto < -1e-12
        ok = false; msg = 'Las caras fijas sumarian mas de 1. Libere alguna (columna Fija).';
        return
    end
    resto = max(resto, 0);
    if ~any(libres)
        if abs(resto) > 1e-12
            ok = false; msg = 'No quedan caras libres para compensar. Libere alguna (columna Fija).';
            return
        end
    else
        S = sum(p(libres));
        if S > 0
            p(libres) = p(libres) * (resto / S);
        else
            p(libres) = resto / nnz(libres);
        end
    end
    p(k) = nuevo;
    p = p / sum(p);          % elimina error de redondeo acumulado
end
