s.waitForBoot({
	{
	s.options.sampleRate = 441000;
	}.();

    {
        ~sampleLayerBuffer = Buffer.read(s, thisProcess.nowExecutingPath.dirname +/+ "stems/background.wav");
    }.();

    {
        SynthDef(\sampleLayer, {
            | buf, out = 0, volume = 0.1, pitchRatio = 1, infVerb = 0 |
            var sound, finalSound, reverb;
            sound = PlayBuf.ar(2, buf, loop: 1);
            finalSound = PitchShift.ar(sound, 0.2, pitchRatio, 0.0, 0.0, 1.0, 0.0);
            reverb = FreeVerb.ar(finalSound, infVerb, infVerb, 0.3);
            Out.ar(out, reverb * volume);
        }).add;
    }.();

    {
        s.sync;
        ~sampleLayerSynths = [0, 2].collect { |i| Synth(\sampleLayer, [\buf, ~sampleLayerBuffer, \out, i]) };
    }.();

    {
        var columns, win, slider, temp, temp2, fixedx, userView, volumeSlider;

        columns = [0.25, 0.5, 0.75, 1];
        win = Window("2D Slider + Volume", Rect(200, 200, 300, 350)).front; // Increased height for EZSlider

        // Original Slider2D (unchanged)
        slider = Slider2D(win, Rect(20, 20, 260, 260))
            .background_(Color.gray)
            .action_({ |sld|
                var freqIndex, freq;
                var frequencies = [261.63, 293.66, 329.63, 349.23, 392, 440, 493.88, 523.25];
                freqIndex = (sld.y * 7).floor;
                freq = frequencies[freqIndex];
                temp2 = sld.x.linexp(0, 1, 1, 5);

                if (sld.x <= 0.25, { temp2 = 0.5 },
                    { if (sld.x <= 0.5, { temp2 = 1 },
                        { if (sld.x <= 0.75, { temp2 = 1.5 },
                            { if (sld.x <= 1, { temp2 = 2 }) }
                        )}
				)};

                [freq, temp2].postln;
                { SinOsc.ar(freq: freq) * 0.5 * EnvGen.kr(Env.perc(releaseTime: temp2 - 0.01), doneAction: temp2) }.play;
		)});

        fixedx = 0.2;

        // UserView for grid lines (unchanged)
        userView = UserView(win, slider.bounds)
            .background_(Color.clear)
            .canFocus_(false)
            .acceptsMouse_(false)
            .drawFunc_({
                var lineX, lineY;
                Pen.color = Color.red;
                columns.do { |col|
                    lineX = slider.bounds.width * col;
                    Pen.line(Point(lineX, 0), Point(lineX, slider.bounds.height));
                };
                Pen.stroke;
                Pen.color = Color.blue;
                7.do { |i|
                    lineY = slider.bounds.height * (i + 1) / 8;
                    Pen.line(Point(0, lineY), Point(slider.bounds.width, lineY));
                };
                Pen.stroke;
            });

        // Add EZSlider BELOW the Slider2D (new)
		volumeSlider = EZSlider(
            parent: win,
            bounds: Rect(100, 700, 700, 100), // Positioned below Slider2D (Y = 290)
            label: "Volume",
            controlSpec: ControlSpec(0, 1, \lin, 0.01, 0.1),
            action: { |ez|
                ~sampleLayerSynths.do { |synth| synth.set(\volume, ez.value) };
            },
            labelWidth: 60
        );

		// Add EZSlider BELOW the Slider2D (new)



    }.();
});