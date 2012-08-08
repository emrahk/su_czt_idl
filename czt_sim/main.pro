PRO main,data,ndata,efx,efz,wpa,wpc,wpst,eventnumb,time,qc,qa,qst, $
         qainde,qaindh,qcinde,qcindh,qstinde,qstindh,clouddiv=divcloud,divide=divide,plot=plot

IF NOT keyword_set(divcloud) THEN divcloud = 1

geteventinfo,data,eventnumb,pos,ener
cloudnumb = n_elements(ener)
cloud = create_struct('xe_actual',dblarr(1000),'ze_actual',dblarr(1000),'te_actual',dblarr(1000))
holes = create_struct('xh_actual',dblarr(1000),'zh_actual',dblarr(1000),'th_actual',dblarr(1000))
cloud = replicate (cloud,cloudnumb)
holes = replicate (holes,cloudnumb)
taue = 3e-6 ;3e-6
tauh = 1e-6
Qr_e = ener   ;???????? 2 choosen as bandgap !!!multiply by e
QAinde = dblarr(16,1000)
QCinde = dblarr(16,1000)
QSTinde = dblarr(5,1000)
Qr_h = -ener   ;???????? 2 choosen as bandgap !!!multiply by e
QAindh = dblarr(16,1000)
QCindh = dblarr(16,1000)
QSTindh = dblarr(5,1000)
q = dblarr(cloudnumb)

cnte=0
cnth=0
timee = findgen(1000)*1e-9
timeh = findgen(1000)*10e-9

IF NOT keyword_set(divide) THEN BEGIN
   FOR i=0,cloudnumb-1 DO BEGIN
      electron_motion,0.,pos[0,i],pos[2,i],efx,efz,a,b,c,te_actual,xe_actual,ze_actual,coarsegridpos=[1.025,4.5]
      lene = floor(max(te_actual)*1e9)
      xe_actual=interpol(xe_actual,te_actual,timee[0:lene])
      ze_actual=interpol(ze_actual,te_actual,timee[0:lene])
      FOR j=0,lene DO BEGIN
         cloud[i].xe_actual[j]=xe_actual[j]
         IF cloud[i].xe_actual[j] gt 19.54 THEN cloud[i].xe_actual[j] = 19.54
         IF cloud[i].xe_actual[j] lt 0 THEN cloud[i].xe_actual[j] = 0
         cloud[i].ze_actual[j]=ze_actual[j]
      ENDFOR
      FOR j=lene+1,999 DO BEGIN
         cloud[i].xe_actual[j]=xe_actual[lene]
         cloud[i].ze_actual[j]=ze_actual[lene]
      ENDFOR
   ENDFOR
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
ENDIF ELSE BEGIN
   t = intarr(cloudnumb*divcloud)
   dvdcloud = create_struct('xe_actual',dblarr(1000),'ze_actual',dblarr(1000),'te_actual',dblarr(1000))
   dvdcloud = replicate(dvdcloud,cloudnumb*divcloud)
   index = where (pos[2,*] le 1.1,count)
   IF count eq 0 THEN BEGIN
      FOR i=0,cloudnumb-1 DO BEGIN
         electron_motion,1.,pos[0,i],pos[2,i],efx,efz,a,b,c,te_actual,xe_actual,ze_actual,coarsegridpos=[1.025,4.5]
         lene = floor(max(te_actual)*1e9)
         xe_actual=interpol(xe_actual,te_actual,timee[0:lene])
         ze_actual=interpol(ze_actual,te_actual,timee[0:lene])
         FOR k=0,divcloud-1  DO BEGIN 
            t[divcloud*i+k]=lene
            FOR j=0,lene DO BEGIN
               dvdcloud[divcloud*i+k].xe_actual[j]=xe_actual[j]+(k-(divcloud-1)/2)*0.005
               ;should be inside the detector
               IF dvdcloud[divcloud*i+k].xe_actual[j] gt 19.54 THEN dvdcloud[divcloud*i+k].xe_actual[j] = 19.54
               IF dvdcloud[divcloud*i+k].xe_actual[j] lt 0 THEN dvdcloud[divcloud*i+k].xe_actual[j] = 0
               dvdcloud[divcloud*i+k].ze_actual[j]=ze_actual[j]
            ENDFOR
         ENDFOR  
      ENDFOR
   
      FOR i=0,cloudnumb*divcloud-1 DO BEGIN
         electron_motion,0.,dvdcloud[i].xe_actual[t[i]],1.07,efx,efz,a,b,c,te_actual,xe_actual,ze_actual,coarsegridpos=[1.025,4.5]
         lene = floor(max(te_actual)*1e9)
         xe_actual=interpol(xe_actual,te_actual,timee[0:lene])
         ze_actual=interpol(ze_actual,te_actual,timee[0:lene])
         ind = where(dvdcloud[i].xe_actual ne 0.,count)
         FOR j=count+1,count+lene+1 DO BEGIN
            dvdcloud[i].xe_actual[j]=xe_actual[j-count-1]
            IF dvdcloud[i].xe_actual[j] gt 19.54 THEN dvdcloud[i].xe_actual[j] = 19.54
            IF dvdcloud[i].xe_actual[j] lt 0 THEN dvdcloud[i].xe_actual[j] = 0
            dvdcloud[i].ze_actual[j]=ze_actual[j-count-1]
         ENDFOR
         FOR j=count+lene+2,999 DO BEGIN
            dvdcloud[i].xe_actual[j]=xe_actual[lene]
            dvdcloud[i].ze_actual[j]=ze_actual[lene]
         ENDFOR
      ENDFOR
   ENDIF ELSE BEGIN
      FOR i=0,cloudnumb*divcloud-1 DO BEGIN
         cnumb = i MOD divcloud
         grid = i MOD cloudnumb
         electron_motion,0.,pos[0,cnumb],pos[2,cnumb]+(grid-2)*0.005,efx,efz,a,b,c,te_actual,xe_actual,ze_actual,coarsegridpos=[1.025,4.5]
         lene = floor(max(te_actual)*1e9)
         xe_actual=interpol(xe_actual,te_actual,timee[0:lene])
         ze_actual=interpol(ze_actual,te_actual,timee[0:lene])
         ind = where(dvdcloud[i].xe_actual ne 0.,count)
         FOR j=count,count+lene+1 DO BEGIN
            dvdcloud[i].xe_actual[j]=xe_actual[j-count-1]
            IF dvdcloud[i].xe_actual[j] gt 19.54 THEN dvdcloud[i].xe_actual[j] = 19.54
            IF dvdcloud[i].xe_actual[j] lt 0 THEN dvdcloud[i].xe_actual[j] = 0
            dvdcloud[i].ze_actual[j]=ze_actual[j-count-1]
         ENDFOR
         FOR j=count+lene+2,999 DO BEGIN
            dvdcloud[i].xe_actual[j]=xe_actual[lene]
            dvdcloud[i].ze_actual[j]=ze_actual[lene]
         ENDFOR
      ENDFOR
   
   ENDELSE
