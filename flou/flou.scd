(
SynthDef(\synthy, {
	arg freq=220, lfoRng=0.6, out=0, amp=0.1, width=0.5, gate=1.0, atk=0.01, rel=1.0, curve= -8, pos=0.0;
	var sig, env, lfo, lfo2;
	env = EnvGen.kr(
		Env.perc(atk, rel, 1.0, curve),
		gate,
		doneAction:2);
	lfo = LFNoise2.kr([3,4]).range(freq * lfoRng.midiratio.reciprocal, freq * lfoRng.midiratio);
	lfo2 = Line.kr(0.7, 0.9, rel*0.3);
	sig = VarSaw.ar(lfo,0, lfo2, env);
	sig = Balance2.ar(sig[0], sig[1], pos, amp);
	Out.ar(out, sig);
}).add;

SynthDef(\shooting, {
	arg freq=220, lfoRng=0.5, out=0, amp=0.1, width=0.5, gate=1.0, atk=0.03, rel=1.0, curve= -8, pos=0.0;
	var sig, env, lfo, lfo2, pulse, pitchEnv;
	env = EnvGen.kr(
		Env.perc(atk, rel, 1.0, curve),
		gate,
		doneAction:2);
	pitchEnv = EnvGen.kr(
		Env([0.9, 1.0, 0.8], [atk*50, rel],-4),
		gate
	);
	lfo = LFNoise2.kr([3,4]).range(freq * lfoRng.midiratio.reciprocal, freq * lfoRng.midiratio);
	lfo2 = Line.kr(0.5, 0.7, rel*0.4);
	sig = VarSaw.ar(lfo*pitchEnv,0, lfo2, env);
	sig = Balance2.ar(sig[0], sig[1], pos, amp);
	Out.ar(out, sig);
}).add;


~numFreqs = 20;
SynthDef(\grinder, {
	arg out=0, amp=0.1, dens=4, gate=1.0, atk=0.1, lfoRng=0.5, pos=0.0, decay=0.2, freq=60, formant=89;
	var sig, env, lfo;

	env = EnvGen.kr(
		Env([0.0, 1.0, 0.0], [atk, decay],-4, 1),
		gate,
		doneAction: 2
	);
	lfo = LFNoise2.kr(
		Array.series(~numFreqs, 3.0, 1.0).scramble ).range( dens * lfoRng.midiratio.reciprocal, dens * lfoRng.midiratio);
	amp = Decay.ar(Dust.ar(lfo,env), decay, mul: amp);
	formant =  Array.geom(~numFreqs, formant, 4.midiratio).scramble * (amp + 5);
	sig = SyncSaw.ar(
		Array.geom(~numFreqs, freq, 1.midiratio).scramble,
		formant,
		mul:amp
	);
	sig = Splay.ar(sig, level:amp);
	Out.ar(out, sig);
}).add;
)

(
Pbindef(
	\grinder,
	\amp, 0.5,
	\decay, 0.02,
	\dens, Pseg([600,1],[8], \lin, inf),
	\freq, 80,
	\formant, 83,
	\instrument, \grinder,
	\dur, 8,
);
)
Pdef(\grinder).play;

Pdef(\grinder).stop;


(
~dur = 8;
~chords = [[0,2,4,6],[1,2,3,5],[0,4,5,6],[1,3,5,6]];

Pbindef(
	\metro,
	\instrument, \synthy,
	\dur, 1,
	\rel, 0.2,
	\octave,7,
	\degree, Pseq([4,0,0,0],inf)
);


Pdef(\basic,
	Pfindur( ~dur,
		Pbind(
			\instrument, \synthy,
			\dur, Pwhite(Pseg([0.001,0.1],[~dur], -4), Pseg([0.04,0.5],[~dur],-4)),
			\curve, -8.0,
			\rel, Pexprand(
				Pseg([2.0, 8.0],[~dur],-4.0),
				Pseg([0.1, 1.0], [~dur], -4.0)
			),
			\root, -5,
			\octave, Prand([6,7], inf),
			\db, Pseg([-25, -30], [~dur]),
			\pos, Pwhite(-0.5, 0.5)
		)
	)
);

Pdef(
	\chordSeq,
	Pseq(
		~chords.collect({
			arg i;
			Pbindf(
				Pdef(\basic),
				\degree, Prand(i,inf)
			)
		}),
		inf
	);
);

Pdef(\melody,
	Pbind(
		\instrument, \shooting,
		\degree, Pseq([-3,2,3,2,1,0],inf),
		\root, -5,
		\dur, Pseq([0.5, 7.5], inf),
		\lag, Pwhite(0.1,0.2),
		\curve, -8.0,
		\rel, ~dur,
		\octave, 7,
		\db, -10,
		\pos, 0
	)
);

Pdef(\third,
	Pbindf(
		Pdef(\melody),
		\degree, Pseq([0,4,5,4,3,2], inf),
		\lag, Pwhite(0.02,0.1)
	)
);

Pdef(\melody).play(quant:Quant(8,-0.5));
Pdef(\third).play(quant:Quant(8,-0.5));

Pdef(\chordSeq).play(quant:Quant(8));
// Pdef(\metro).play(quant:Quant(8));
)

Pdef(\chordSeq).stop;
Pdef(\third).stop;
Pdef(\melody).stop;



