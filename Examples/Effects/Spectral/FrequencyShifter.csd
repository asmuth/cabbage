; FrequencyShifter.csd
; Iain McCurdy, 2013.
; 
; Frequency shifting using the hilbert filter
; 
; CONTROLS
; --------
; Input			--	Choose audio input: Live, sine tone or pink noise
; Polarity		--	3 options: 'Positive' = multiply 'Freq.' by 1, 'Negative' = multiply 'Freq.' by -1, 'Dual' = sum of 'Positive' and 'Negative' outputs
; Mix			--	Dry/Wet mix control
; Freq.			--	Principle frequency of the shifting frequency (before modulation by other controls)
; Mult.			--	multipler of shifting frequency. Can be useful for finer control of shifting frequency around zero.
; Feedback		--	Amount of frequency shifter that is fed back into its input
; Level			--	Output level
; Dual Mono / Stereo	--	'Dual Mono' = both channels treated in the same way. 'Stereo' = right channel 180 degrees out of phase with respect to the left
;				 Stereo mode most apparent if shifting frequency is close to zero
; zero freq		--	set 'Freq.' to zero
;  [LFO~]
; Modulate Frequency	--	Switch to activate LFO modulation  of shifting frequency
; Shape			--	Shape of the LFO: sine / triangle / square / random sample and hold / random splines
; Rate			--	Rate of LFO (in hertz)
; Min			--	Minimum frequency of the LFO modulation
; Max			--	Maximum frequency of the LFO modulation
; Pan Mod			--	Amount of panning modulation (strictly speaking, stereo balance modulation). Rate of modulation governed also by 'Rate'
; Sync LFO		--	Restart LFO. Can be useful if 'random spline' modulation becomes 'stuck' at a low frequency

<Cabbage>
form caption("Frequency Shifter") size(560,180), pluginid("fshi") style("legacy")
image                   bounds( 0,  0, 560,180), colour("darkslategrey"), outlinecolour("silver"), outlinethickness(6), shape("rounded")
label    bounds(15,  7, 70, 11), text("INPUT"), fontcolour("white")
combobox bounds(15, 18, 70, 20), channel("input"), value(1), text("Live","Tone","Noise")
label    bounds(15, 42, 70, 11), text("POLARITY"), fontcolour("white")
combobox bounds(15, 53, 70, 20), channel("polarity"), value(1), text("Positive","Negative","Dual")
rslider bounds( 80, 10, 70, 70), text("Mix"),      channel("mix"),    range(0, 1.00, 0.5),     colour(27,59,59), textcolour("white"), trackercolour(255,255,100)
rslider bounds(150, 10, 70, 70), text("Freq."),    channel("freq"),   range(-4000, 4000, -50), colour(27,59,59), textcolour("white"), trackercolour(255,255,100)
rslider bounds(220, 10, 70, 70), text("Mult."),    channel("mult"),   range(-1, 1.00, 0.1),    colour(27,59,59), textcolour("white"), trackercolour(255,255,100)
rslider bounds(285, 15, 60, 60), text("Port."),    channel("port"),   range(0, 30.00, 0.1),    colour(27,59,59), textcolour("white"), trackercolour(255,255,100)

rslider bounds(340, 10, 70, 70), text("Feedback"), channel("fback"),  range(0, 0.75, 0.6),     colour(27,59,59), textcolour("white"), trackercolour(255,255,100)
rslider bounds(410, 10, 70, 70), text("Level"),    channel("level"),  range(0, 1.00, 1),       colour(27,59,59), textcolour("white"), trackercolour(255,255,100)

checkbox bounds(480, 20, 12, 12), channel("r1") fontcolour("white") colour(yellow) value(1)
checkbox bounds(480, 32, 12, 12), channel("r2") fontcolour("white") colour(yellow) 
label    bounds(493, 21, 55,  9), text("DUAL MONO"), fontcolour("white")
label    bounds(492, 33, 40,  9), text("STEREO"), fontcolour("white")

button   bounds(480, 50, 65, 20), colour("Green"), text("Zero Freq", "Zero Freq"), channel("Zerofreq"), value(0), latched(0)

;----

line     bounds( 10, 90, 540, 2), colour("Grey")

;----

