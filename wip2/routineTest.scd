//IF FAILING YOU MUST SET KT-USB FOR BOTH INPUT AND OUTPUT. ALSO, MATCH SAMPLE RATE.


//global var for # of speakers
//run code in one take
(
s.reboot;
s.options.sampleRate = 44100;

ServerOptions.devices;

s.waitForBoot {
    "Input Channels: ".post; s.options.numInputBusChannels.postln;
    "Output Channels: ".post; s.options.numOutputBusChannels.postln;
};

v = s.volume;
v.min;
v.max;
v.volume = -45;
v.setVolumeRange(-45, 10);
v.mute;
v.unmute;

v.gui;

s.meter;

)

~testRoutine = Routine(
	{ { SinOsc.ar(440) }.play; }
);

~testRoutine.next;
~testRoutine.stop;


(
var synth;
r = Routine {
	    //{ SinOsc.ar(200) }.play;
        //200.yield;
	    //{ SinOsc.ar(400) }.play;
        //400.yield;
		//{ SinOsc.ar(600) }.play;
        //200.idle(6);
	    //{ SinOsc.ar(600) }.play;
        //600.yield;
	    synth =  {SinOsc.ar(800) }.play;
	    1.wait;
	    synth.free;
	"".yieldAndReset;
        //800.yieldAndReset;

};



fork {
    loop {
        var freq = r.value;
		freq.postln;
		//{ SinOsc.ar(freq) }.play;
        3.wait;
    }
}
);

