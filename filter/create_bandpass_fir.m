function [filterObj, taps, info] = create_bandpass_fir(Fl, Fh, fs, transitionWidth)
%CREATE_BANDPASS_FIR Create a GNU Radio-style real-coefficient band-pass FIR.
%   Fl and Fh are the centers of the lower and upper transition bands, in Hz.
%   For complex input, a real-coefficient filter passes symmetric positive
%   and negative frequency bands.

    [filterObj, taps, info] = design_gnuradio_fir( ...
        'bandpass', [Fl, Fh], fs, transitionWidth);
end
