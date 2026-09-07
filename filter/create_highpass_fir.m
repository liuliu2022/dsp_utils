function [filterObj, taps, info] = create_highpass_fir(Fc, fs, transitionWidth)
%CREATE_HIGHPASS_FIR Create a GNU Radio-style high-pass FIR filter.
%   Fc is the center of the transition band, in Hz.

    [filterObj, taps, info] = design_gnuradio_fir( ...
        'highpass', Fc, fs, transitionWidth);
end
