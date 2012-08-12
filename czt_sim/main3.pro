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

FOR i=0,cloudnumb-1 DO BEGIN
   electron_motion,1.,pos[0,i],pos[2,i],efx,efz,a,b,c,tac,xac,zac,coarsegridpos=[1.025,4.5]
   size = n_elements(tac)-1
   fe[i] = size

   IF xac(size) gt 19.54 THEN lastpos = 19.54 ELSE BEGIN 
      IF xac(size) lt 0 THEN lastpos = 0 ELSE  lastpos = xac(size)
   ENDELSE

   FOR j=0,size DO BEGIN 
      IF xac[j] gt 19.54 THEN xac[j] = 3908 ELSE BEGIN 
         IF xac[j] lt 0 THEN xac[j] = 0 ELSE  xac[j]=floor(xac[j]/0.005)
      ENDELSE
   ENDFOR

   zac = floor(zac/0.005)
   FOR j=0,divcloud-1 DO BEGIN
      electron_motion,0.,lastpos+(j-(divcloud-1)/2)*0.005,1.075,efx,efz,a,b,c,dtac,dxac,dzac,coarsegridpos=[0.5,4.5]
      
      dzac = floor(dzac/0.005)
      dsize = n_elements(dtac)-1
      fd[divcloud*i+j] = dsize

      FOR k=0,dsize -1 DO BEGIN 
         IF dxac[k] gt 19.54 THEN dxac[k] = 3908 ELSE BEGIN 
            IF dxac[k] lt 0 THEN dxac[k] = 0 ELSE  dxac[k]=floor(dxac[k]/0.005)
         ENDELSE
      ENDFOR

      dvdcloud[divcloud*i+j].xac[0:size] = xac + j - (divcloud -1)/2
      index = where ( dvdcloud[divcloud*i+j].xac[0:size] gt 3908 )
      IF index NE -1 THEN dvdcloud[divcloud*i+j].xac[index] = 3908
      index = where ( dvdcloud[divcloud*i+j].xac[0:size] lt 0 )
      IF index NE -1 THEN dvdcloud[divcloud*i+j].xac[index] = 0

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
      IF xac[j] gt 19.54 THEN xac[j] = 3908 ELSE BEGIN 
         IF xac[j] lt 0 THEN xac[j] = 0 ELSE  xac[j]=floor(xac[j]/0.005)
      ENDELSE
   ENDFOR

   holes[i].xac[0:size] = xac
   holes[i].zac[0:size] = zac
   holes[i].tac[0:size] = tac

ENDFOR

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;i've get the positions and time

qad = dblarr(cloudnumb*divcloud,16,1000)
qcd = dblarr(cloudnumb*divcloud,16,1000)
qsd = dblarr(cloudnumb*divcloud,5,1000)
qah = dblarr(cloudnumb,16,1000)
qch = dblarr(cloudnumb,16,1000)
qsh = dblarr(cloudnumb,5,1000)
taue = 3e-6
tauh = 1e-6

FOR i=0,cloudnumb-1 DO BEGIN
   FOR j=0,divcloud-1 DO BEGIN
      FOR k=0,fe[i]+fd[divcloud*i+j] DO BEGIN
         xpos = dvdcloud[divcloud*i+j].xac[k]
         zpos = dvdcloud[divcloud*i+j].zac[k]
         t = dvdcloud[divcloud*i+j].tac[k]
         FOR m=0,15 DO BEGIN
            qad[divcloud*i+j,m,k] = wpa[m,xpos,zpos]*tcalc[j,floor(t*1e9)]*qe[i]*exp(-t/taue)
            qcd[divcloud*i+j,m,k] = wpc[m,xpos,zpos]*tcalc[j,floor(t*1e9)]*qe[i]*exp(-t/taue)
            IF m lt 5 THEN qsd[divcloud*i+j,m,k] = wpst[m,xpos,zpos]*tcalc[j,floor(t*1e9)]*exp(-t/taue)
         ENDFOR
      ENDFOR
  ENDFOR
ENDFOR


FOR i=0,cloudnumb-1 DO BEGIN
   FOR k=0,fh[i] DO BEGIN
      xpos = holes[i].xac[k]
      zpos = holes[i].zac[k]
      t = holes[i].tac[k]
      FOR m=0,15 DO BEGIN
         qah[i,m,k] = wpa[m,xpos,zpos]*qh[i]*exp(-t/tauh)
         qch[i,m,k] = wpc[m,xpos,zpos]*qh[i]*exp(-t/tauh)
         IF m lt 5 THEN qsh[i,m,k] = wpst[m,xpos,zpos]*qh[i]*exp(-t/tauh)
      ENDFOR
  ENDFOR
ENDFOR

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;indivudual charge is calculated
a=1001

time = findgen(a)*1e-9

qa = dblarr(16,a)
qc = dblarr(16,a)
qst = dblarr(5,a)

FOR m=0,15 DO BEGIN
   FOR i=0,cloudnumb-1 DO BEGIN
      qa[m,*] = qa[m,*] + interpol(reform(qah[i,m,0:fh[i]]),holes[i].tac[0:fh[i]],time)
      qc[m,*] = qc[m,*] + interpol(reform(qch[i,m,0:fh[i]]),holes[i].tac[0:fh[i]],time)
      IF m lt 5 THEN BEGIN
         qst[m,*] = qst[m,*] + interpol(reform(qsh[i,m,0:fh[i]]),holes[i].tac[0:fh[i]],time)
      ENDIF
      FOR j=0,divcloud-1 DO BEGIN 
         qa[m,*] = qa[m,*] + interpol(reform(qad[i,m,0:fe[i]+fd[i]]),dvdcloud[divcloud*i+j].tac[0:fe[i]+fd[i]],time)
         qc[m,*] = qc[m,*] + interpol(reform(qcd[i,m,0:fe[i]+fd[i]]),dvdcloud[divcloud*i+j].tac[0:fe[i]+fd[i]],time)         
         IF m lt 5 THEN qst[m,*] = qst[m,*] + interpol(reform(qsd[i,m,0:fe[i]+fd[i]]),dvdcloud[divcloud*i+j].tac[0:fe[i]+fd[i]],time)         
      ENDFOR
   ENDFOR
ENDFOR   

END
