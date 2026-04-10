(

//s = Server.remote("bikes0", NetAddr("10.10.10.109", 57110));
s.boot;

SynthDef(\freqChange, {
        arg freq = 440;

        Out.ar(0, SinOsc.ar(freq));
}).add;

x = Synth(\freqChange, [\freq, 440]);

~receiverIp = NetAddr.new("10.10.10.110", 9997);


a = EZSlider(nil, 300@42, "freq change", ControlSpec.new(200, 1500, step: 100));
a.action_({ |ez|
        x.set(\freq, ez.value);

        ~receiverIp.sendMsg("/setFreq", ez.value);

        "sent".postln;

});

)
