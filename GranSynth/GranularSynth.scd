s.options.sampleRate = 44100;
s.boot;

(
s.meter;
s.plotTree;
s.scope;
);
//Couldn't get relative path to work so just edit this for wherever the file is on your machine
b = Buffer.read(s, "/Users/jacobwesterstahl/Desktop/GranSynth/Additive Squish 2.wav", channels:[0]);
b.play;

//Signal.hanningWindow(1024).plot

b.numChannels;
//b.free;

FreqScope.new;
//OLD CODE!!!!
(
{
	{
		x = SynthDef(\twodslider, {
			|freq = 400, pan = 0|
			var sig = SinOsc.ar(freq, 0, 0.2);
			//Out.ar(0, Pan2.ar(sig, pan));
		}).add;

	}.();


	{
		var columns, win, slider, temp, temp2, fixedx, userView, freq;

		~freq = 440;
		~temp2 = 2;

		columns = [0.25, 0.5, 0.75, 1];
		win = Window("2D Slider", Rect(200, 200, 300, 300)).front;
		slider = Slider2D(win, Rect(20, 20, 260, 260)).background_(Color.gray).action_({|sld|
			var freqIndex, ~freq;

			// Define an array of frequencies for each horizontal line
			var frequencies = [261.63, 293.66, 329.63, 349.23, 392, 440, 493.88, 523.25]; // 8 frequencies for 7 lines

			// Map y-position to the corresponding frequency
			freqIndex = (sld.y * 7).floor; // Determine which horizontal line the slider is closest to
			~freq = frequencies[freqIndex]; // Get the frequency for that line

			// Map x-position to a value (as before
			~temp2 = sld.x.linexp(1, 1, 1, 5);

			if (sld.x<= 0.25, {~temp2 = 0.5;},
				{if (sld.x<= 0.5, {~temp2 = 1;},
					{if (sld.x<= 0.75, {~temp2 = 1.5;},
						{if (sld.x<= 1, {~temp2 = 2;})}
					)}
				)}
			);

			[freq, temp2].postln; // Post frequency and temp2 values
			{SinOsc.ar(freq:freq)*0.5*EnvGen.kr(Env.perc(releaseTime:temp2-0.01), doneAction:2)}.play;
			//p.sendMsg("/" ++ "Laura" ++ "/ping", freq, temp2);
		});

		fixedx = 0.2;

		userView = UserView(win, slider.bounds)
		.background_(Color.clear)
		.canFocus_(false)
		.acceptsMouse_(false)
		.drawFunc_({
			var lineX, lineY;

			// Draw vertical lines (along y-axis) in red
			Pen.color = Color.red; // Set color to red for vertical lines
			columns.do { |col|
				lineX = slider.bounds.width * col;
				Pen.line(Point(lineX, 0), Point(lineX, slider.bounds.height));
			};
			Pen.stroke; // Stroke the vertical lines

			// Draw 7 equally spaced horizontal lines in blue
			Pen.color = Color.blue; // Set color to blue for horizontal lines
			7.do { |i|
				lineY = slider.bounds.height * (i + 1) / 8; // Equally spaced lines
				Pen.line(Point(0, lineY), Point(slider.bounds.width, lineY));
			};
			Pen.stroke; // Stroke the horizontal lines
		});
		//if (0 < temp2[0] , { 100 } , { 200 });
		{
	var sig, startPos;
	sig = GrainBuf.ar(
		2,
				Impulse.ar({ExpRand(~temp2,~freq)}!12),
		0.09,//MouseX.kr(0.0002, 0.13, 1, 0.2).poll, //# of grains/second LFNoise1.kr(0.3!2).exprange(.0002, 0.1),       //
		b, //name of the buffer
		1, // ratio of playback speed
		LFNoise1.ar.range(0,5), //starting position of grain
		1, //type of sample interpolation
		0, //pan position
		-1, //envbufnum
		512 //max amount of grains

	);
	//sig = sig * 0.5;
}.play;

	}.();

}.();

)








// NEW CODE ALMOST WORKS!!!


s.waitForBoot({
	// Load a sample buffer (replace with your own path)
	b = Buffer.read(s, Platform.resourceDir +/+ "sounds/a11wlk01.wav");

	// Create control busses
	~freqBus = Bus.control(s, 1).set(440);
	~temp2Bus = Bus.control(s, 1).set(1);

	// Grain player SynthDef
	SynthDef(\grainPlayer, {
		var freq = In.kr(~freqBus);
		var density = In.kr(~temp2Bus);
		var sig;

		sig = GrainBuf.ar(
			2,                      // stereo
			Impulse.ar(density * 10), // grain density
			0.09,                   // grain duration
			b,                      // buffer
			LFNoise1.kr(0.2).range(0.5, 2), // playback rate
			LFNoise1.kr(0.1).range(0, 1),   // position
			2,                      // interpolation
			LFNoise1.kr(0.3).range(-1, 1), // panning
			-1,                     // env buffer
			512                     // max grains
		);
		Out.ar(0, sig * 0.5);
	}).add;

	s.sync;

	~grainSynth = Synth(\grainPlayer);

	// GUI setup
	{
		var win, slider, userView;
		var frequencies = [261.63, 293.66, 329.63, 349.23, 392, 440, 493.88, 523.25];

		win = Window("2D Grain Controller", Rect(200, 200, 300, 300)).front;

		// Correct variable name (was 'slider' with extra 'l')
		slider = Slider2D(win, Rect(20, 20, 260, 260))
		.background_(Color.gray)
		.action_({|sld|
			// Vertical position controls frequency
			var freqIndex = (sld.y * 7).floor.clip(0, 7);
			var freq = frequencies[freqIndex];

			// Horizontal position controls grain density
			var temp2 = case
			{ sld.x <= 0.25 } { 0.5 }
			{ sld.x <= 0.5 } { 1 }
			{ sld.x <= 0.75 } { 1.5 }
			{ sld.x <= 1 } { 2 };

			~freqBus.set(freq);
			~temp2Bus.set(temp2);

			// Visual feedback
			["Freq:".post; freq.postln; "Density:".post; temp2.postln];
		});

		// Grid drawing
		userView = UserView(win, slider.bounds)
		.drawFunc_({
			// Vertical lines (red)
			Pen.color = Color.red(0.7, 0.5);
			[0.25, 0.5, 0.75].do { |col|
				Pen.line(
					Point(col * slider.bounds.width, 0),
					Point(col * slider.bounds.width, slider.bounds.height)
				);
			};

			// Horizontal lines (blue)
			Pen.color = Color.blue(0.7, 0.5);
			7.do { |i|
				var y = (i + 1) / 8 * slider.bounds.height;
				Pen.line(Point(0, y), Point(slider.bounds.width, y));
			};
			Pen.stroke;
		});

		// Make sure the slider starts at a valid position
		slider.setXY(0.5, 0.5);

		win.onClose = {
			~grainSynth.free;
			b.free; // Also free the buffer
		};
	}.();
});

