<Cabbage>
form caption("XY-Pad Example") size(400, 300), colour(220, 220, 220), pluginID("def1")
xypad bounds(10, 10, 380, 280), channel("xChannel", "yChannel"), rangex(0, 1000, 100), rangey(0, 1000, 100), textcolour("yellow"), text("XY-PAD")
</Cabbage>
<CsoundSynthesizer>
<CsOptions>
-n -d -+rtmidi=NULL -M0 -m0d 
</CsOptions>
<CsInstruments>
; Initialize the global variables. 
sr = 44100
ksmps = 32
nchnls = 2
0dbfs = 1

seed 0 
;basic usage
instr 1
kXVal chnget "xChannel"
kYVal chnget "yChannel"
a1 oscili 1, kXVal
a2 oscili a1, kYVal
outs a2, a2
endin

</CsInstruments>
<CsScore>
;causes Csound to run for about 7000 years...
f0 z
;starts instrument 1 and runs it for a week
i1 0 z
</CsScore>
</CsoundSynthesizer> 
