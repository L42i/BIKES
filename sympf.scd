s.waitForBoot({


	{
		~sampleLayerBuffer = Buffer.read(s, thisProcess.nowExecutingPath.dirname +/+ "stems/background.wav");
	}.();

	{
		SynthDef(\sampleLayer, {
	 | buf, out = 0, volume = 0.1, pitchRatio = 1, infVerb = 0|

    var sound, finalSound, reverb;

    // Play the buffer
    sound = PlayBuf.ar(2, buf, loop: 1);

	finalSound = PitchShift.ar(sound,0.2, pitchRatio, 0.0, 0.0, 1.0, 0.0);

	reverb = FreeVerb.ar(finalSound, infVerb, infVerb, 0.3);

    // Output to specified channel
    Out.ar(out, reverb * volume); // Scale down the output level


}).add;
	}.();


{

		s.sync;

		~sampleLayerSynths = [0, 2].collect { |i| Synth(\sampleLayer, [\buf, ~sampleLayerBuffer,\out, i,])};



}.();


	{
		var columns, win, slider, temp, temp2, fixedx, userView;

		columns = [0.25, 0.5, 0.75, 1];
		win = Window("2D Slider", Rect(200, 200, 300, 300)).front;
		slider = Slider2D(win, Rect(20, 20, 260, 260)).background_(Color.gray).action_({|sld|
			var freqIndex, freq;

			// Define an array of frequencies for each horizontal line
			var frequencies = [261.63, 293.66, 329.63, 349.23, 392, 440, 493.88, 523.25]; // 8 frequencies for 7 lines

			// Map y-position to the corresponding frequency
			freqIndex = (sld.y * 7).floor; // Determine which horizontal line the slider is closest to
			freq = frequencies[freqIndex]; // Get the frequency for that line

			// Map x-position to a value (as before)
			temp2 = sld.x.linexp(0, 1, 1, 5);

			if (sld.x<= 0.25, {temp2 = 0.5;},
				{if (sld.x<= 0.5, {temp2 = 1;},
					{if (sld.x<= 0.75, {temp2 = 1.5;},
						{if (sld.x<= 1, {temp2 = 2;})}
					)}
				)}
			);

			[freq, temp2].postln; // Post frequency and temp2 values
			{SinOsc.ar(freq:freq)*0.5*EnvGen.kr(Env.perc(releaseTime:temp2-0.01), doneAction:temp2)}.play;
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

	}.();








});




