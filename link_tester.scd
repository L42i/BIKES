s.waitForBoot({

	~kick = Buffer.read(s,thisProcess.nowExecutingPath.dirname +/+ "B_Drum_2_MONO.wav");

		SynthDef( \simple_sample, {

			|
			out_bus   = 0,
			rate      = 1,
			gain      = 1,
			gate      = nil,
			bufferNr  = 0,
			startpos  = 0|

			var sig = PlayBuf.ar(1, bufferNr, rate * BufRateScale.kr(bufferNr), gate, startpos*BufFrames.kr(bufferNr));

			Out.ar(out_bus, gain * sig);

		}).add;

s.sync;

		~tree_percussion_1 = Synth( \simple_sample,
			[\bufferNr, ~kick.bufnum, \gain, 0], target: s
		);



s.sync;

	Pbindef(\perc_1, \type, \set, \args, #[\gate, \gain] ,\id, ~tree_percussion_1);


	~shared_CLOCK  = LinkClock(1).latency_(Server.default.latency);




	Pbindef(\perc_1,
		\dur, 1/4,
		\gate, Pseq(
			[
				Pseq([1,1,1,1,1,1,1,1],1),
				Pseq([0,0,0,0,0,0,0,0],1),
		], inf),
		\gain, Pseq(
			[
				Pseq([1,1,1,1,1,1,1,1],1),
				Pseq([0,0,0,0,0,0,0,0],1),
		], inf),
		\rate, 1,
	).play(~shared_CLOCK,nil,4);


	~shared_CLOCK.tempo = 2;


	~shared_CLOCK.latency = -0.01;

	{
		var columns, win, slider, temp, temp2, fixedx, userView, volumeSlider, lpfSlider;

		columns = [0.25, 0.5, 0.75, 1];
		win = Window("2D Slider + Controls", Rect(200, 200, 300, 400)).fullScreen;

		slider = Slider2D(win, Rect(40, 40, 520, 520))
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

		volumeSlider = EZSlider(
			parent: win,
			bounds: Rect(610, 200, 400, 100),
			label: "Volume",
			controlSpec: ControlSpec(0, 1, \lin, 0.01, 0.1),
			action: { |ez|
				~sampleLayerSynths.do { |synth| synth.set(\volume, ez.value) };
			},
			labelWidth: 60
		);

		lpfSlider = EZSlider(
			parent: win,
			bounds: Rect(610, 400, 400, 100),
			label: "LowPass",
			controlSpec: ControlSpec(2, 10, \exp, 1, 1),
			action: { |ez|
				~shared_CLOCK.tempo = ez.value;
			},
			labelWidth: 60
		);
	}.();

});







