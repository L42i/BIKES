(
OSCdef(\gridListener, { |msg|
    var x = msg[1];
    var y = msg[2];
    ("Grid clicked: " ++ x ++ ", " ++ y).postln;

    // You could map this to trigger sounds, e.g.:
    Synth(\default, [\freq, (x+1) * 100 + (y*50)]);
}, "/grid");
)
