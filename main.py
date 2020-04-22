import parselmouth
from parselmouth.praat import call
from IPython.display import Audio

# Pressure: cm H2O
# Frequency: Hz
# Elasticity: kPa
control = "HumanM"
animal = "Dog"
soundFile = "hello"
ctrlDict = {}
animDict = {}

def change_pitch(sound, factor, minf = 75, maxf = 600):
    manipulation = call(sound, "To Manipulation", 0.001, minf, maxf)
    pitch_tier = call(manipulation, "Extract pitch tier")
    call(pitch_tier, "Multiply frequencies", sound.xmin, sound.xmax, factor)
    call([pitch_tier, manipulation], "Replace pitch tier")
    return call(manipulation, "Get resynthesis (overlap-add)")


def createDictionary(lines):
    d = {}
    for line in lines:
        a = line.split(" ")
        d[a[0]] = [float(x) for x in a[1:]]
    return d

def relativeFactor(f):
    return animDict[f][0]/ctrlDict[f][0]

def relativeValue(f, val):
    control = ctrlDict[f]
    animal = animDict[f]
    if len(control) == 2 and len(animal) == 2:
        # Standard deviations away from mean
        stdAway = (val - control[0]) / control[1]
        return (stdAway * animal[1]) + animal[0]
    if len(control) == 1 and len(animal) == 1:
        return val * animal[0]/control[0]

if __name__ == "__main__":
    sound = parselmouth.Sound("Audio/"+soundFile+".wav")
    with open("AnimalData/"+control, 'r') as file:
        ctrlines = file.readlines()
    with open("AnimalData/"+animal, 'r') as file:
        anmlines = file.readlines()
    ctrlDict = createDictionary(ctrlines)
    animDict = createDictionary(anmlines)
    print(relativeFactor("F0"))
    sound2 = change_pitch(sound, relativeFactor("F0"))
    sound2.save(soundFile+"_pitched.wav", "WAV")

    val = 0
    # Fundamental frequency
    if val == "F0":
        pass
    # Phonation threshold pressure
    if val == "PTP":
        pass
    # Subglottal pressure
    if val == "PS":
        pass
    # Sound pressure level
    if val == "SPL":
        pass
    # Vocal fold elasticity (Young's modulus)
    if val == "YM":
        pass
    # Pitch slope with normal pressures
    if val == "TPSL":
        pass
    # Average pitch slope on all pressures
    if val == "APSL":
        pass
    # Min frequency
    if val == "F0MIN":
        pass
    # Max frequency
    if val == "F0MAX":
        pass
    # Mucous thickness (mm)
    if val == "MTH":
        pass
    # Number of formants
    if val == "NF":
        pass
    # Formant dispersion
    if val == "DF":
        pass
    # Formants
    if val == "F1":
        pass
    if val == "F2":
        pass
