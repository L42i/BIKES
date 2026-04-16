(
s.waitForBoot({

	var path, rootNote;
    var currentDens = 60;
    var currentDur = 0.4;
    var currentPos = 0.1;

    // Set base MIDI note to align with AtmosphericC2.wav
    rootNote = 60;

    // --- 2. Resolve Relative Path & Load Buffer ---
    ~absolutePrefix = thisProcess.nowExecutingPath.dirname.dirname;
    path = ~absolutePrefix +/+ "Audio Files" +/+ "PadSoundC4.wav";
    b = Buffer.readChannel(s, path, channels: [0]);

    // --- 3. Granular SynthDef ---
    SynthDef.new(\gs, {
        arg sync=0, dens=60, dur=0.4, durRand=0.5, durHz=0.3, buf=0,
        rate=1, pos=0.1, posSpeed=0.1, posRand=0.05,
        grainEnv=(-1), pan=0, panHz=0.1, panRand=0,
        atk=0.5, rel=2, gate=1, amp=0.3, out=0;

        var sig, env, trigger, durCtrl, posCtrl, panCtrl;

        env = EnvGen.ar(Env.asr(atk, 1, rel), gate, doneAction: 2);

        trigger = Select.ar(sync, [Dust.ar(dens ! 2), Impulse.ar(dens ! 2)]);
        durCtrl = dur * LFNoise1.kr(durHz ! 2).exprange(1 - durRand, 1 + durRand);

        // Position: Linear sweep + Jitter + Manual Offset
        posCtrl = Phasor.ar(0, posSpeed * BufRateScale.ir(buf), 0, BufSamples.ir(buf) - 1);
        posCtrl = posCtrl + LFNoise1.ar(100 ! 2).bipolar(posRand * SampleRate.ir);
        posCtrl = (posCtrl / BufSamples.ir(buf) + pos).wrap(0, 1);

        panCtrl = pan + LFNoise1.kr(panHz ! 2).bipolar(panRand);

        sig = GrainBuf.ar(2, trigger, durCtrl, buf, rate, posCtrl, 2, panCtrl, grainEnv);
        Out.ar(out, sig * env * amp);
    }).add;

    s.sync;

    // 1. Data Lookups
    ~noteMap = ( 'C': 0, 'C#': 1, 'D': 2, 'D#': 3, 'E': 4, 'F': 5, 'F#': 6, 'G': 7, 'G#': 8, 'A': 9, 'A#': 10, 'B': 11 );
    ~scales = (
        'Major':      [0, 2, 4, 5, 7, 9, 11],
        'Minor':      [0, 2, 3, 5, 7, 8, 10],
        'Dorian':     [0, 2, 3, 5, 7, 9, 10],
        'Mixolydian': [0, 2, 4, 5, 7, 9, 10]
    );

    // --- IMPORTANT: Initialize with defaults so math doesn't fail ---
    ~currentRoot = 'C';     // Use Symbols (with single quotes)
    ~currentScale = 'Major';
    ~currentDegree = 1;
    ~currentSynth = nil;

    // 2. The Play Function
    // --- 5. OSC Playback Logic (Adapted for Granular \gs) ---
    ~playNote = { |rootName, scaleName, degree|
        var rootMidi, noteMidi, ratio;

        // Base 36 aligns with the Granular Synth's starting C2 frequency
        rootMidi = rootNote + ~noteMap[rootName.asSymbol];
        noteMidi = rootMidi + ~scales[scaleName.asSymbol][degree.asInteger - 1];
        ratio = (noteMidi - rootNote).midiratio; // Convert difference into playback speed

        if (~activeSynth.notNil && { ~activeSynth.isPlaying }) {
            // If already playing, sweep the rate rather than freq
            ~activeSynth.set(\rate, ratio);
        } {
            // If starting a new note, instantiate \gs with static variables
            ~activeSynth = Synth(\gs, [
                \buf, b,
                \rate, ratio,
                \dens, currentDens,
                \dur, currentDur,
                \pos, currentPos,
                \amp, 0.2,
                \gate, 1
            ]).register;
        };
    };

    // 3. OSC Definitions
    OSCdef(\updateContext, { |msg|
        ~currentRoot = msg[1].asSymbol;
        ~currentScale = msg[2].asSymbol;
        ~currentDegree = msg[3].asInteger;
        "Context: % % %".format(~currentRoot, ~currentScale, ~currentDegree).postln;
    }, "/remoteChord");

    OSCdef(\localRelay, { |msg|
        var btnIdx = msg[1].asInteger;
        var isOn   = msg[2].asInteger;
        if(isOn == 1) {
            { ~playChordTone.value(btnIdx) }.defer;
        } {
            { if(~currentSynth.notNil) { ~currentSynth.release; ~currentSynth = nil; } }.defer;
        };
    }, "/localChord");

    "Receiver Ready".postln;
});
)