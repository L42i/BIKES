//RUN LOCAL AUDIO SERVER
(
s.boot;
s.meter;
)

//Declare Synthdef
(
x = SynthDef(\twodslider, {
	|freq = 400, pan = 0|
	var sig = SinOsc.ar(freq, 0, 0.2);
	Out.ar(0, Pan2.ar(sig, pan));
}).add;

)

//Declare hostName vs peerName
(
~myNode = "Orlando";
~peerNode = "Shirin";

)


//Instantiate Synthdef
(
x = Synth(\twodslider, [\freq, 440]);
)

//Stop Synthdef
(
x.free;
)

//Join the p2psc network
(
fork{
	p = P2PSC();
	p.sync;
	p.setName(~myNode);
	p.sync;
}
)
//2d Slider C major scale
(
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


	if (sld.x<= 0.25, {
		"here".postln;
		temp2 = 0.5;


	},
		{if (sld.x<= 0.5, {temp2 = 1;},
			{if (sld.x<= 0.75, {temp2 = 1.5;},
				{if (sld.x<= 1, {temp2 = 2;})}
			)}
		)}
	);

		(temp2).postln;

	//[freq, temp2].postln; // Post frequency and temp2 values
	p.sendMsg("/" ++ ~peerNode ++ "/ping", freq, temp2);
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
)



//STEP 2: RECEIVER
(
fork {
	p.addPath({ |msg|
		var sleeptime = 1;
				var freq =(msg[1]).asFloat;
				var time =(msg[2]).asFloat;


		msg.postln; //print message for debugging

		fork{
			time.wait;

		{SinOsc.ar(freq:freq)*0.5*EnvGen.kr(Env.perc(releaseTime:sleeptime-0.01), doneAction:2)}.play;

			p.sendMsg("/" ++ ~peerNode ++ "/ping", freq, time);

		}

	},"/ping");
}
)



(
~myNode.free;
~peerNode.free;
)



