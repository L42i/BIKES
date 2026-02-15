s.waitForBoot({

	~kick = "";

	thisProcess.nowExecutingPath.dirname.postln;



	if(("hostname".unixCmdGetStdOut).contains("zs-MBP-6"))
	{
		~kick = Buffer.read(s,thisProcess.nowExecutingPath.dirname +/+ "three/Bass.wav");

	};
	if(("hostname".unixCmdGetStdOut).contains("student8"))
	{
		~kick = Buffer.read(s,thisProcess.nowExecutingPath.dirname +/+ "three/Kick.wav");
	};
	if(("hostname".unixCmdGetStdOut).contains("student10"))
	{
		~kick = Buffer.read(s,thisProcess.nowExecutingPath.dirname +/+ "three/Bass.wav");
	};
	if(("hostname".unixCmdGetStdOut).contains("student11"))
	{
		~kick = Buffer.read(s,thisProcess.nowExecutingPath.dirname +/+ "three/VibePerc.wav");
	};
	if(("hostname".unixCmdGetStdOut).contains("student12"))
	{
		~kick = Buffer.read(s,thisProcess.nowExecutingPath.dirname +/+ "three/VocoPerc.wav");
	};


		SynthDef( \simple_sample, {

			|
			out_bus   = 0,
			rate      = 1,
			gain      = 1,
			gate      = nil,
			bufferNr  = 0,
			startpos  = 0,
		    lpfFreq = 16000
		|

			var sig = PlayBuf.ar(1, bufferNr, rate * BufRateScale.kr(bufferNr), gate, startpos*BufFrames.kr(bufferNr));
		    var filtered = LPF.ar(sig, lpfFreq);

		Out.ar(out_bus, gain * filtered);

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
				Pseq([1,1,1,1,1,1,1,1],7),
				Pseq([1,1,1,1,1,1,1,0],1),
		], inf),
		\gain, 1,
		\rate, 1,
	).play(~shared_CLOCK,nil,4);


	~shared_CLOCK.tempo = 4.13;


	~shared_CLOCK.latency = -0.00;

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

		lpfSlider = EZSlider(
			parent: win,
			bounds: Rect(610, 400, 400, 100),
			label: "Low Pass",
			controlSpec:  ControlSpec(100, 20000, \exp, 1, 20000),
			action: { |ez|

				~tree_percussion_1.set(\lpfFreq, ez.value)
			},
			labelWidth: 60
		);

		volumeSlider = EZSlider(
			parent: win,
			bounds: Rect(610, 200, 400, 100),
			label: "Latency",
			controlSpec: ControlSpec(0, 1, \lin, 0.1, 0.1),
			action: { |ez|
				~shared_CLOCK.latency = ez.value;

			},
			labelWidth: 60
		);


	}.();

});






