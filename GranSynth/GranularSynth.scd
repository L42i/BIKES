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


// NEW CODE  WORKS!!!


s.waitForBoot({
	// Load a sample buffer (replace with your own path)
	b = Buffer.read(s,"/Users/jacobwesterstahl/Desktop/GranSynth/Additive Squish 2.wav"); //Platform.resourceDir +/+

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


		// Make sure the slider starts at a valid position
		slider.setXY(0.5, 0.5);

		win.onClose = {
			~grainSynth.free;
			b.free; // Also free the buffer
		};
	}.();
});


