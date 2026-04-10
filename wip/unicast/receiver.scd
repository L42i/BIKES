(



s.boot;
SynthDef(\freqChange, {
        arg freq = 440;
        Out.ar(0, SinOsc.ar(freq));
}).add;

x = Synth(\freqChange, [\freq, 440]);

r = Server.remote("bikes1", NetAddr.new("10.10.10.110", 9996));
r.options.bindAddress = "0.0.0.0";
r.boot;

~oscHandler = OSCFunc({|msg|

        var newFreq = (msg[1]).asInteger;
        newFreq.postln;
        x.set(\freq, newFreq);

}, '/setFreq', nil, 9997);





)


(
~oscHandler.free;
)

