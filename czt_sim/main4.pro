PRO main4,data,ndata,efx,efz,wpa,wpc,wpst,eventnumb,time,qc,qa,qst, $
          qainde,qaindh,qcinde,qcindh,qstinde,qstindh,clouddiv=divcloud, $
          calct=tcalc,divide=divide,plot=plot

IF NOT keyword_set(divcloud) THEN divcloud = 1

geteventinfo,data,eventnumb,pos,ener
cloudnumb = n_elements(ener)

qad = dblarr(cloudnumb*divcloud,16,1000)
qcd = dblarr(cloudnumb*divcloud,16,1000)
qsd = dblarr(cloudnumb*divcloud,5,1000)
qah = dblarr(cloudnumb,16,1000)
qch = dblarr(cloudnumb,16,1000)
qsh = dblarr(cloudnumb,5,1000)
taue = 3e-6
tauh = 1e-6
a=1001
time = findgen(a)*1e-9
qa = dblarr(16,a)
qc = dblarr(16,a)
qst = dblarr(5,a)

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
fe = dblarr(cloudnumb)
fh = dblarr(cloudnumb)
fd = dblarr(divcloud*cloudnumb)

FOR i=0,cloudnumb-1 DO BEGIN
   electron_motion,1.,pos[0,i],pos[2,i],efx,efz,a,b,c,tac,xac,zac,coarsegridpos=[1.025,4.5]
   size = n_elements(tac)-1
   fe[i] = size

   IF xac(size) gt 19.54 THEN lastpos = 19.54 ELSE BEGIN 
      IF xac(size) lt 0 THEN lastpos = 0 ELSE  lastpos = xac(size)
   ENDELSE

   FOR j=0,size DO BEGIN 
      xac[j]=floor(xac[j]/0.005)
      IF xac[j] gt 19.54 THEN xac[j] = 3908  
      IF xac[j] lt 0 THEN xac[j] = 0
   ENDFOR
   zac = floor(zac/0.005)
   
   FOR j=0,divcloud-1 DO BEGIN
      place = lastpos+(j-(divcloud-1)/2)*0.005
      IF place gt 19.54 THEN place = 19.54
      IF place lt 0 THEN place = 0
      electron_motion,0.,place,1.075,efx,efz,a,b,c,dtac,dxac,dzac,coarsegridpos=[0.5,4.5]
      
      dzac = floor(dzac/0.005)
      dsize = n_elements(dtac)-1
      fd[i] = dsize
      
      FOR k=0,dsize -1 DO BEGIN 
         IF dxac[k] gt 19.54 THEN dxac[k] = 3908 ELSE BEGIN 
            IF dxac[k] lt 0 THEN dxac[k] = 0 ELSE  dxac[k]=floor(dxac[k]/0.005)
         ENDELSE
      ENDFOR
      
      xac[0:size] = xac + j - (divcloud -1)/2
      index = where ( xac[0:size] gt 3908 )
      IF index NE -1 THEN xac[index] = 3908
      index = where ( xac[0:size] lt 0 )
      IF index NE -1 THEN xac[index] = 0
      dxac=[xac,dxac[1:dsize]]
      dzac=[zac,dzac[1:dsize]]
      dtac=[tac,dtac[1:dsize]+tac[size]]
      
      FOR m=0,15 DO BEGIN
         qad[i,m,0:size+dsize] = wpa[m,dxac,dzac]*qe[i]*exp(-dtac/taue)*tcalc[j,floor(dtac*1e9)] 
         qcd[i,m,0:size+dsize] = wpa[m,dxac,dzac]*qe[i]*exp(-dtac/taue)*tcalc[j,floor(dtac*1e9)] 
         IF m lt 5 THEN qad[i,m,0:size+dsize] = wpa[m,dxac,dzac]*qe[i]*exp(-dtac/taue)*tcalc[j,floor(dtac*1e9)] 
         qa[m,*] = qa[m,*] + interpol(reform(qad[i,m,0:size+dsize]),dtac,time)
         qc[m,*] = qc[m,*] + interpol(reform(qcd[i,m,0:size+dsize]),dtac,time)         
         IF m lt 5 THEN qst[m,*] = qst[m,*] + interpol(reform(qsd[i,m,0:size+dsize]),dtac,time)      
      ENDFOR      
   ENDFOR
ENDFOR

stop

FOR i=0,cloudnumb-1 DO BEGIN
   hole_motion,pos[0,i],pos[2,i],efx,efz,a,b,c,tac,xac,zac,coarsegridpos=[1.025,4.5]
   zac = floor(zac/0.005)
   size = n_elements(tac)-1

   FOR j=0,size -1 DO BEGIN 
      IF xac[j] gt 19.54 THEN xac[j] = 3908 ELSE BEGIN 
         IF xac[j] lt 0 THEN xac[j] = 0 ELSE  xac[j]=floor(xac[j]/0.005)
      ENDELSE
   ENDFOR
   
    FOR m=0,15 DO BEGIN
       qch[i,m,0:size] = wpc[m,xac,zac]*qh[i]*exp(-tac/tauh)
       qch[i,m,0:size] = wpc[m,xac,zac]*qh[i]*exp(-tac/tauh)
       IF m lt 5 THEN qch[i,m,0:size] = wpc[m,xac,zac]*qh[i]*exp(-tac/tauh)
       qa[m,*] = qa[m,*] + interpol(reform(qah[i,m,0:size]),tac[0:size],time)
       qc[m,*] = qc[m,*] + interpol(reform(qch[i,m,0:size]),tac[0:size],time)
       IF m lt 5 THEN qst[m,*] = qst[m,*] + interpol(reform(qsh[i,m,0:size]),tac[0:size],time)
    ENDFOR
 ENDFOR

END
