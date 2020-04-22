# ----------------------------------------------
# Assembles monophones into synthesized speech |
# ----------------------------------------------

# Store starting objects so they are not deleted in cleanup
select all
objLen = numberOfSelected()
for n to objLen
    objects[n] = selected(n)
endfor

clearinfo
writeInfoLine: "Running context-sensitive monophone synthesizer."
speech$ = "HH AH L OW SIL M AY SIL N EY M SIL IH Z SIL M AA R K AH S SIL"

soundDirectory$ =   "D:/Documents/CS/AnimalSpeech/Sounds/"
outf$ =             "D:/Documents/CS/AnimalSpeech/Generated/test1.wav"
vowelRegex$ = "[(AA)(AE)(AH)(AO)(AW)(AY)(EH)(ER)(EY)(IH)(OW)(OY)(UH)(UW)]_[0-9]"

appendInfoLine: "Processing speech..."
# Split input by " "
length = 0
repeat
    strlen = length(speech$)
    sep = index(speech$, " ")
    if sep > 0
        part$ = left$(speech$, sep-1)
        speech$ = mid$(speech$, sep+1, strlen)
    else
        part$ = speech$
    endif
    length = length+1
    array$[length] = part$
until sep = 0

appendInfoLine: "Finding sounds..."
soundList = Create Strings as file list: "soundList", soundDirectory$ + "*.Sound"
select Strings soundList
numSounds = Get number of strings

x = 0
for n to numSounds
    select Strings soundList
    filename$ = Get string... n
    Read from file... 'soundDirectory$''filename$'
    name$ = filename$ - ".Sound"
    if index_regex(filename$, "_mono_") <> 0
        x = x+1
        phonIndex = index_regex(filename$, "[A-Z]+_[A-Z]+\.Sound") - 1
        phon$ = right$(name$, length(name$) - phonIndex)
        sounds$[x] = phon$
        monoDict$[phon$] = name$
    endif

endfor

appendInfoLine: 'numSounds', " files."

# Start with silence
oldSound = Create Sound from formula... silence 1 0 0.125 44100 0
newSound = Create Sound from formula... silence 1 0 0.125 44100 0
oldPhone$ = "SIL"
oldDur = 125
for i to length
    phon$ = array$ [i]
    silent = 0
    if phon$ = "SIL"
        newSound = Create Sound from formula... silence 1 0 0.125 44100 0
        silent = 1
    endif
    foundCS = 0
    if phon$ <> "SIL"
        for n to x
            if sounds$[n] = oldPhone$ + "_" + phon$
                foundCS = 1
            endif
        endfor
        if foundCS && (oldPhone$ <> "SIL")
            name$ = monoDict$[oldPhone$ + "_" + phon$] 
            appendInfoLine: "Appending CS monophone ", name$
        else
            name$ = monoDict$["SIL_" + phon$]
            appendInfoLine: "Appending monophone ", name$
        endif
        selectObject: "Sound " + name$
        newSound = selected("Sound", 1)
        dur = Get total duration
    endif
    select newSound
    newSound = Copy: string$(i) + "_" + oldPhone$ + "_" + phon$
    select newSound
    plus oldSound
    # cross = 0.001
    d = min(oldDur, dur)
    cross = min(d / 4000, 0.025)
    oldSound = Concatenate with overlap... cross
    oldPhone$ = phon$
    oldDur = dur
endfor

selectObject: oldSound
Save as WAV file: outf$

# Don't delete preexisting objects
select all
for n to objLen
    minus objects[n]
endfor
minus oldSound
Remove

appendInfoLine: "Output: ", outf$, newline$, "Done."