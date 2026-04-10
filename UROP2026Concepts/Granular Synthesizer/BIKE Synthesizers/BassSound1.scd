// BASIC SETUP FOR "STICKY" GRANULAR SYNTHESIZER FOR UROP
// Synth Architecture Taken from: https://www.youtube.com/watch?v=WBqAM_94TW4 , shoutout Eli Fieldsteel
s.meter;
FreqScope.new(400, 200, 0, server: s);
s.options.numInputBusChannels = 0;

(
s.waitForBoot({
    var notes, rootNote, win, win2, noteNames, activeSynths;
    var dens_Dial, dur_Dial, pos_Dial, size=64;

    // Variables to track current state for new notes
    var currentDens = 60;
    var currentDur = 0.4;
    var currentPos = 0.1;

    b = Buffer.readChannel(s, "/Users/lauracall-gomez/Desktop/BIKES/UROP2026Concepts/Granular Synthesizer/Audio Files/BassSoundC1.wav", channels: [0]); // LOAD FILEPATH

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

    rootNote = 24;
    notes = (24..36);
    noteNames = ["C", "C#", "D", "D#", "E", "F", "F#", "G", "G#", "A", "A#", "B"];
    activeSynths = Array.newClear(128);

    // --- Keyboard Window ---
    win = Window("Sticky Granular Piano", Rect(200, 400, 550, 150)).front;
    win.view.decorator = FlowLayout(win.view.bounds, 10@10, 5@5);

    notes.do({ |midi|
        var button, label, ratio, name, octave;
        name = noteNames[midi % 12];
        octave = (midi / 12).floor - 1;
        label = name ++ octave.asString;
        ratio = (midi - rootNote).midiratio;

        button = Button(win, Rect(0, 0, 40, 80))
            .states_([[label, Color.black, Color.gray(0.9)], [label, Color.white, Color.red(0.6)]])
            .action_({ |btn|
                if (btn.value == 1) {
                    activeSynths[midi] = Synth.new(\gs, [
                        \buf, b,
                        \rate, ratio,
                        \dens, currentDens,
                        \dur, currentDur,   // Use current knob value
                        \pos, currentPos,   // Use current knob value
                        \amp, 0.2,
                        \gate, 1
                    ]);
                } {
                    activeSynths[midi].set(\gate, 0);
                    activeSynths[midi] = nil;
                };
            });
    });

    // --- Control Window ---
    win2 = Window.new("Adjust Synth Params", Rect(200, 200, 400, 300)).front;
    win2.view.decorator = FlowLayout(win2.view.bounds, 20@20, 10@10);

    // 1) Density
    StaticText(win2, Rect(0, 0, 100, 20)).string_("Grain Density");
    dens_Dial = Knob.new(win2, Rect(0, 0, size, size));
    dens_Dial.action_({ |v|
        currentDens = v.value.linexp(0, 1, 10, 200);
        activeSynths.do({ |s| if(s.notNil) { s.set(\dens, currentDens) } });
    });
    dens_Dial.value = currentDens.explin(10, 200, 0, 1);

    // 2) Duration - FIXED: variable name dur_Dial
    StaticText(win2, Rect(0, 0, 100, 20)).string_("Grain Duration");
    dur_Dial = Knob.new(win2, Rect(0, 0, size, size));
    dur_Dial.action_({ |v|
        currentDur = v.value.linexp(0, 1, 0.05, 2);
        activeSynths.do({ |s| if(s.notNil) { s.set(\dur, currentDur) } });
    });
    dur_Dial.value = currentDur.explin(0.05, 2, 0, 1);

    // 3) Position - FIXED: linlin mapping for scrubber feel
    StaticText(win2, Rect(0, 0, 100, 20)).string_("Grain Position");
    pos_Dial = Knob.new(win2, Rect(0, 0, size, size));
    pos_Dial.action_({ |v|
        currentPos = v.value.linlin(0, 1, 0.0, 1.0); // Scrub from 0% to 100%
        activeSynths.do({ |s| if(s.notNil) { s.set(\pos, currentPos) } });
    });
    pos_Dial.value = currentPos.linlin(0.0, 1.0, 0, 1);

    win.onClose = { activeSynths.do(_.set(\gate, 0)); win2.close; };
});
)