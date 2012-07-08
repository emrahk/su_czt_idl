.compile datawork
.compile field

evindex=1

pos = eventgetinfo(evindex,/pos)
ener = eventgetinfo(evindex,/ener)
numb = eventgetinfo(evindex,/numb)
index = geteventindex()
cloudnumb = (index(evindex)-index(evindex-1))
onindex=dblarr(cloudnumb)
onindex = onindex + 1
onindex(1286)=0
onindex = WHERE ( onindex EQ 1)

cfield = coulombfield(pos,ener,onindex,cloudnumb)
