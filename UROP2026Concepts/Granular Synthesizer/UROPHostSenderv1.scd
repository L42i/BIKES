s.options.numInputBusChannels = 0;

s.waitForBoot({

    // 1. Data Lookups
    ~noteMap = ( 'C': 0, 'C#': 1, 'D': 2, 'D#': 3, 'E': 4, 'F': 5, 'F#': 6, 'G': 7, 'G#': 8, 'A': 9, 'A#': 10, 'B': 11 );
    ~scales  = (
        'Major':      [0, 2, 4, 5, 7, 9, 11],
        'Minor':      [0, 2, 3, 5, 7, 8, 10],
        'Dorian':     [0, 2, 3, 5, 7, 9, 10],
        'Mixolydian': [0, 2, 4, 5, 7, 9, 10]
    );

    ~activeSynth = nil;

    // 2. Logic to actually play the sound (Shared by Network and Local)
    ~playNote = { |rootName, scaleName, degree|
        var rootMidi, noteMidi;

        rootMidi = 60 + ~noteMap[rootName.asSymbol];
        noteMidi = rootMidi + ~scales[scaleName.asSymbol][degree.asInteger - 1];

        if (~activeSynth.notNil && { ~activeSynth.isPlaying }) {
            ~activeSynth.set(\freq, noteMidi.midicps);
        } {
            ~activeSynth = Synth(\default, [
                \freq, noteMidi.midicps,
                \amp, 0.2,
                \sustain, 1
            ]).register;
        };
    };

    // 3. Dynamic Host Identification
    ~hostname = "hostname".unixCmdGetStdOut.replace("\n", "");

    if(~hostname.isEmpty) {
        ~host = "Peer_" ++ 1000.rand;
    } {
        ~host = ~hostname;
    };

    // 4. P2PSC Setup & Diagnostic
    fork {
        // We only call this ONCE!
        p = P2PSC();
        p.sync;
        p.setName(~host);
        p.sync;

        0.2.wait;

        // Add the path
        p.addPath({ |msg|
            { ~playNote.value(msg[1], msg[2], msg[3]) }.defer;
        }, "/remoteChord");

        p.sync;

        // Built-in Diagnostic Check
        "-----------------------------".postln;
        "🔍 FINAL P2PSC CHECK 🔍".postln;
        "Peers Visible: %".format(p.getPeers).postln;
        "Server sees paths: %".format(p.getPaths).postln;
        "SC local paths:    %".format(p.paths.keys.asList).postln;
        "-----------------------------".postln;

        "✅ P2PSC Ready! My dynamic name is: %".format(~host).postln;
    };

    // 5. Pygame Relay
    OSCdef(\pygameRelay, { |msg|
        var root    = msg[1];
        var scale   = msg[2];
        var degree  = msg[3];

        // A. Play locally immediately
        { ~playNote.value(root, scale, degree) }.defer;

        // B. Send via Hybrid Direct Routing
        if(p.notNil) {
            fork {
                p.getPeers.do { |peerName|
                    if(peerName != ~host) {
                        // Use P2PSC's discovered name to send a direct ping!
                        NetAddr(peerName.asString, 57121).sendMsg("/remoteChord", root, scale, degree);
						NetAddr(peerName.asString, 57120).sendMsg("/remoteChord", root, scale, degree);
                    };
                };
            };
        };

    }, "/chord");

}
);
