HOW TO RUN the 2D Creative electron detector simulation to create a spectrum and relevant data

inside CZTMODEL directory
restore,'CR_EL_DATA/IDLDATA/comsoldata.sav'
restore,'CR_EL_DATA/IDLDATA/geantoutput.sav'

say you want to run event number 200001 - 250000, then
count9=indgen(25000,/long)+200001L 
p_spectrum, data, efx, efz, wpa, wpc, wpst, spe9, anarr9, caarr9, starr9, evlist9, vcount=count9, /verbose, /timetrap, noiselev=3. 

start with smaller number of events.
check inside p_spectrum and main4_ek for input and output parameters.

============
Some information regarding fixes to Yigit's programs and ongoing problems to be fixed
=============
There are 4 main programs,
main.pro, main2.pro main3.pro and main4.pro

assuming for now that main4 is the newest program. But main3.pro has more info in header.

Creating header for main4 and check differences. main4 works for a single event!

PRO spectrum,data,event,efx,efz,wpa,wpc,wpst,spe,anarr,caarr,starr,evlist,clouddiv=divcloud, vcount=count,verbose=verbose,timetrap=timetrap,noiselev=levnoise

runs main4 for as many photons we like.

WARNING 1. No FANO factor, work with energies, not charges, Qr_e=ener!

time - up to 1ms a resolutition of 1ns, and then 10ns. Hole time scale goes as 10ns, but electron goes as 1ns.

tcalc and calc? check cloudsize.pro.

WARNING: ftime=1e-6, so only electron cloud calculated?
I do not understand. need to work out examples!

Then it runs elec_motion and hol_motion with coarsegridpos[0.75, 4.7]?

WARNING:
 t=floor(max(th_actual-1e-6)*1e8)+ 1000
 if t gt 1800 then t=1800

what is this???

WARNING:
event in main4 is useless? Keeping to make other programs work.

DATA:
restore,'../data/geantoutput.sav'


WARNING
electron motion has WPcath, 2555 not the actual x value. likely to be abug!!!
It still uses mid cathode results so all cathode results could be wrong?

WARNING: no trapping for the last 15 steps. not sure why the last 15 steps are not included in the main program

Anodes seem ok, but there is a problem with cathodes, kinks.
need to concentrate on that

Current values in the run:
tauh=1e-6 muh=5e3
taue=3e-5 mob=3e-5


INVESTIGATE EVENT 6???

CLOUDSIZE and GRID DIST DOES NOT WORK!!!!!!!!!!
just make sure the initial version works first

FUCK FUCK FUCK

The other parts work ok. Just go on to create spectrum....
charge expulsion and charge division later?
