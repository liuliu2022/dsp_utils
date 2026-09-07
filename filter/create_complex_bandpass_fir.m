function [filterObj, taps, info] = create_complex_bandpass_fir(Fl, Fh, fs, transitionWidth)
%CREATE_COMPLEX_BANDPASS_FIR Create a GNU Radio-style complex band-pass FIR.
%   Fl and Fh may be positive or negative and define a one-sided complex
%   baseband passband. Both frequencies are in Hz.

    [filterObj, taps, info] = design_gnuradio_fir( ...
        'complex_bandpass', [Fl, Fh], fs, transitionWidth);
end
