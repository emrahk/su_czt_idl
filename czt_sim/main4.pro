PRO main3,data,ndata,efx,efz,wpa,wpc,wpst,eventnumb,time,qc,qa,qst, $
          qainde,qaindh,qcinde,qcindh,qstinde,qstindh,clouddiv=divcloud, $
          calct=tcalc,divide=divide,plot=plot

IF NOT keyword_set(divcloud) THEN divcloud = 1

geteventinfo,data,eventnumb,pos,ener
cloudnumb = n_elements(ener)

IF NOT keyword_set(tcalc) THEN BEGIN
   tcalc = dblarr(divcloud,1000)
   cloudsize,sigma,timearr,ftime=1e-6
   FOR i=0,999 DO BEGIN 
      grid_dist,sigma[i],divcloud,calc
      tcalc[0:divcloud-1,i] = calc
   ENDFOR
ENDIF

QE = ener
QH = -ener
holes=create_struct('xac',dblarr(1000),'zac',dblarr(1000),'tac',dblarr(1000))
holes=replicate(holes,cloudnumb)
dvdcloud=create_struct('xac',dblarr(1000),'zac',dblarr(1000),'tac',dblarr(1000))
dvdcloud=replicate(dvdcloud,divcloud*cloudnumb)
fe = dblarr(cloudnumb)
fh = dblarr(cloudnumb)
fd = dblarr(cloudnumb*divcloud)
temax=1001
thmax=201
timee=findgen(temax)*1e-9
timeh=findgen(thmax)*1e-8


FOR i=0,cloudnumb-1 DO BEGIN
   electron_motion,1.,pos[0,i],pos[2,i],efx,efz,a,b,c,tac,xac,zac,coarsegridpos=[1.025,4.5]
   size = n_elements(tac)-1
   fe[i] = size

   lastpos = xac(size)
   IF xac(size) gt 19.54 THEN lastpos = 19.54 
   IF xac(size) lt 0 THEN lastpos = 0 

   FOR j=0,size DO BEGIN 
      xac[j]=floor(xac[j]/0.005)
      IF xac[j] gt 3908 THEN xac[j] = 3908 
      IF xac[j] lt 0 THEN xac[j] = 0  
   ENDFOR

   zac = floor(zac/0.005)
   FOR j=0,divcloud-1 DO BEGIN
      electron_motion,0.,lastpos+(j-(divcloud-1)/2)*0.005,1.075,efx,efz,a,b,c,dtac,dxac,dzac,coarsegridpos=[0.5,4.5]
      
      dzac = floor(dzac/0.005)
      dsize = n_elements(dtac)-1
      fd[divcloud*i+j] = dsize

      FOR k=0,dsize -1 DO BEGIN 
         dxac[k]=floor(dxac[k]/0.005)
         IF dxac[k] gt 3908 THEN dxac[k] = 3908 
         IF dxac[k] lt 0 THEN dxac[k] = 0  
      ENDFOR

      dvdcloud[divcloud*i+j].xac[0:size] = xac + j - (divcloud -1)/2
      index = where ( dvdcloud[divcloud*i+j].xac[0:size] gt 3908 )
      IF index[0] NE -1 THEN dvdcloud[divcloud*i+j].xac[index] = 3908
      index = where ( dvdcloud[divcloud*i+j].xac[0:size] lt 0 )
      IF index[0] NE -1 THEN dvdcloud[divcloud*i+j].xac[index] = 0

      dvdcloud[divcloud*i+j].zac[0:size] = zac
      dvdcloud[divcloud*i+j].tac[0:size] = tac
      dvdcloud[divcloud*i+j].xac[size+1:size+dsize] = dxac[1:dsize]
      dvdcloud[divcloud*i+j].zac[size+1:size+dsize] = dzac[1:dsize]
      dvdcloud[divcloud*i+j].tac[size+1:size+dsize] = dtac[1:dsize] + tac[size]
   ENDFOR
ENDFOR

FOR i=0,cloudnumb-1 DO BEGIN

   hole_motion,pos[0,i],pos[2,i],efx,efz,a,b,c,tac,xac,zac,coarsegridpos=[1.025,4.5]
   zac = floor(zac/0.005)
   size = n_elements(tac)-1
   fh[i] = size

   FOR j=0,size -1 DO BEGIN 
      xac[j]=floor(xac[j]/0.005)
      IF xac[j] gt 3908 THEN xac[j] = 3908  
      IF xac[j] lt 0 THEN xac[j] = 0 
   ENDFOR

   holes[i].xac[0:size] = xac
   holes[i].zac[0:size] = zac
   holes[i].tac[0:size] = tac

ENDFOR



END
