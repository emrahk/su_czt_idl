PRO main3,data,event,efx,efz,wpa,wpc,wpst,eventnumb,time,qc,qa,qst, $
          qainde,qaindh,qcinde,qcindh,qstinde,qstindh,clouddiv=divcloud, $
          calct=tcalc,divide=divide,plot=plot

IF NOT keyword_set(divcloud) THEN divcloud = 1

geteventinfo,data,eventnumb,pos,ener
cloudnumb = n_elements(ener)
Qr_e = ener                     ;???????? 2 choosen as bandgap !!!multiply by e
Qr_h = -ener                    ;???????? 2 choosen as bandgap !!!multiply by e

timee = findgen(1001)*1e-9
timeh = findgen(1201)*1e-8

time=[timee,timeh[where(timeh gt max(timee))]]

QA = dblarr(16,n_elements(time))
QC = dblarr(16,n_elements(time))
QST = dblarr(16,n_elements(time))

IF NOT keyword_set(tcalc) THEN BEGIN
   tcalc = dblarr(divcloud,1000)
   cloudsize,sigma,timearr,ftime=1e-6
   FOR i=0,999 DO BEGIN 
      grid_dist,sigma[i],divcloud,calc
      tcalc[0:divcloud-1,i] = calc
   ENDFOR
ENDIF