ENDELSE
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


FOR i=0,cloudnumb-1 DO BEGIN
   hole_motion,pos[0,i],pos[2,i],efx,efz,a,b,c,th_actual,xh_actual,zh_actual,coarsegridpos=[1.025,4.5]
   lenh = floor(max(th_actual)*1e8)
   IF lenh gt 999 THEN lenh = 999
   xh_actual=interpol(xh_actual,th_actual,timeh[0:lenh])
   zh_actual=interpol(zh_actual,th_actual,timeh[0:lenh])
   FOR j=0,lenh DO BEGIN
      holes[i].xh_actual[j]=xh_actual[j]
      IF holes[i].xh_actual[j] gt 19.54 THEN holes[i].xh_actual[j] = 19.54
      IF holes[i].xh_actual[j] lt 0 THEN holes[i].xh_actual[j] = 0
      holes[i].zh_actual[j]=zh_actual[j]
   ENDFOR
   FOR j=lenh,999 DO BEGIN
      holes[i].xh_actual[j]=xh_actual[lenh]
      holes[i].zh_actual[j]=zh_actual[lenh]
   ENDFOR
ENDFOR

;**********************************************************************************************

IF keyword_set(plot) THEN BEGIN
   IF NOT keyword_set(divide) THEN BEGIN
      FOR i=0,cloudnumb-1 DO BEGIN
         xe_actual = reform(cloud[i].xe_actual[where(cloud[i].xe_actual ne 0 )])
         ze_actual = reform(cloud[i].ze_actual[where(cloud[i].ze_actual ne 0 )])
         trajectory,xe_actual,ze_actual,i
      ENDFOR
   ENDIF ELSE BEGIN
      FOR i=0,cloudnumb*divcloud-1 DO BEGIN
         xe_actual = reform(dvdcloud[i].xe_actual[where(dvdcloud[i].xe_actual ne 0 )])
         ze_actual = reform(dvdcloud[i].ze_actual[where(dvdcloud[i].ze_actual ne 0 )])
         trajectory,xe_actual,ze_actual,i
      ENDFOR
   ENDELSE
   FOR i=0,cloudnumb-1 DO BEGIN
      xe_actual = reform(holes[i].xh_actual[where(holes[i].xh_actual ne 0 )])
      ze_actual = reform(holes[i].zh_actual[where(holes[i].zh_actual ne 0 )])
      trajectory,xe_actual,ze_actual,1,/hole
   ENDFOR
