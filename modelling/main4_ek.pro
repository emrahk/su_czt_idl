;*************************************************************************************
;turns given geant output to an event and returns induced charge for
;all electrodes. New version
;-------------------------------------------------------------------------------------

PRO main4_ek,data,efx,efz,wpa,wpc,wpst,eventnumb,time,qc,qa,qst, $
          noqc,noqa,noqst,clouddiv=divcloud,timetrap=timetrap, $
          calct=tcalc,divide=divide,noiselev=levnoise,plot=plot

;INPUTS
;data        : output from geant which can be read with geteventinfo
;efx,efz     : electric field input
;wp(a,c,st)  : weighting potential input
;eventnumb   : index of the event in current data.
;
;OUTPUTS
;time        : time scale specified in the program
;q(c,a,st)   : induced charged on electrodes with respect to time
;noq(c,s,st) : induced signals with noise
;OPTIONAL INPUTS
;clouddiv    :divide clouds, currently not functional
;timetrap    : use time for trapping instead of distance
;calct       : ?  
;plot        : plots trajectory of the all clouds
;-------------------------------------------------------------------------------------
  
IF NOT keyword_set(divcloud) THEN divcloud = 1
IF NOT keyword_set(levnoise) THEN levnoise=3.

;gets event info for all clouds in the (eventnumb)th event.
geteventinfo,data,eventnumb,pos,ener
cloudnumb = n_elements(ener)
cloud = create_struct('xe_actual',dblarr(1000),'ze_actual',dblarr(1000),'te_actual',dblarr(1000))
holes = create_struct('xh_actual',dblarr(1000),'zh_actual',dblarr(1000),'th_actual',dblarr(1000))
cloud = replicate (cloud,cloudnumb)
holes = replicate (holes,cloudnumb)
Qr_e = ener                     ;???????? 2 choosen as bandgap !!!multiply by e
Qr_h = ener                    ;???????? 2 choosen as bandgap !!!multiply by e
;because induced charges are negative

;timee = findgen(1001)*1e-9
;timeh = findgen(1001)*1e-8

;time=[timee,timeh[where(timeh gt max(timee))]]

time=findgen(10001L)*1e-9

QA = dblarr(16,n_elements(time))
QC = dblarr(16,n_elements(time))
QST = dblarr(5,n_elements(time))

;elctrode signals with noise
noqa = dblarr(16,n_elements(time))
noqc = dblarr(16,n_elements(time))
noqst = dblarr(5,n_elements(time))


IF NOT keyword_set(tcalc) THEN BEGIN
   tcalc = dblarr(divcloud,1000)
   cloudsize,sigma,timearr,ftime=1e-6
   FOR i=0,999 DO BEGIN 
      grid_dist,sigma[i],divcloud,calc
      tcalc[0:divcloud-1,i] = calc
   ENDFOR
ENDIF

;stop

