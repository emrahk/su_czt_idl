PRO gettrajectory,efx,efz,event

event=create_struct('xac',dblarr(500),'zac',dblarr(500),'tac',dblarr(500),'size',0)
event=replicate(event,3909)

FOR i=0,3908 DO BEGIN
  electron_motion,0.,i*0.005,1.07,efx,efz,a,b,c,t,x,z,d,e,f,coarsegridpos=[1.1,4]
  asize = n_elements(t)-1
  event[i].xac[0:asize] = x
  event[i].zac[0:asize] = z
  event[i].tac[0:asize] = t
  event[i].size = asize
ENDFOR

END
