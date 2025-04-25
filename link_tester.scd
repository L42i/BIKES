
s.boot;

~kick = Buffer.read(s,"/home/student/Desktop/B_Drum_2.wav");

(
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
)


		~tree_percussion_1 = Synth( \simple_sample,
			[\bufferNr, ~kick.bufnum, \gain, 0], target: s
		);


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

~shared_CLOCK.tempo = 5


~shared_CLOCK.latency = -0.01