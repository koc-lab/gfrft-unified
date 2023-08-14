% (c) Copyright 2023 Tuna Alikaşifoğlu

function Must_Be_Equal_Size(first, second)
    % Test for equal size
    if ~isequal(size(first), size(second))
        eid = 'Size:notEqual';
        msg = 'Size of first input must equal size of second input.';
        throwAsCaller(MException(eid, msg));
    end
end
