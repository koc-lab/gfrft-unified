% (c) Copyright 2023 Tuna Alikaşifoğlu

function [varargout] = Matrix_Idx(matrix, ordering)
    arguments
        matrix {mustBeNumeric}
        ordering(1, :) char{mustBeMember(ordering, {'min', 'max'})}
    end

    if strcmp(ordering, 'min')
        [~, I] = min(matrix(:));
    else
        [~, I] = max(matrix(:));
    end

    if nargout == 1
        dimension_count = ndims(matrix);
        [idx{1:dimension_count}] = ind2sub(size(matrix), I);
        varargout{1} = idx;
    else
        [varargout{1:nargout}] = ind2sub(size(matrix), I);
    end
end
