(

SynthDef(\kk, { |out=0, amp=0.5, pan, distort=0.3, n|
	var env = EnvGen.kr(Env.perc(0.0001, 0.09, amp, 8));
	var source = SinOsc.ar(EnvGen.kr(Env.perc(0.0001, 1.5, n+1, -200), 1, 1000, 45, doneAction:2), 1, 1);
	var noise = BPF.ar(GrayNoise.ar(6)!2,
			EnvGen.kr(Env.perc(0.001, 0.3, 1, -200), 1, 6000, 70),
			1.5)
	  .distort * Line.kr(distort,0.0,0.1);

	OffsetOut.ar(
		out,
		DirtPan.ar(
			source + noise,
			~dirt.numChannels,
			pan,
			env
		)
	)
}).add;

)