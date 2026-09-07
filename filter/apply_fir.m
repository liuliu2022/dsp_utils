function [filteredData, validData, validStartIndex] = apply_fir(data, filterObj)
%APPLY_FIR Independently FIR-filter one noncontiguous acquisition frame.
%   data must be Channels x Samples and may be real or complex. The filter
%   state is cleared on every call because adjacent acquisition frames are
%   not assumed to be time-contiguous.
%
%   filteredData has the same size as data. validData excludes the startup
%   transient caused by zero initial conditions. validStartIndex is the
%   first valid column in filteredData; it is empty when the frame is too
%   short to contain settled output.

    validateattributes(data, {'numeric'}, {'2d', 'nonempty'}, mfilename, 'data');
    assert(isa(filterObj, 'dsp.FIRFilter'), ...
        '[dsp_utils] filterObj must be a dsp.FIRFilter object.');

    [numChannels, numSamples] = size(data);
    assert(numChannels >= 1 && numSamples >= 1, ...
        '[dsp_utils] data must contain at least one channel and one sample.');

    % Release a previously locked object so a different channel count is safe.
    if isLocked(filterObj)
        release(filterObj);
    end
    reset(filterObj);

    % DSP System objects operate on Samples x Channels. Use .' so complex
    % baseband data is transposed without conjugation.
    filteredData = filterObj(data.').';

    assert(isequal(size(filteredData), [numChannels, numSamples]), ...
        '[dsp_utils] FIR output size does not match the input size.');

    numTaps = numel(filterObj.Numerator);
    if numSamples >= numTaps
        validStartIndex = numTaps;
        validData = filteredData(:, validStartIndex:end);
    else
        validStartIndex = [];
        validData = filteredData(:, []);
    end
end
