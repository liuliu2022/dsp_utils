function [filterObj, taps, info] = create_lowpass_fir(Fc, fs, transitionWidth)
%CREATE_LOWPASS_FIR Create a GNU Radio-style low-pass FIR filter.
%   Fc is the center of the transition band, in Hz.

    [filterObj, taps, info] = design_gnuradio_fir( ...
        'lowpass', Fc, fs, transitionWidth);
end
