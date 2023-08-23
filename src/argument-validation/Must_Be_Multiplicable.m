% (c) Copyright 2023 Tuna Alikaşifoğlu

function Must_Be_Multiplicable(first, second)
    % Test for equal size
    if ~isequal(size(first, ndims(first)), size(second, 1))
        eid = 'MATLAB:innerdim';
        msg = 'Dimensions are not compatible.';
        throwAsCaller(MException(eid, msg));
    end
end
