# ---------------------------------------------------------
# Processes sounds given target F1 and formant dispersion |
# ---------------------------------------------------------

clearinfo
directory$ = "D:/Documents/CS/CowSpeech/Sounds/"
outdir$ = "D:/Documents/CS/CowSpeech/Manipulated/"
vowelRegex$ = "[eo]_[0-9]"
writeInfoLine: "Running formant manipulator."

soundList = Create Strings as file list: "soundList", directory$ + "*.Sound"
select Strings soundList
numSounds = Get number of strings

for n to numSounds
    select Strings soundList
    filename$ = Get string... n
    Read from file... 'directory$''filename$'
endfor

appendInfoLine: 'numSounds', " files..."

# Animal info
animalF0 = 151
animalF1 = 984
animalF2 = 1594
animalDF = 1466

# Human info
# 14 female, 17 male
tractSize = 17.2
humanF0 = 120
numFormants = 5

# Precalculations
humanF1 = 34300 / (4 * tractSize)
humanDF = humanF1 * 2
humanF2 = humanF1 + humanDF
maxFormant = humanF1 + (humanDF * (numFormants - 1))

for n to numSounds
    select Strings soundList
    name$ = Get string: 'n'
    name$ = name$ - ".Sound"
    if index_regex(name$, vowelRegex$) <> 0
        # Process source
        appendInfoLine: "Processing source..."
        select Sound 'name$'
        manipulation = To Manipulation: 0.001, 75, 600
        pitch_tier = Extract pitch tier
        Multiply frequencies: 0, 100, animalF0 / humanF0
        selectObject: manipulation, pitch_tier
        Replace pitch tier
        selectObject: manipulation
        resynth = Get resynthesis (overlap-add)

        # Process filter
        appendInfoLine: "Processing filter..."
        selectObject: "Sound "+name$
        # Timestep (0 = auto), num formants, max formant, window len, preemphasis freq
        formant = To Formant (burg): 0, numFormants, maxFormant, 0.025, 50
        selectObject: "Formant "+name$
        appendInfoLine: "Adjusting formants..."
        Formula (frequencies): ~ if row = 1 then animalF1 + (animalF1 * ((self - humanF1) / self))  else self fi
        Formula (frequencies): ~ if row = 2 then animalF2 + (animalF2 * ((self - humanF2) / self))  else self fi
        for formantN from 3 to numFormants + 1
            expected = humanF1 + (humanDF * (formantN - 1))
            animal = animalF1 + (animalDF * (formantN - 1))
            Formula (frequencies): ~ if row = formantN then animal + (animal * ((self - expected) / self))  else self fi
        endfor
        selectObject: "Sound "+name$, "Formant "+name$
        Filter
        outf$ = outdir$ + name$ + ".Sound"
        selectObject: "Sound "+name$
        Save as binary file: outf$
    endif
endfor
select all
Remove
appendInfoLine: "Output: ", outdir$, newline$, "Done."


# # Extract source from sound
# selectObject: "Sound "+soundName$
# resample = Resample: 2 * maxFormant, 50
# selectObject: resample
# # Prediction order (16 default), window length, timestep, preemphasis freq
# lpc = To LPC (burg): 10, 0.025, 0.005, 50
# selectObject: resample, lpc
# filtered = Filter (inverse)

# startT = 0.0
# endT = 1.0
# voicelessStartT = 0.0
# voicelessEndT = 0.02
# intensityPointT = 0.1
# intensityPointI = 60
# f0 = 73
# factor = 0.5
# sampleRate = 44100
# # Create pitch
# pitchTier = Create PitchTier: "source", startT, endT
# Add point: 0.0, f0
# Add point: 1.0, f0
# ## Make parts voiceless
# Remove points between: voicelessStartT, voicelessEndT
# # Convert to sound
# source = To Sound (phonation): sampleRate, 0.6, 0.05, 0.7, 0.03, 3.0, 4.0
# # Modify intensity
# Create IntensityTier: "intens", startT, endT
# Add point: intensityPointT, intensityPointI
# selectObject: source
# ## Create filter (start, end, nformants, F1 Hz, formant dispersion, min bandwidth, bandwidth spacing)
# Create FormantGrid: "filter", startT, endT, 10, 550, 1100, 60, 50
# ## Create formant contours: F1 rises from 100 to 700 Hz and F2 from 500 to 1100 Hz in 0.05s. Other formants remain
# Remove formant points between: 1, startT, endT
# Add formant point: 1, 0.00, 100
# Add formant point: 1, 0.05, 700
# Remove formant points between: 2, 0.0, 1.0
# Add formant point: 2, 0.00, 500
# Add formant point: 2, 0.05, 1100

# # Perform synthesis from source and LPC filter
# selectObject: "Sound source", "LPC filter"
# Filter: "no"

# # For formantgrid filter
# selectObject: "Sound source", "FormantGrid filter"
# Filter