FOR i=0,cloudnumb-1 DO BEGIN
   index = where(pos[2,*] lt 0.85)
   IF index[0] ne -1 THEN BEGIN
      elec_motion,0., cnt, pos[0,i], pos[2,i], efx, efz, wpa, wpc, wpst,$
                  te_actual, xe_actual, ze_actual, QAinde, QCinde, QSTinde, qtinda,qtindc,qtindst,coarsegridpos=[0.75,4.7]     
      te_actual = te_actual[1:cnt]
      t=floor(max(te_actual)*1e9)
      QAinde = Qainde*Qr_e[i]
      QCinde = QCinde*Qr_e[i]
      QSTinde = QSTinde*Qr_e[i] 
      FOR j=0,15 DO BEGIN
         QA[j,0:t] = QA[j,0:t] + interpol(QAinde[j,1:cnt],te_actual,time[0:t])
         QC[j,0:t] = QC[j,0:t] + interpol(QCinde[j,1:cnt],te_actual,time[0:t])
         IF j lt 5 THEN QST[j,0:t] = QST[j,0:t] + interpol(QSTinde[j,1:cnt],te_actual,time[0:t])
         QA[j,t+1:n_elements(time)-1] = QA[j,t+1:n_elements(time)-1] + QAinde[j,cnt]
         QC[j,t+1:n_elements(time)-1] = QC[j,t+1:n_elements(time)-1] + QAinde[j,cnt]
         IF j lt 5 THEN QST[j,t+1:n_elements(time)-1] = QST[j,t+1:n_elements(time)-1] + QAinde[j,cnt]
      ENDFOR
   ENDIF ELSE BEGIN
       elec_motion,0.75, cnt, pos[0,i], pos[2,i], efx, efz, wpa, wpc, wpst,$
                  te_actual, xe_actual, ze_actual, QAinde, QCinde, QSTinde, qtinda,qtindc,qtindst,restq,coarsegridpos=[0.75,4.7]
       xpos = round(xe_actual[cnt]/0.005)
       IF xpos gt 3908 THEN xpos = 3908
       IF xpos lt 0 THEN xpos = 0
       cnt2 = event[xpos].size-1
       te_actual = [te_actual[1:cnt],event[xpos].tac[1:cnt2]+te_actual[cnt]]
       xe_actual = [xe_actual[1:cnt],event[xpos].xac[1:cnt2]]
       ze_actual = [ze_actual[1:cnt],event[xpos].zac[1:cnt2]]
       t=floor(max(te_actual)*1e9)
       Qainde2 = dblarr(16,cnt+cnt2+1)
       Qcinde2 = dblarr(16,cnt+cnt2+1)
       Qstinde2 = dblarr(5,cnt+cnt2+1)
       FOR a=0,15 DO BEGIN 
          first = Qainde[a,1:cnt]*Qr_e[i]
          second = Qr_e[i]*restq*(event[xpos].wa[a,1:cnt2]+qtinda[a])
          QAinde2[a,1:cnt] = first
          Qainde2[a,cnt+1:cnt+cnt2] = second
          first = Qcinde[a,1:cnt]*Qr_e[i]
          second = Qr_e[i]*restq*(event[xpos].wc[a,1:cnt2]+qtindc[a])
          QCinde2[a,1:cnt] = first
          QCinde2[a,cnt+1:cnt+cnt2] = second
          IF a lt 5 THEN BEGIN 
             first = Qstinde[a,1:cnt]*Qr_e[i]
             second = Qr_e[i]*restq*(event[xpos].wa[a,1:cnt2]+qtindst[a])
             Qstinde2[a,1:cnt] = first
             Qstinde2[a,cnt+1:cnt+cnt2] = second
          ENDIF
       ENDFOR
       ;stop
       FOR j=0,15 DO BEGIN
         QA[j,0:t] = QA[j,0:t] + interpol(QAinde2[j,1:cnt+cnt2],te_actual,time[0:t])
         QC[j,0:t] = QC[j,0:t] + interpol(QCinde2[j,1:cnt+cnt2],te_actual,time[0:t])
         IF j lt 5 THEN QST[j,0:t] = QST[j,0:t] + interpol(QSTinde2[j,1:cnt+cnt2],te_actual,time[0:t])
         QA[j,t+1:n_elements(time)-1] = QA[j,t+1:n_elements(time)-1] + QAinde2[j,cnt+cnt2]
         QC[j,t+1:n_elements(time)-1] = QC[j,t+1:n_elements(time)-1] + Qcinde2[j,cnt+cnt2]
         IF j lt 5 THEN QST[j,t+1:n_elements(time)-1] = QST[j,t+1:n_elements(time)-1] + QStinde2[j,cnt+cnt2]
      ENDFOR
       ;stop
   ENDELSE
   IF keyword_set(plot) THEN trajectory,xe_actual,ze_actual,i
   hol_motion, cnt, pos[0,i], pos[2,i], efx, efz, wpa, wpc, wpst,$
               th_actual, xh_actual, zh_actual, QAindh, QCindh, QSTindh, coarsegridpos=[0.75,4.7]     
   cnt = cnt -1
   th_actual = th_actual[1:cnt]
   t=floor(max(th_actual-1e-6)*1e8)+1000
   if t gt 1800 then t = 1800
   QAindh = Qaindh*Qr_e[i]
   QCindh = QCindh*Qr_e[i]
   QSTindh = QSTindh*Qr_e[i]
   FOR j=0,15 DO BEGIN
      QA[j,0:t] = QA[j,0:t] + interpol(QAindh[j,1:cnt],th_actual,time[0:t])
      QC[j,0:t] = QC[j,0:t] + interpol(QCindh[j,1:cnt],th_actual,time[0:t])
      IF j lt 5 THEN QST[j,0:t] = QST[j,0:t] + interpol(QSTindh[j,1:cnt],th_actual,time[0:t])
      QA[j,t+1:n_elements(time)-1] = QA[j,t+1:n_elements(time)-1] + QAindh[j,cnt]
      QC[j,t+1:n_elements(time)-1] = QC[j,t+1:n_elements(time)-1] + QCindh[j,cnt]
      IF j lt 5 THEN QST[j,t+1:n_elements(time)-1] = QST[j,t+1:n_elements(time)-1] + QSTindh[j,cnt]
   ENDFOR
    IF keyword_set(plot) THEN trajectory,xh_actual,zh_actual,1,/hole
ENDFOR

;**********************************************************************************************

END
