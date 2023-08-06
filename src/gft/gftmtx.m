function [gftmtx, igftmtx, eigVals] = gftmtx(shiftMatrix, sortMethod,...
                                             decompMethod, roundDigit)
    arguments
        shiftMatrix (:,:) {mustBeNumeric, mustBeSquareMatrix}
        sortMethod (1,:) char {mustBeMember(sortMethod,...
                                {'tv','ascend','ascend02pi'})} = 'tv'
        decompMethod (1,:) char {mustBeMember(decompMethod,...
                                    {'eig','jordan'})} = 'eig'
        roundDigit (1,1) double {mustBeInteger} = int32(abs(log10(eps)))
    end

switch sortMethod
    case "tv"
        [V, D] = tvdecomposition(shiftMatrix, decompMethod);
    case {"ascend", "ascend02pi"}
        [V, D] = ascendingdecomposition(shiftMatrix, sortMethod,...
                                        decompMethod, roundDigit);
    otherwise
        error("`sortMethod` can be either `tv` | `ascend` | `ascend02pi`");
end

igftmtx = V;
if ishermitian(shiftMatrix)
    gftmtx = V';
else
    gftmtx = inv(V);
end
if nargout > 2
    eigVals = diag(D);
end
end

function [V, D] = spectraldecomposition(Z, decompMethod)
if strcmp(decompMethod, "jordan")
    [V, D] = jordan(Z);
elseif strcmp(decompMethod, "eig")
    if ishermitian(Z)
        [V, D] = eigh(Z);
    else
        [V, D] = eig(Z);
    end
else
    error("`decompMethod` can be either `jordan` | `eig`");
end
end

function [V, D] = tvdecomposition(Z, decompMethod)
[V, D] = spectraldecomposition(Z, decompMethod);
maxEigValue = max(abs(diag(D)));
normalizedZ = Z / maxEigValue;

difference = V - normalizedZ * V;
tv = vecnorm(difference, 1, 1);
[~, sort_idx] = sort(tv);
V = V(:, sort_idx);
D = D(sort_idx, sort_idx);
end

function [V, D] = ascendingdecomposition(Z, sortMethod, ...
                                            decompMethod, roundDigit)
[V, D] = spectraldecomposition(Z, decompMethod);

if strcmp(sortMethod, "ascend")
    [~, sort_idx] = sort(diag(D));
elseif strcmp(sortMethod, "ascend02pi")
    [~, sort_idx] = sortComplex02pi(diag(D), roundDigit);
end

D = D(sort_idx, sort_idx);
V = V(:, sort_idx);
end

% custom valiation for `mustBeSquareMatrix`
function mustBeSquareMatrix(A)
if ~ismatrix(A) || size(A, 1) ~= size(A, 2)
    eid = 'Size:notSquare';
    msg = 'Matrix must be square.';
    throwAsCaller(MException(eid,msg))
end
end