ENDIF

;**********************************************************************************************

IF NOT keyword_set(divide) THEN BEGIN
   FOR m=0,999 DO BEGIN
      cloudsize,result,timearr,ftime=timee[m]
      sigma = result(n_elements(result)-1)
      grid_dist,sigma,divcloud,calc
      FOR i=0,cloudnumb-1 DO BEGIN
         x=floor(cloud[i].xe_actual[m]/0.005)
         z=floor(cloud[i].ze_actual[m]/0.005)
         IF z gt 5 THEN q[i] = Qr_e[i]*exp(-timee[m]/taue)
         FOR k=0,divcloud-1 DO BEGIN
            place = x+k-(divcloud-1)
            IF place gt 3908 THEN place = 3908
            IF place lt 0 THEN place = 0
            FOR j=0,15 DO BEGIN
               ;QAinde[j,m] = QAinde[j,m] + wpa[j,x+k-(divcloud-1),z]*calc[k]*q[i]
               QAinde[j,m] = QAinde[j,m] + wpa[j,place,z]*calc[k]*q[i]
               QCinde[j,m] = QCinde[j,m] + wpc[j,place,z]*calc[k]*q[i]
               IF (j lt 5) THEN QSTinde[j,m] = QSTinde[j,m] + wpst[j,place,z]*calc[k]*q[i]
            ENDFOR
         ENDFOR
      ENDFOR
   ENDFOR
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
ENDIF ELSE BEGIN
   FOR m=0,999 DO BEGIN
      ;cloudsize,result,timearr,ftime=timee[m]
      IF t[i]*1e-9 le timee[m] THEN cloudsize,result,timearr,ftime=timee[m] ELSE cloudsize,result,timearr,ftime=(t[i]*1e-9)
      sigma = result(n_elements(result)-1)
      grid_dist,sigma,divcloud,calc
      FOR i=0,cloudnumb-1 DO BEGIN
         FOR k=0,divcloud-1 DO BEGIN
            x=floor(dvdcloud[divcloud*i+k].xe_actual[m]/0.005)
            z=floor(dvdcloud[divcloud*i+k].ze_actual[m]/0.005)
            IF z gt 5 THEN q[i] = Qr_e[i]*exp(-timee[m]/taue)
            FOR j=0,15 DO BEGIN
               QAinde[j,m] = QAinde[j,m] + wpa[j,x,z]*calc[k]*q[i]
               QCinde[j,m] = QCinde[j,m] + wpc[j,x,z]*calc[k]*q[i]
               IF (j lt 5) THEN QSTinde[j,m] = QSTinde[j,m] + wpst[j,x,z]*calc[k]*q[i]
            ENDFOR
         ENDFOR
      ENDFOR
   ENDFOR
ENDELSE

FOR m=0,999 DO BEGIN
   FOR i=0,cloudnumb-1 DO BEGIN
      x=floor(holes[i].xh_actual[m]/0.005)
      z=floor(holes[i].zh_actual[m]/0.005)
      IF holes[i].zh_actual[m] lt 4.98 THEN q[i] = Qr_h[i]*exp(-timeh[m]/tauh)
      FOR j=0,15 DO BEGIN
         QAindh[j,m] = QAindh[j,m] + wpa[j,x,z]*q[i]
         QCindh[j,m] = QCindh[j,m] + wpc[j,x,z]*q[i]
         IF (j lt 5) THEN QSTindh[j,m] = QSTindh[j,m] + wpst[j,x,z]*q[i]
      ENDFOR
   ENDFOR
ENDFOR

qa=dblarr(16,1000)
qc=dblarr(16,1000)
qst=dblarr(5,1000)

FOR i=0,15 DO BEGIN
   qainde[i,*] = interpol(qainde[i,*],timee,timeh)
   qcinde[i,*] = interpol(qcinde[i,*],timee,timeh)
   qa[i,*] = qainde[i,*] + qaindh[i,*]
   qc[i,*] = qainde[i,*] + qcindh[i,*]
   IF i lt 5 THEN BEGIN
      qstinde[i,*] = interpol(qstinde[i,*],timee,timeh)
      qst[i,*] = qstinde[i,*] + qstindh[i,*]
   ENDIF
ENDFOR

time=timeh

END