checkbox bounds( 40,100,150, 20), channel("ModOnOff") text("LFO Modulate Freq."), fontcolour("white") colour(lime) value(0)
label    bounds( 53,127, 45, 11), text("SHAPE"), fontcolour("white")
combobox bounds( 40,138, 85, 20), channel("LFOShape"), value(7), text("Sine","Triangle","Square","Saw Up","Saw Down","Rand.S&H","Rand.Spline")
rslider bounds( 175,100, 70, 70), text("Rate"),     channel("LFORate"),  range(0, 30,  1.5, 0.5, 0.001), colour("lightslategrey"), textcolour("white"), trackercolour(255,255,100)
rslider bounds( 245,100, 70, 70), text("Min"),      channel("LFOMin"),   range(-2000, 2000, -600),       colour("lightslategrey"), textcolour("white"), trackercolour(255,255,100)
rslider bounds( 315,100, 70, 70), text("Max"),      channel("LFOMax"),   range(-2000, 2000,  600),       colour("lightslategrey"), textcolour("white"), trackercolour(255,255,100)
rslider bounds( 385,100, 70, 70), text("Pan Mod."), channel("PanSpread"),range(0, 1.00, 1),              colour("lightslategrey"), textcolour("white"), trackercolour(255,255,100)
button   bounds(455,100, 65, 20), colour("Green"), text("Sync LFO", "Sync LFO"), channel("SyncLFO"), value(0), latched(0)

</Cabbage>
<CsoundSynthesizer>

<CsOptions>
-d -n -+rtmidi=null -M0
</CsOptions>

<CsInstruments>
;sr is set by the host
ksmps 	= 	32
nchnls 	= 	2
0dbfs 	= 	1

;Iain McCurdy, 2012
;http://iainmccurdy.org/csound.html
;Frequency shifter effect based around the hilbert filter.

gisine		ftgen	0,0,4096,10,1			;A SINE WAVE SHAPE
gicos		ftgen	0,0,4096,11,1			;A COSINE WAVE SHAPE
gishapes	ftgen	0,0,8,-2,0,1,2,4,5

opcode	FreqShifter,a,akkki
	adry,kmix,kfshift,kfback,ifn	xin			;READ IN INPUT ARGUMENTS
	kWet	limit	kmix*2,0,1
	kDry	limit	(1-kmix)*2,0,1
	aFS	init	0					;INITILISE FEEDBACK SIGNAL (FOR FIRST K-PASS)
	ain	=	adry + (aFS * kfback)			;ADD FEEDBACK SIGNAL TO INPUT (AMOUNT OF FEEDBACK CONTROLLED BY 'Feedback Gain' SLIDER)
	areal, aimag hilbert ain				;HILBERT OPCODE OUTPUTS TWO PHASE SHIFTED SIGNALS, EACH 90 OUT OF PHASE WITH EACH OTHER
	;QUADRATURE OSCILLATORS. I.E. 90 OUT OF PHASE WITH RESPECT TO EACH OTHER
	;OUTUTS	OPCODE	AMPLITUDE | FREQ. | FUNCTION_TABLE | INITIAL_PHASE (OPTIONAL;DEFAULTS TO ZERO)
	asin 	oscili       1,    kfshift,     ifn,           0
	acos 	oscili       1,    kfshift,     ifn,           0.25	
	;RING MODULATE EACH SIGNAL USING THE QUADRATURE OSCILLATORS AS MODULATORS
	amod1	=		areal * acos
	amod2	=		aimag * asin	
	;UPSHIFTING OUTPUT
	aFS	= (amod1 - amod2)
	aout	sum	aFS*kWet, adry*kDry		;CREATE WET/DRY MIX
		xout	aout				;SEND AUDIO BACK TO CALLER INSTRUMENT
endop


opcode	CabbageRadio2,k,SS			; change opcode name and number is string variable inputs
S1,S2	xin					; add string inputs for the required number of inputs 
kon		=	0
koff		=	0
ksum		=	0
ktrigsum	=	0
#define READ_CHANGES(NAME)	#
k$NAME	chnget	$NAME
ksum	=	ksum + k$NAME
kon$NAME	trigger	k$NAME,0.5,0
ktrigsum	=	ktrigsum + kon$NAME#

#define WRITE_CHANGES(NAME'COUNT)	#
if kon$NAME!=1 then
 chnset	koff,$NAME
else
 kval	=	$COUNT
endif#

 $READ_CHANGES(S1) 
 $READ_CHANGES(S2)				; add macro expansions for the required number of radio buttons

