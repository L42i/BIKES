// BASIC SETUP FOR "STICKY" GRANULAR SYNTHESIZER FOR UROP
// Synth Architecture Taken from: https://www.youtube.com/watch?v=WBqAM_94TW4 , shoutout Eli Fieldsteel

(
s.waitForBoot({
    var notes, rootNote, win, noteNames, activeSynths;

    // 1. Load the Buffer
	b = Buffer.readChannel(s, "YOUR FILEPATH HERE/Angelic Vocal FX 01.wav", channels: [0]); // Complete Directory with your filepath

    // 2. Updated SynthDef with a Gate
    SynthDef.new(\gs, {
        arg sync=0, dens=60, dur=0.4, durRand=0.5, durHz=0.3, buf=0,
        rate=1, pos=0.1, posSpeed=0.1, posRand=0.05,
        grainEnv=(-1), pan=0, panHz=0.1, panRand=0,
        atk=0.5, rel=2, gate=1, amp=0.3, out=0; // Added gate

        var sig, env, trigger, durCtrl, posCtrl, panCtrl;

        // Env.asr sustains as long as gate is 1
        env = EnvGen.ar(
            Env.asr(atk, 1, rel),
            gate,
            doneAction: 2
        );

        trigger = Select.ar(sync, [Dust.ar(dens ! 2), Impulse.ar(dens ! 2)]);
        durCtrl = dur * LFNoise1.kr(durHz ! 2).exprange(1 - durRand, 1 + durRand);

        posCtrl = Phasor.ar(0, posSpeed * BufRateScale.ir(buf), 0, BufSamples.ir(buf) - 1);
        posCtrl = posCtrl + LFNoise1.ar(100 ! 2).bipolar(posRand * SampleRate.ir);
        posCtrl = (posCtrl / BufSamples.ir(buf) + pos).wrap(0, 1);

        panCtrl = pan + LFNoise1.kr(panHz ! 2).bipolar(panRand);

        sig = GrainBuf.ar(2, trigger, durCtrl, buf, rate, posCtrl, 2, panCtrl, grainEnv);
        Out.ar(out, sig * env * amp);
    }).add;

    s.sync;

    // 3. GUI Logic
    rootNote = 70; // A#4
    notes = (60..72);
    noteNames = ["C", "C#", "D", "D#", "E", "F", "F#", "G", "G#", "A", "A#", "B"];

    // Array to store active Synth nodes (one for each possible MIDI note)
    activeSynths = Array.newClear(128);

    win = Window("Sticky Granular Piano", Rect(200, 200, 550, 150)).front;
    win.view.decorator = FlowLayout(win.view.bounds, 10@10, 5@5);

    notes.do({ |midi|
        var button, label, ratio, name, octave;

        name = noteNames[midi % 12];
        octave = (midi / 12).floor - 1;
        label = name ++ octave.asString;
        ratio = (midi - rootNote).midiratio;

        button = Button(win, Rect(0, 0, 40, 80))
            .states_([
                [label, Color.black, Color.gray(0.9)], // State 0: OFF
                [label, Color.white, Color.red(0.6)]   // State 1: ON
            ])
            .action_({ |btn|
                if (btn.value == 1) {
                    // Start the synth and store it in the array
                    activeSynths[midi] = Synth.new(\gs, [
                        \buf, b,
                        \rate, ratio,
                        \amp, 0.2,
                        \pos, 0.1,
                        \gate, 1
                    ]);
                } {
                    // Turn off the specific synth for this note
                    activeSynths[midi].set(\gate, 0);
                    activeSynths[midi] = nil;
                };
            });
    });

    win.onClose = { activeSynths.do(_.set(\gate, 0)) }; // Clean up on window close
    "Sticky Piano Ready. Root: A#4".postln;
});
)
