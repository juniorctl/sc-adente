(
// Ndef(\flanger).fadeTime = 20

Ndef(\flanger, {
	var sigPluck, local, delay, cutoff, bassTrig, pulse, dist;

	var sig = Ndef(\in).ar(2)[0];
	var f0 = Select.kr(LFTri.kr(1/64).range(0, 3), [44, 43, 41]).lag(12);
	var famp = 1;
	var rate = 4;
	var pluckOffset = 5;
	var pluckCoef = 0.9;
	var width = SinOsc.kr(1/34).range(0.1, 0.9);

	var f = [
		43,
		// f0,
		43.05,
		50
	];

	f = ([
		f[0], f[0] + 0.1, f[1], f[2], f[0] + 12, f[1] + 12,
	]).postln;

	f = f.midicps;
	f = f.scramble;

	pulse = Impulse.ar(rate / 2) + Impulse.ar(rate / 2, 1/2.2);
	pulse = pulse * LFNoise2.ar(20).range(-20, 0).dbamp;
	pulse = Decay.ar(pulse, LFNoise2.ar(1).exprange(0.03, 0.8));

	delay = f / 2;

	cutoff = SinOsc.kr(1/60, rrand(0, 2.0)).lincurve(-1, 1, 100, 3400, 3);

	sig = BLowPass4.ar(VarSaw.ar(f, 0, 0, famp).sum, cutoff, 0.8);
	sig = LeakDC.ar(sig);
	bassTrig = Impulse.ar(1/20);

	local = LocalIn.ar(2);
	local = Rotate2.ar(local[0], local[1], SinOsc.kr(1/16).range(-1, 1));
	local = SoftClipAmp8.ar(local, 0.4);
	local = BLowPass.ar(local, cutoff);
	local = PitchShift.ar(local, 4 / f, [0.5, 4], 0.01).sum;
	local = Decimator.ar(local, f * 8, 16).sum;
	local = -20.dbamp * local;
	local = local + Splay.ar(DelayC.ar(local, 4, { rrand(0.0, 4.0) } ! 6, 0.5));

	sigPluck = delay.collect({ |delay, i|
		delay = [
			LFCub.ar(1 / rrand(30, 36), 2.0.rand).range(delay - pluckOffset, delay + pluckOffset)
			+ SinOsc.ar(1/2).range(-0.2, 0.2),
			delay * 4.05
		];
		PeakFollower.kr(sig, 0.9) * Pluck.ar(
			sig + local, sig,
			4,
			delay.reciprocal,
			9,
			[pluckCoef, 0.1],
			[1, -16.dbamp]
		).sum;
	});

	sig = SoftClipAmp8.ar(sig + sigPluck, -30.dbamp, 1);
	sig = Splay.ar(sig);
	sig = sig + PitchShift.ar(sig, 2, 0.25);

	sig = LeakDC.ar(sig);
	LocalOut.ar(sig);

	sig = sig + (-20.dbamp * AdCVerb.ar(HPF.ar(sig, 900), 9));

	sig = -6.dbamp * sig;

}).play;
)



/////// REFACTORED:
/////////////////////////////////////////
// create proxy space
~p = ~p ? ProxySpace.new(s, \p);
~p.fadeTime = 20;

/////////////////////////////////////////
// freq lfo
(~p[\freq][0] = {

	var f1 = \f1.kr(43);
	var f2 = \f2.kr(43.05);
	var f3 = \f3.kr(50);
	var f = [f1, f2, f3];
	f = ([
		f[0], f[0] + 0.1, f[1], f[2], f[0] + 12, f[1] + 12,
	]);

	f = f.midicps;
	f.scramble;
};
~p[\freq][2] = \set -> Pbind(
	\f1, Pseq([33, 43], inf),
	\delta, 16
);
);

/////////////////////////////////////////
// cutoff lfo
(~p[\cutoff][0] = {
	SinOsc.kr(1/60, rrand(0, 2.0)).lincurve(-1, 1, 100, 3400, 3);
});

