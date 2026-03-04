(
s.meter();
s.options.sampleRate = 44100;
s.boot();
)

(
// We use a gated envelope so the sound can sustain indefinitely
// until we explicitly tell it to stop.
SynthDef(\carrierTone, {
    |freq = 440, amp = 0.2, gate = 1|
    var sig, env;

    // Env.asr holds the sound at the sustain level as long as gate > 0.
    // doneAction: 2 removes the synth when the release finishes.
    env = EnvGen.kr(Env.asr(attackTime: 0.1, sustainLevel: 1.0, releaseTime: 0.5), gate, doneAction: 2);

    sig = SinOsc.ar(freq, 0, amp) * env;

    Out.ar(0, Pan2.ar(sig, 0)); // Center pan
}).add;
)

(
~isCarrier = false;      // Track if this specific node has the sound
~carrierSynth = nil;     // This will hold our active Synth object
~nodeName = "Jacob"; // Adjust to pi name

fork {
    p = P2PSC();
    p.sync;
	p.setName(~nodeName);
    p.sync;
    ("Joined network as: " ++ p.name).postln;
};
)

p.name.postln;

(
fork {
    p.addPath({ |msg|
        var senderName = msg[1];

        ("Received claim from: " ++ senderName).postln;

        // If we are currently the carrier, we need to stop!
        if(~isCarrier, {
            "I am no longer the carrier. Fading out...".postln;
            ~isCarrier = false;

            // Set the gate to 0 to trigger the release portion of the envelope
            if(~carrierSynth.notNil, {
                ~carrierSynth.set(\gate, 0);
            });
        });

    }, "/claimCarrier"); // This is the custom OSC path we will use
};
)

(
r = Task({
    var dist;
    var waitTime = 1.0; // Simulate distance every n seconds

    loop {
        dist = rrand(0, 20);
        ("Rolled: " ++ dist).postln;

        // If the number is 0 or 1...
        if(dist < 2) {

            // ...and we aren't ALREADY the carrier...
            if(~isCarrier.not) {

                "\n>>> Carrier switching! <<<".postln;
                ~isCarrier = true;

                // 1. Start our sound
                ~carrierSynth = Synth(\carrierTone, [\freq, rrand(300, 600)]);

                // 2. Tell everyone else in the network to stop
                p.getPeers().do({ |peerName|
                    // Send message to each peer's /claimCarrier path
                    p.sendMsg("/" ++ peerName ++ "/claimCarrier", p.name);
                });
            };
        };

        waitTime.yield;
    }
});
)

// Start the game!
r.play;

// Stop the game
r.stop;