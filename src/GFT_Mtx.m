% (c) Copyright 2023 Tuna Alikaşifoğlu

function [gftmtx, igftmtx, eig_vals] = GFT_Mtx(shift_mtx, sort_method, decomp_method, round_digit)
    arguments
        shift_mtx(:, :) {mustBeNumeric, Must_Be_Square_Matrix}
        sort_method(1, :) char{mustBeMember(sort_method, ...
                                            {'tv', 'ascend', 'ascend02pi'})} = 'tv'
        decomp_method(1, :) char{mustBeMember(decomp_method, ...
                                              {'eig', 'jordan'})} = 'eig'
        round_digit(1, 1) double{mustBeInteger} = int32(abs(log10(eps)))
    end

    switch sort_method
        case "tv"
            [eig_vecs, eig_vals_mtx] = TV_Decomposition(shift_mtx, decomp_method);
        case {"ascend", "ascend02pi"}
            [eig_vecs, eig_vals_mtx] = Ascending_Decomposition(shift_mtx, sort_method, ...
                                                               decomp_method, round_digit);
        otherwise
            error("`sort_method` can be either `tv` | `ascend` | `ascend02pi`");
    end

    igftmtx = eig_vecs;
    if ishermitian(shift_mtx)
        gftmtx = eig_vecs';
    else
        gftmtx = inv(eig_vecs);
    end
    if nargout > 2
        eig_vals = diag(eig_vals_mtx);
    end
end

function [eig_vecs, eig_vals_mtx] = Spectral_Decomposition(shift_mtx, decomp_method)
    if strcmp(decomp_method, "jordan")
        [eig_vecs, eig_vals_mtx] = jordan(shift_mtx);
    elseif strcmp(decomp_method, "eig")
        [eig_vecs, eig_vals_mtx] = eig(shift_mtx);
    else
        error("`decomp_method` can be either `jordan` | `eig`");
    end
end

function [eig_vecs, eig_vals_mtx] = TV_Decomposition(shift_mtx, decomp_method)
    [eig_vecs, eig_vals_mtx] = Spectral_Decomposition(shift_mtx, decomp_method);
    max_eig_value = max(abs(diag(eig_vals_mtx)));
    shift_mtx_normalized = shift_mtx / max_eig_value;

    difference = eig_vecs - shift_mtx_normalized * eig_vecs;
    tv = vecnorm(difference, 1, 1);
    [~, sort_idx] = sort(tv);
    eig_vecs = eig_vecs(:, sort_idx);
    eig_vals_mtx = eig_vals_mtx(sort_idx, sort_idx);
end

function [eig_vecs, eig_vals_mtx] = Ascending_Decomposition(shift_mtx, sort_method, ...
                                                            decomp_method, round_digit)
    [eig_vecs, eig_vals_mtx] = Spectral_Decomposition(shift_mtx, decomp_method);

    if strcmp(sort_method, "ascend")
        [~, sort_idx] = sort(diag(eig_vals_mtx));
    elseif strcmp(sort_method, "ascend02pi")
        [~, sort_idx] = Sort_Complex_Zero_Two_Pi(diag(eig_vals_mtx), round_digit);
    end

    eig_vals_mtx = eig_vals_mtx(sort_idx, sort_idx);
    eig_vecs = eig_vecs(:, sort_idx);
end

function [sorted, idx] = Sort_Complex_Zero_Two_Pi(arr, round_digit)
    arguments
        arr(:, 1) {mustBeNumeric, mustBeVector}
        round_digit(1, 1) double{mustBeInteger} = int32(abs(log10(eps)))
    end

    if nargin == 2
        arr_rounded = round(arr, round_digit);
    else
        arr_rounded = arr;
    end

    if isreal(arr_rounded)
        [~, idx] = sort(arr_rounded);
    else
        [~, idx] = sort(exp(-1j * pi) * arr_rounded);
    end
    sorted = arr(idx);
end
