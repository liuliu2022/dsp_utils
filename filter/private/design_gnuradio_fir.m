function [filterObj, taps, info] = design_gnuradio_fir(filterType, freqSpec, fs, transitionWidth)
%DESIGN_GNURADIO_FIR Design a GNU Radio-style windowed-sinc FIR filter.
%   This private helper follows GNU Radio firdes conventions:
%   Hamming window, 53 dB nominal attenuation, and
%   numTaps = fix(attenuationDb * fs / (22 * transitionWidth)).

    filterType = validatestring(filterType, ...
        {'lowpass', 'highpass', 'bandpass', 'complex_bandpass'});

    validateattributes(fs, {'numeric'}, ...
        {'real', 'finite', 'scalar', 'positive'}, mfilename, 'fs');
    validateattributes(transitionWidth, {'numeric'}, ...
        {'real', 'finite', 'scalar', 'positive'}, mfilename, 'transitionWidth');
    validateattributes(freqSpec, {'numeric'}, ...
        {'real', 'finite', 'vector', 'nonempty'}, mfilename, 'freqSpec');

    attenuationDb = 53;
    numTaps = fix(attenuationDb * fs / (22 * transitionWidth));
    if mod(numTaps, 2) == 0
        numTaps = numTaps + 1;
    end
    numTaps = max(numTaps, 3);

    order = numTaps - 1;
    groupDelay = order / 2;
    win = hamming(numTaps, 'symmetric');
    nyquist = fs / 2;

    switch filterType
        case 'lowpass'
            validateattributes(freqSpec, {'numeric'}, {'numel', 1});
            cutoff = freqSpec(1);
            assert(cutoff > 0 && cutoff < nyquist, ...
                '[dsp_utils] Low-pass cutoff must satisfy 0 < Fc < fs/2.');
            taps = fir1(order, cutoff / nyquist, 'low', win, 'scale');
            cutoffInfo = cutoff;

        case 'highpass'
            validateattributes(freqSpec, {'numeric'}, {'numel', 1});
            cutoff = freqSpec(1);
            assert(cutoff > 0 && cutoff < nyquist, ...
                '[dsp_utils] High-pass cutoff must satisfy 0 < Fc < fs/2.');
            taps = fir1(order, cutoff / nyquist, 'high', win, 'scale');
            cutoffInfo = cutoff;

        case 'bandpass'
            validateattributes(freqSpec, {'numeric'}, {'numel', 2});
            bandEdges = sort(freqSpec(:).');
            assert(bandEdges(1) > 0 && bandEdges(2) < nyquist && ...
                   bandEdges(1) < bandEdges(2), ...
                '[dsp_utils] Band-pass edges must satisfy 0 < Fl < Fh < fs/2.');
            taps = fir1(order, bandEdges / nyquist, 'bandpass', win, 'scale');
            cutoffInfo = bandEdges;

        case 'complex_bandpass'
            validateattributes(freqSpec, {'numeric'}, {'numel', 2});
            bandEdges = sort(freqSpec(:).');
            assert(bandEdges(1) >= -nyquist && bandEdges(2) <= nyquist && ...
                   bandEdges(1) < bandEdges(2), ...
                ['[dsp_utils] Complex band-pass edges must satisfy ' ...
                 '-fs/2 <= Fl < Fh <= fs/2.']);

            halfBandwidth = (bandEdges(2) - bandEdges(1)) / 2;
            centerFrequency = (bandEdges(1) + bandEdges(2)) / 2;
            assert(halfBandwidth > 0 && halfBandwidth < nyquist, ...
                '[dsp_utils] Complex band-pass bandwidth must be less than fs.');

            prototype = fir1(order, halfBandwidth / nyquist, ...
                'low', win, 'scale');
            centeredIndex = -groupDelay:groupDelay;
            taps = prototype .* exp(1j * 2 * pi * centerFrequency / fs .* centeredIndex);
            cutoffInfo = bandEdges;
    end

    filterObj = dsp.FIRFilter('Numerator', taps);

    info.type = filterType;
    info.sampleRate = fs;
    info.cutoffFrequency = cutoffInfo;
    info.transitionWidth = transitionWidth;
    info.window = 'Hamming';
    info.nominalAttenuationDb = attenuationDb;
    info.numTaps = numTaps;
    info.order = order;
    info.groupDelay = groupDelay;
    info.transientLength = order;
    info.validStartIndex = numTaps;
end
