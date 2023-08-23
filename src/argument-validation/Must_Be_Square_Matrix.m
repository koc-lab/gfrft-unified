% (c) Copyright 2023 Tuna Alikaşifoğlu

function Must_Be_Square_Matrix(matrix)
    % custom valiation for `Must_Be_Square_Matrix`
    if ~ismatrix(matrix) || size(matrix, 1) ~= size(matrix, 2)
        eid = 'Size:notSquare';
        msg = 'Matrix must be square.';
        throwAsCaller(MException(eid, msg));
    end
end
