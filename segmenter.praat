# ----------------------------------------------------------------------------
# Extracts each nonempty segment from textgrids, recording preceding phoneme |
# ----------------------------------------------------------------------------

# Store starting objects so they are not deleted in cleanup
select all
objLen = numberOfSelected()
for n to objLen
    objects[n] = selected(n)
endfor

directory$ =    "D:/Documents/CS/AnimalSpeech/Audio/"
outdir$ =       "D:/Documents/CS/AnimalSpeech/Sounds/"
phonTier = 1

clearinfo
writeInfoLine: "Running segmenter."

# Collect sounds
appendInfoLine: "Collecting sounds from", directory$, "..." 
soundList = Create Strings as file list: "soundList", directory$ + "*.wav"
select Strings soundList
numSounds = Get number of strings
for n to numSounds
    select Strings soundList
    filename$ = Get string... n
    Read from file... 'directory$''filename$'
endfor

# Collect TextGrids
appendInfoLine: "Collecting TextGrids from", directory$, "..." 
gridList = Create Strings as file list: "gridList", directory$ + "*.TextGrid"
select Strings gridList
numGrids = Get number of strings
if numSounds <> numGrids
    appendInfoLine: "Mismatch: ", 'numSounds', " sounds, ", 'numGrids', " TextGrids."
endif
for n to numGrids
    select Strings gridList
    filename$ = Get string... n
    Read from file... 'directory$''filename$'
    objects$[numGrids + n] = "TextGrid " + filename$
endfor

# Read each file
appendInfoLine: "Extracting segments from ", 'numSounds', " files..."
for n from 1 to numSounds
    select Strings soundList
    name$ = Get string: 'n'
    name$ = name$ - ".wav"
    appendInfoLine: "Checking ", name$, "..."
    select TextGrid 'name$'
    numPhonemes = Get number of intervals: phonTier

    appendInfoLine: numPhonemes, " intervals detected."
    prevPhoneme$ = "SIL"
    prevStart = 0
    start = 0
    # Extract each interval from the file
    for i from 1 to numPhonemes
        select TextGrid 'name$'
        phoneme$ =  Get label of interval: phonTier, i
        start =     Get start point: phonTier, i
        end   =     Get end point: phonTier, i
        id$ = name$ + "_" + string$(i)
        if phoneme$ <> ""
            # Extract context-sensitive monophone
            select Sound 'name$'
            Edit
            editor Sound 'name$'
                Select... 'start' 'end'
                Extract selection
                Close
            endeditor
            outf$ = outdir$ + id$ + "_mono_" + prevPhoneme$ + "_" + phoneme$ + ".Sound"
            Write to binary file: outf$

            # Extract diphone
            if prevPhoneme$ <> "SIL"
                select Sound 'name$'
                Edit
                editor Sound 'name$'
                    Select... 'prevStart' 'end'
                    Extract selection
                    Close
                endeditor
                dur = round(1000 * (end - start))
                outf$ = outdir$ + id$ + "_diph_" + prevPhoneme$ + "_" + phoneme$ + "_" + string$(dur) + ".Sound"
                Write to binary file: outf$
            endif
        endif
        prevStart = start
        prevPhoneme$ = phoneme$
        if phoneme$ == ""
            prevPhoneme$ = "SIL"
        endif
    endfor
endfor

# Clean up objects except preexisting and output sound
appendInfoLine: newline$, "Output: ", outdir$, newline$, "Done."
select all
for n to objLen
    minus objects[n]
endfor
Remove