if ktrigsum>0 then

 $WRITE_CHANGES(S1'1)
 $WRITE_CHANGES(S2'2)				; add macro expansions for the required number of radio buttons

endif

kval	=	(ksum=0?0:kval)
	xout	kval
endop


instr	1
kporttime	linseg	0,0.001,1
koff	=	0
kmix		chnget	"mix"			; read input widgets
kfreq		chnget	"freq"
kmult		chnget	"mult"
kport		chnget	"port"
kfshift		portk	kfreq*kmult,kporttime*kport
kfback		chnget	"fback"
klevel		chnget	"level"
kpolarity	chnget	"polarity"
kStereoMode	CabbageRadio2	"r1","r2"	; call UDO
kZeroFreq	chnget	"Zerofreq"
ktrig changed	kZeroFreq
if ktrig=1 then
 chnset	koff,"freq"
endif
kModOnOff	chnget	"ModOnOff"	
kLFOShape        chnget	"LFOShape"        	
kLFORate         chnget	"LFORate"         	
kLFOMin          chnget	"LFOMin"          	
kLFOMax          chnget	"LFOMax"          	
kPanSpread	chnget	"PanSpread"		
kSyncLFO	chnget	"SyncLFO"


/* INPUT */
kinput		chnget	"input"
if kinput=1 then
 a1,a2	ins
elseif kinput=2 then
 a1	oscils	0.2, 300, 0
 a2	=	a1
else
 a1	pinkish	0.2
 a2	pinkish	0.2
endif



/* LFO */
if kModOnOff=1 then
 ktrig	changed	kLFOShape,kSyncLFO
 if ktrig==1 then
  reinit RESTART_LFO
 endif
 RESTART_LFO:
 if i(kLFOShape)=6 then
  kLFOFreq	randomh	kLFOMin,kLFOMax,kLFORate
 elseif i(kLFOShape)=7 then				; random spline
  ;kLFOFreq	randomi	kLFOMin,kLFOMax,kLFORate,1
  ;kLFOFreq	portk	kLFOFreq,1/kLFORate
  kLFOFreq	rspline	kLFOMin,kLFOMax,kLFORate,kLFORate*2
 else
  ishape	table	i(kLFOShape)-1,gishapes
  kLFOFreq	lfo	1,kLFORate,ishape
  kLFOFreq	scale	(kLFOFreq*0.5)+0.5,kLFOMin,kLFOMax
 endif
 rireturn
endif

 
 
kfshift	=	kfshift+kLFOFreq

/* FREQUENCY SHIFTERS */
ktrig	changed	kStereoMode
if ktrig=1 then
 reinit RESTART_FREQUENCY_SHIFTERS
endif
RESTART_FREQUENCY_SHIFTERS:
if kpolarity=1 then						; polarity is positive...
 a1	FreqShifter	a1,kmix,kfshift,kfback,gisine	
 if i(kStereoMode)=2 then
  a2	FreqShifter	a2,kmix,kfshift,kfback,gicos	; cosine version
 else
  a2	FreqShifter	a2,kmix,kfshift,kfback,gisine	
 endif 
elseif kpolarity=2 then						; polarity is negative...
 a1	FreqShifter	a1,kmix,-kfshift,kfback,gisine	
 if i(kStereoMode)=2 then
  a2	FreqShifter	a2,kmix,-kfshift,kfback,gicos	; cosine version
 else
  a2	FreqShifter	a2,kmix,-kfshift,kfback,gisine	
 endif
else								; polarity is dual...
 aa	FreqShifter	a1,kmix,kfshift,kfback,gisine	; positive
 if i(kStereoMode)=2 then
  ab	FreqShifter	a2,kmix,kfshift,kfback,gicos	; cosine version
 else
  ab	FreqShifter	a2,kmix,kfshift,kfback,gisine	
 endif 
 ac	FreqShifter	a1,kmix,-kfshift,kfback,gisine	; negative
 if i(kStereoMode)=2 then
  ad	FreqShifter	a2,kmix,-kfshift,kfback,gicos	; cosine version
 else
  ad	FreqShifter	a2,kmix,-kfshift,kfback,gisine	
 endif
rireturn

 a1	=		(aa+ac)*0.5				; sum positive and negative and attenuate
 a2	=		(ab+ad)*0.5
endif


/* PANNING */
if kModOnOff=1 then
 kpan	randomi	0.5-(kPanSpread*0.5),0.5+(kPanSpread*0.5),kLFORate,1
 kpan	portk	kpan,1/kLFORate
 a1  =     a1 * sin(kpan*$M_PI_2)
 a2  =     a2 * cos(kpan*$M_PI_2)
 ;a1	=	a1*kpan
 ;a2	=	a2*(1-kpan)
endif



a1	=	a1 * klevel					; scale using level control
a2	=	a2 * klevel
	outs	a1,a2
endin

</CsInstruments>
<CsScore>
i 1 0 [60*60*24*7]
</CsScore>
</CsoundSynthesizer>