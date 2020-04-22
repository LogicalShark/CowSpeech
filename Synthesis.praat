# Pitch
# models fundamental frequency (in Hertz).

# Flutter
# models a kind of "random" variation of the pitch (with a number between zero and one).

# Voicing amplitude
# models the maximum amplitude of the glottal flow (in dB SPL).

# Open phase
# models the open phase of the glottis (with a number between zero and one). If the tier is empty a default of 0.7 will be used.

# Power1, Power2
# model the form of the glottal flow function flow(t)=tpower1-tpower2 for 0≤ t ≤ 1. To make glottal closure possible, power2 has to be larger than power1. If the power1 tier is empty, a default value of 3 will be used. If the power2 tier is empty, a default of 4 will be used.

# Collision phase
# models the last part of the flow function with an exponential decay function instead of a polynomial one. More information about Power1, Power2, Open phase and Collision phase can be found in the PointProcess: To Sound (phonation)... manual.

# Spectral tilt
# models the extra number of dB the voicing spectrum should be down at 3000 Hertz.

# Aspiration amplitude
# models the (maximum) amplitude of the noise generated at the glottis (in dB SPL).

# Breathiness amplitude
# models the maximum breathiness noise amplitude during the open phase of the glottis (in dB SPL). The amplitude of the breathiness noise is modulated by the glottal flow.

# Double pulsing
# models diplophonia (by a fraction between zero and one). Whenever this parameter is greater than zero, alternate pulses are modified. A pulse is modified with this single parameter in two ways: it is delayed in time and its amplitude is attenuated. If the double pulsing value is a maximum and equals one, the time of closure of the first peak coincides with the opening time of the second one.

Create KlattGrid: "kg", 0, 1, 6, 1, 1, 6, 1, 1, 1
Add pitch point: 0.5, 100
Add voicing amplitude point: 0.5, 90
To Sound