(

(
SynthDef(\entropy, { |out, sustain=1, pan, decay=0, width=0.3, attack, release|
	var env = EnvGen.kr(Env.new([0,1,1,0],[attack, sustain, release], -8),doneAction: 2);
	var caboos = LFNoise0.kr(15);
	var sig = SinOscFB.ar(
		Pulse.kr(
			LFPulse.kr(SinOsc.kr(0.3).range(1, caboos.fold(1, 4)), Crackle.kr.range(0, 2pi)),
			LFNoise1.kr(7).range(0.1, caboos.slew(0.3, 0.9))
		).exprange(LFNoise2.kr(3).range(Line.kr(300, 800, 17), caboos.range(800, 1400)))
	)!2;

	sig = sig + Impulse.ar(caboos.slew(0.1, 0.9).range(300, 800));

	sig = sig / 2;

	sig = FreeVerb.ar(sig,
		SinOsc.kr(1/3).range(0.3, 0.9),
		LFSaw.kr(1/5).range(0.3, 0.9),
		SinOsc.kr(1/7).range(0.3, 0.9)
	);
	sig = [sig, sig + Delay1.ar(sig)];
	sig = sig.tanh;

	OffsetOut.ar(out, DirtPan.ar(sig, ~dirt.numChannels, pan, env));
}).add;
);

SynthDef(\blow, { |out, decay=0, sustain=0.03, freq, pan, accelerate, voice = 0.5, semitone=12, resonance=0.3, lfo=1, pitch1=1, width = 0.3|
	var imp = LFNoise1.kr(80);
	var basefreq = freq * Line.kr(1, 1+accelerate, sustain);
	var lfof1 = min(basefreq*10*pitch1, 22000);
	var lfof2 = min(lfof1 * (lfo + 1), 22000);
	var sig = LPF.ar(
		SinOsc.ar(
			LFNoise1.kr(3).range(2,4) * basefreq / 2.sqrt
		),
		LFNoise2.kr(40).range(lfof1, lfof2), resonance
	);
	var env = LFGauss.ar(sustain, width, loop: 0).range(0, 1);
	OffsetOut.ar(out, DirtPan.ar(sig, ~dirt.numChannels, pan, env))
}).add;

SynthDef(\gfreeze, {
	| out = 0, amp = 1, freq = 440.0, gain,
	trigRate = 60, grainDur = 0.35, pos = 0.3, rate = 1,
	attack = 0.1, sustain = 1, release = 2, gate = 1,
	lowPassCutoff = 4000, highPassCutoff = 100, pan = 0
	|

	var input = LFSaw.ar(freq).distort * gain;
	var localBuf = LocalBuf.new(SampleRate.ir * 1, 1).clear;
	var record = RecordBuf.ar(input, localBuf, loop: 0);

	var grainTrig = Dust.ar(trigRate);
	var granulation = GrainBuf.ar(1, grainTrig, grainDur, localBuf, rate, pos);

	var lpf = LPF.ar(granulation, lowPassCutoff);
	var signal = HPF.ar(lpf.distort, highPassCutoff);

	var env = EnvGen.kr(Env.asr(attack, sustain, release), gate, amp, doneAction: 2);

	OffsetOut.ar(out, DirtPan.ar(signal / 10, ~dirt.numChannels, pan, env));
}).add;

SynthDef(\uou, { |freq=440,amp=1,attack=0.01,decay=0.3,sustain=0.5,release=0.4,out=0,pan=0,accelerate=0,hold=0.5|
	var env = EnvGen.kr(Env.adsr(attack, decay, sustain, release), doneAction:2);
	var modmod = LFNoise0.kr(2).range(2,20);
	var mod = LFNoise1.kr(modmod).range(0.5,1.2).distort;
	var sig = VarSaw.ar(freq*mod, accelerate, hold) * amp;

	OffsetOut.ar(out, DirtPan.ar(sig, ~dirt.numChannels, pan, env));
}).add;

SynthDef(\zonta, { |out = 0, speed = 1, freq = 440, pan=0, detune=0, amp = 0.5, attack=0.0001, release 0.5, sustain=1|
	var env = EnvGen.ar(Env.perc(attack, release, 8), doneAction: 2);
	var width = LFNoise0.kr(20).range(0.2,0.8);
	var sig = (
		Pulse.ar(freq + (detune * 3), width) +
		LFSaw.ar(freq/2 + (detune * 3), width.sin) +
		SinOsc.ar(freq/2 + (detune * 3), pi/2) +
		Phaser.ar(freq*2 + (detune * 3), width.cos)
	)/4;

	sig = MoogLadder.ar(sig, freq*8, width);

	OffsetOut.ar(out, DirtPan.ar(sig * amp, ~dirt.numChannels, pan, env));
}).add;

SynthDef(\pingz, { |out,pan,freq=440,attack=0.00001,release=0.2|
	var env = EnvGen.ar(Env.perc(attack, release), doneAction:2);
	var signal = Resonz.ar(env, freq, 0.99);

	OffsetOut.ar(out, DirtPan.ar(signal * 2 , ~dirt.numChannels, pan));
}).add;

SynthDef(\pingm, { |out,pan,freq=440,attack=0.00001,release=0.2|
	var env = EnvGen.ar(Env.perc(attack, release), doneAction:2);
	var signal = MoogLadder.ar(env, freq, 0.99);

	OffsetOut.ar(out, DirtPan.ar(signal*2, ~dirt.numChannels, pan));
}).add;

SynthDef(\pingr, { |out,pan,freq=440,attack=0.00001,release=0.2|
	var env = EnvGen.ar(Env.perc(attack, release), doneAction:2);
	var signal = RLPFD.ar(env, freq, 0.99, 0.4);

	OffsetOut.ar(out, DirtPan.ar(signal*2, ~dirt.numChannels, pan));
}).add;

SynthDef(\pings, { |out,pan,freq=440,attack=0.00001,release=0.2|
	var env = EnvGen.ar(Env.perc(attack, release), doneAction:2);
	var signal = Streson.ar(env, 1/freq, 0.99, 0.4);

	OffsetOut.ar(out, DirtPan.ar(signal/5, ~dirt.numChannels, pan));
}).add;

SynthDef(\pulsa, { |out=0, freq=220, attack=0.1, release=1, pan=0|
	var env = EnvGen.kr(Env.perc(attack, release), doneAction: 2);
	var signal = Pulse.ar(freq, SinOsc.kr(3000/freq));
	signal = (LocalIn.ar(1).distort) + (Delay1.ar(signal));
	signal = MoogLadder.ar(signal, freq*2.7, 0);

	LocalOut.ar(signal);

	Out.ar(out, Pan2.ar(signal, pan) * env);
}).add;

SynthDef(\addi, { |out=0, pan=0, freq=440, attack=0.01, release=0.4, sustain=1|
	var env = EnvGen.kr(Env.asr(attack, sustain, release), doneAction: 2);
	var comp = 35; // numero dei componenti
	var res = 0.1; // risoluzione in semitoni
	var signal = Mix.new(Array.fill(comp, { |i|
		SinOsc.ar(freq: ((freq/7.333)+(i*res)).midicps, phase: i/2pi, mul: 4.0/comp )}
	));

	OffsetOut.ar(out, DirtPan.ar(signal, ~dirt.numChannels, pan, env));
}).add;

SynthDef(\sbaum, { |out=0,freq=440,pan=0|
	var sig = Impulse.ar(freq, SinOsc.kr(freq/4), 0.5) + Saw.ar(freq/2, 0.5);
	sig = LPF18.ar(sig, 2400, 0.7);
	OffsetOut.ar(out, DirtPan.ar(sig, ~dirt.numChannels, pan));
}).add;

SynthDef(\dk, { |out=0, freq=440, pan=0, attack=0.01, release=0.5|
	var sub = Pulse.ar(freq/2);
	var noise = PinkNoise.ar(1);

	//var ani = Fold.ar(LFTri.ar(freq, 0), 0.2, 1);
	var ani = Pulse.ar(freq, SinOsc.kr(0.8).range(0.2,0.8));
	var sig = (sub * 0.45) + (noise * 0.05) + (ani * 0.5);

	var env = EnvGen.ar(Env.perc(attack, release));

	var cutoff = 2500.0;
	sig = LPF.ar(sig, cutoff + ((cutoff/10) * LFNoise0.kr(5).range(-2,2)));

	OffsetOut.ar(out, DirtPan.ar(sig, ~dirt.numChannels, pan, env));
}).add;

// metallic bouncing marbles: from Bana on Patch and Tweak book
SynthDef(\mbm, { |out=0, freq=440, pan=0, attack=0.01, release=0.4|
	var env = EnvGen.ar(Env.perc(attack, release * LFTri.kr(2).range(0.5, 1.5)));
	var carrier = SinOsc.ar(freq*16);
	var signal = SinOsc.ar(freq);
	var sig = signal * carrier;

	OffsetOut.ar(out, DirtPan.ar(sig, ~dirt.numChannels, pan, env));
}).add;

SynthDef(\cuerda, { |out=0, freq=440, pan=0, attack=0.01, release=0.4|
	var env = EnvGen.ar(Env.asr, doneAction: 2);

	var sig = ((Pulse.ar(freq, LFSaw.kr(200/freq).range(0.2, 0.8)) * SinOsc.ar(freq*8)) * 0.5)
	  + ((Saw.ar(freq)) * 0.47)
	  + WhiteNoise.ar(0.03);

	OffsetOut.ar(out, DirtPan.ar(sig, ~dirt.numChannels, pan, env));
}).add;

)
