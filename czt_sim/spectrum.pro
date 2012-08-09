;runs main.pro for all events and get histograms for all events
PRO spectrum,data,efx,efz,wpa,wpc,wpst,spe
  
;INPUT
;-------------------------------
;data    : geant data
;efx,efz : used as electric field in main
;wpa,wpc,wpst : weightin potential used in main
;OUTPUT
;-------------------------------
;spe     : struct spe with anode,cathode and steer
 
  index = where(data[0,*] eq 0,count) ;getting indexes of first clouds
  te = 100

  ;define energy array
  anarr = dblarr(16,count)
  caarr = dblarr(16,count)
  starr = dblarr(5,count)

  ;gets spectrum array
  anode = dblarr(16,131)
  cathode = dblarr(16,131)
  steer = dblarr(5,131)
  perc=0
  ;count=11

  ;doing the loop for all events
  FOR i=0,count-1 DO BEGIN
     main,data,ndata,efx,efz,wpa,wpc,wpst,i+1,time,qc,qa,qst, $
         qainde,qaindh,qcinde,qcindh,qstinde,qstindh,clouddiv=3,/div

     IF floor((i+1)*100./count) ge perc THEN BEGIN
        print,perc,'%  ',count-i,'events to go....'
        perc = perc + 1
     ENDIF

     ;dont know how to read?
     FOR j=0,15 DO anarr[j,i] = max(qa[j,0:te])
     FOR j=0,15 DO caarr[j,i] = max(qc[j,0:te])
     FOR j=0,4 DO starr[j,i] = max(qst[j,0:te])
     
  ENDFOR

  ;getting histograms
  FOR i=0,15 DO anode[i,0:130] = histogram(anarr[i,0:count-1],min=0,max=130)
  FOR i=0,15 DO cathode[i,0:130] = histogram(caarr[i,0:count-1],min=0,max=130)
  FOR i=0,4 DO steer[i,0:130] = histogram(starr[i,0:count-1],min=0,max=130)

  ;creating spe struct
  spe = create_struct('anode',anode,'cathode',cathode,'steer',steer)

END
