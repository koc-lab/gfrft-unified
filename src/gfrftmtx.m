% (c) Copyright 2023 Tuna Alikaşifoğlu

function [gfrftMatrix, igfrftMatrix] = gfrftmtx(gftMatrix, a)
arguments
    gftMatrix(:, :) {mustBeNumeric, mustBeSquareMatrix}
    a(1, 1) double{mustBeReal}
end

gfrftMatrix = mpower(gftMatrix, a);
if nargout > 1
    igfrftMatrix = mpower(gftMatrix, -a);
end
end

% custom valiation for `mustBeSquareMatrix`
function mustBeSquareMatrix(A)
if ~ismatrix(A) || size(A, 1) ~= size(A, 2)
    eid = 'Size:notSquare';
    msg = 'Matrix must be square.';
    throwAsCaller(MException(eid, msg))
end
end