FOR i=0,cloudnumb-1 DO BEGIN
   ; timetrap option activated for electrons
   if not keyword_set (timetrap) then begin
      elec_motion,0., cnt, pos[0,i], pos[2,i], efx, efz, wpa, wpc, wpst,$
                  te_actual, xe_actual, ze_actual, QAinde, QCinde, QSTinde,$
                  coarsegridpos=[0.75,4.7], ypos=pos[1,i]
   endif else begin
      elec_motion,0., cnt, pos[0,i], pos[2,i], efx, efz, wpa, wpc, wpst,$
                  te_actual, xe_actual, ze_actual, QAinde, QCinde, QSTinde,$
                  coarsegridpos=[0.75,4.7],/timetrap, ypos=pos[1,i]
   endelse

   te_actual = te_actual[1:cnt]
   t=floor(max(te_actual)*1e9)
   QAinde = Qainde*Qr_e[i]
   QCinde = QCinde*Qr_e[i]
   QSTinde = QSTinde*Qr_e[i] 
   FOR j=0,15 DO BEGIN
      QA[j,0:t] = QA[j,0:t] + interpol(QAinde[j,1:cnt],te_actual,time[0:t])
      QC[j,0:t] = QC[j,0:t] + interpol(QCinde[j,1:cnt],te_actual,time[0:t])
      IF j lt 5 THEN QST[j,0:t] = QST[j,0:t] + interpol(QSTinde[j,1:cnt],te_actual,time[0:t])
      FOR k =t+1,n_elements(time)-1 DO BEGIN
         QA[j,k] = QA[j,k] + QAinde[j,cnt]
         QC[j,k] = QC[j,k] + QCinde[j,cnt]
         IF j lt 5 THEN QST[j,k] = QST[j,k] + QSTinde[j,cnt]
      ENDFOR
   ENDFOR
   
   IF keyword_set(plot) THEN trajectory,xe_actual,ze_actual,i
   ;stop
   ; timetrap option activated by holes
   if not keyword_set(timetrap) then begin
      hol_motion, cnth, pos[0,i], pos[2,i], efx, efz, wpa, wpc, wpst,$
                  th_actual, xh_actual, zh_actual, QAindh, QCindh, QSTindh,$
                  coarsegridpos=[0.75,4.7], ypos=pos[1,i]
   endif else begin
      hol_motion, cnth, pos[0,i], pos[2,i], efx, efz, wpa, wpc, wpst,$
                  th_actual, xh_actual, zh_actual, QAindh, QCindh, QSTindh,$
                  coarsegridpos=[0.75,4.7], /timetrap, ypos=pos[1,i]
   endelse
;   stop
;   cnth=cnth-1
   IF th_actual[cnth] GT 1e-5 THEN BEGIN
      cutofft=where(th_actual GE 1e-5)
      th_actual=th_actual[1:cutofft[0]-1]
      cnth=cutofft[0]-1
   ENDIF ELSE th_actual = th_actual[1:cnth]
 ;  t=floor(max(th_actual-1e-6)*1e8)+ 1000
 ;  if t gt 1800 then t=1800
   th=floor(max(th_actual)*1e9)
;stop
   QAindh = Qaindh*Qr_h[i]
   QCindh = QCindh*Qr_h[i]
   QSTindh = QSTindh*Qr_h[i]
   FOR j=0,15 DO BEGIN
      QA[j,0:th] = QA[j,0:th] + interpol(QAindh[j,1:cnth],th_actual,time[0:th])
      QC[j,0:th] = QC[j,0:th] + interpol(QCindh[j,1:cnth],th_actual,time[0:th]) ;find the bug here
      IF j lt 5 THEN QST[j,0:th] = QST[j,0:th] + interpol(QSTindh[j,1:cnth],th_actual,time[0:th])
      QA[j,th+1:n_elements(time)-1] = QA[j,th+1:n_elements(time)-1] + QAindh[j,cnth]
      QC[j,th+1:n_elements(time)-1] = QC[j,th+1:n_elements(time)-1] + QCindh[j,cnth]
      IF j lt 5 THEN QST[j,th+1:n_elements(time)-1] = QST[j,th+1:n_elements(time)-1] + QSTindh[j,cnth]
   ENDFOR
   ;stop
    IF keyword_set(plot) THEN trajectory,xh_actual,zh_actual,1,/hole
    ;stop
 ENDFOR

;noise level added...
ulevnoise = levnoise * 2 ; WHY?
rand = randomu(systime(1),n_elements(time))
;plot, rand
if keyword_set(levnoise) then begin
   for i=0,15 do begin
      for j=0,n_elements(time)-1 do begin
         noqa[i,j] = QA[i,j] + ulevnoise * (rand[j] - 0.5)
;(randomu(j/5+long(systime(1)))-0.5)
         noqc[i,j] = QC[i,j] + ulevnoise * (rand[j] - 0.5)
         if i lt 5 then noqst[i,j] = QST[i,j] + ulevnoise * (rand[j] - 0.5)
      endfor
   endfor
endif

;**********************************************************************************************

END
