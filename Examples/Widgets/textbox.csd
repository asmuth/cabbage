<Cabbage>
form caption("Textbox Example") size(400, 300), colour(220, 220, 220), pluginid("TxB1")
label bounds(8, 6, 368, 20), text("Basic Usage"), fontcolour("black")
textbox bounds(10, 30, 380, 267) identchannel("widgetIdent"), file("Textbox.csd")
</Cabbage>
<CsoundSynthesizer>
<CsOptions>
-n -d -+rtmidi=NULL -M0 -m0d 
</CsOptions>
<CsInstruments>
; Initialize the global variables. 
;sr is set by the host
ksmps = 32
nchnls = 2
0dbfs = 1

;basic usage
instr 1
 
endin

</CsInstruments>
<CsScore>
;causes Csound to run for about 7000 years...
f0 z
;starts instrument 1 and runs it for a week
i1 0 z
i2 0 z
</CsScore>
</CsoundSynthesizer>
