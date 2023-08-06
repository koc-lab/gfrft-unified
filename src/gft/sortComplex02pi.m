function [sorted, idx] = sortComplex02pi(arr, roundDigit)
    arguments
        arr (:,1) {mustBeNumeric, mustBeVector}
        roundDigit (1,1) double {mustBeInteger} = int32(abs(log10(eps)))
    end
minArgs = 1;
maxArgs = 2;
narginchk(minArgs, maxArgs);

if nargin == 2
    arr_rounded = round(arr, roundDigit);
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
