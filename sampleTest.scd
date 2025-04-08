(
s.reboot;
s.options.numOutputBusChannels = 2;
s.options.sampleRate = 44100;


/*ServerOptions.devices;

s.waitForBoot {
    "Input Channels: ".post; s.options.numInputBusChannels.postln;
    "Output Channels: ".post; s.options.numOutputBusChannels.postln;
};*/

s.meter;
v = s.volume;
v.min;
v.max;
v.volume = 0;
v.setVolumeRange(-10, 10);
v.mute;
v.unmute;

v.gui;

)

(

~sampleLayerBuffer = Buffer.read(s, thisProcess.nowExecutingPath.dirname +/+ "stems/clocks.wav");


//{Out.ar(0, PlayBuf.ar(2, ~baseLayerBuffer, loop: 1));}.play;

)


(

SynthDef(\sampleLayer, {
	 | buf, out = 0, volume = 1, pitchRatio = 1, infVerb = 0|

    var sound, finalSound, reverb;

    // Play the buffer
    sound = PlayBuf.ar(2, buf, loop: 1);

	finalSound = PitchShift.ar(sound,0.2, pitchRatio, 0.0, 0.0, 1.0, 0.0);

	reverb = FreeVerb.ar(finalSound, infVerb, infVerb, 0.3);

    // Output to specified channel
    Out.ar(out, reverb * volume * 1.2); // Scale down the output level


}).add;

)

(
~sampleLayerSynths = [0, 2].collect { |i| Synth(\sampleLayer, [\buf, ~sampleLayerBuffer,\out, i,])};

)