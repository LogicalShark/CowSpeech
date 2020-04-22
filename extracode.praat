

# Extracting part of a sound
# dur = durDict["SIL_" + phon$]
selectObject: "Sound " + name$
totalDur = Get total duration
part = Extract part: totalDur - (dur/1000), totalDur, "rectangular", 1, 0 
newSound = part