/////////////////////////////////////////
// synths
(
~p[\s0][0] = {
	var freq = ~p[\freq].kr()[0];
	var amp = \amp.kr(1);
	var cutoff = ~p[\cutoff].kr;
	var sig = VarSaw.ar(freq, 0, 0, amp);
	sig = BLowPass4.ar(sig, cutoff, 0.8);
	LeakDC.ar(sig);
};
~p[\s1][0] = {
	var freq = ~p[\freq].kr()[1];
	var amp = \amp.kr(1);
	var cutoff = ~p[\cutoff].kr;
	var sig = LFTri.ar(freq, 0, amp);
	sig = DFM1.ar(sig, cutoff, 0.2);
	LeakDC.ar(sig);
};
~p[\s2][0] = {
	var freq = ~p[\freq].kr()[2];
	var amp = \amp.kr(1);
	var sig = PMOsc.ar(freq, freq * 2.1, SinOsc.kr(LFNoise2.kr(0.1).range(1,5)).range(1,6));
	LeakDC.ar(sig);
};
~p[\s3][0] = {
	var freq = ~p[\freq].kr()[3];
	var amp = \amp.kr(1);
	var cutoff = ~p[\cutoff].kr;
	var sig = SinOscFB.ar(freq, SinOsc.kr(0.1).range(0.1, 0.7), amp);
	sig = RLPF.ar(sig, cutoff, 0.2);
	LeakDC.ar(sig);
};
~p[\s4][0] = {
	var freq = ~p[\freq].kr()[4];
	var amp = \amp.kr(1);
	var cutoff = ~p[\cutoff].kr;
	var sig = Pulse.ar(freq, 0.5, amp);
	sig = BLowPass4.ar(sig, cutoff, 0.8);
	LeakDC.ar(sig);
};
~p[\s5][0] = {
	var freq = ~p[\freq].kr()[5];
	var amp = \amp.kr(1);
	var sig = SinOsc.ar(freq, 0, amp);
	sig
};
);

~p[\mix][0] = \mix -> {~p[\s0]};
~p[\mix][1] = \mix -> {~p[\s1]};
~p[\mix][2] = \mix -> {~p[\s2]};
~p[\mix][3] = \mix -> {~p[\s3]};
~p[\mix][4] = \mix -> {~p[\s4]};
~p[\mix][5] = \mix -> {~p[\s5]};
~p[\mix].set(\mix0, 1, \mix1, 0.5, \mix2, 0.2, \mix3, 0.5, \mix4, 0.5, \mix5, 1);

/////////////////////////////////////////
// main fx
(~p[\flanger2][0] = {

	var f = \freq.kr([1,1,1,1,1,1]);

	var cutoff = \cutoff.kr(100);

	var sig = \sig.ar([0]);

	var delay = f / 2;

	var osc2 = {arg delay, sig, local;

		var pluckOffset = 5;
		var pluckCoef = 0.9;

		var sigPluck = delay.collect({|delay, i|
			delay = [
				LFCub.ar(1 / rrand(30, 36), 2.0.rand).range(delay - pluckOffset, delay + pluckOffset)
				+ SinOsc.ar(1/2).range(-0.2, 0.2),
				delay * 4.05
			];
			PeakFollower.kr(sig, 0.9) * Pluck.ar(
				sig + local, sig,
				4,
				delay.reciprocal,
				9,
				[pluckCoef, 0.1],
				[1, -16.dbamp]
			).sum;
		});
		sigPluck;
	};

	var fb = {arg f = 1, cutoff = 1;
		var local = LocalIn.ar(2);
		local = Rotate2.ar(local[0], local[1], SinOsc.kr(1/16).range(-1, 1));
		local = SoftClipAmp8.ar(local, 0.4);
		local = BLowPass.ar(local, cutoff);
		local = PitchShift.ar(local, 4 / f, [0.5, 4], 0.01).sum;
		local = Decimator.ar(local, f * 8, 16).sum;
		local = -20.dbamp * local;
		local = local + Splay.ar(DelayC.ar(local, 4, { rrand(0.0, 4.0) } ! 6, 0.5));
		local;
	};

	var clip = {arg in, sigPluck;
		var sig = SoftClipAmp8.ar(in + sigPluck, -30.dbamp, 1);
		sig = Splay.ar(sig);
		sig = sig + PitchShift.ar(sig, 2, 0.25);
		LeakDC.ar(sig);
	};

	var local = fb.(f, cutoff);
	var pluck = osc2.(delay, sig, local);
	sig = clip.(sig, pluck);
	LocalOut.ar(sig);
	sig;
});

/////////////////////////////////////////
// reverb
(~p[\flanger2].filter(4, {arg in;
	AdCVerb.ar(HPF.ar(in, \hpf.kr(900)), 9);
}).set(\wet4, 0.3)
);

/////////////////////////////////////////
// route
~p[\flanger2] <<>.freq ~p[\freq];
~p[\flanger2] <<>.cutoff ~p[\cutoff];
~p[\flanger2] <<>.sig ~p[\mix];

/////////////////////////////////////////
// play
~p[\flanger2].play;
~p[\flanger2].stop;