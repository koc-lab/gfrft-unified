% (c) Copyright 2023 Tuna Alikaşifoğlu

function Must_Be_Logical(input)
    if ~islogical(input)
        eid = 'MATLAB:Logical:InvalidInput';
        msg = 'Input must be a logical.';
        throwAsCaller(MException(eid, msg));
    end
end
