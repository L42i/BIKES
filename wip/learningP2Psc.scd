//RUN LOCAL AUDIO SERVER
(
s.boot;
s.meter;
)


//STEP 2: RECEIVER
(
fork {
	p = P2PSC();
	p.sync;
	p.setName("Orlando"); // set your name accordingly
	p.sync;
	p.addPath({ |msg|
		var sleeptime = 1;
		var freq = 200;

		msg.postln; //print message for debugging

		fork {

			0.25.wait;

		{SinOsc.ar(freq:freq)*0.5*EnvGen.kr(Env.perc(releaseTime:sleeptime-0.01), doneAction:2)}.play;
			p.sendMsg("/"++"Jayson"++"/ping" , p.name);


		}

		/*fork {
			var nextpeer;
			var source_peer = msg[1].asString;
			var peers = p.getPeers();

			sleeptime.wait; // wait for one second

			// send to the next peer in our list
			nextpeer = peers.wrapAt(1+peers.indexOfEqual(source_peer));

			p.sendMsg("/"++nextpeer++"/ping", "testing message from orlando", p.name)
		};*/
	},"/ping");
}
)


// STEP 3: SENDER
(
fork {
    var peer, peers;
    peers = p.getPeers();
    if (peers.size > 0,
        {
			peer = "Jayson";
				("Sending initial ping to:"+peer).postln;
				("/"++peer++"/ping").postln;
			{SinOsc.ar(freq:1000)*0.5*EnvGen.kr(Env.perc(releaseTime:1-0.01), doneAction:2)}.play;

				p.sendMsg("/"++peer++"/ping" , p.name);


        },
        {"Error: No other peers in the network"}
    )
}
)