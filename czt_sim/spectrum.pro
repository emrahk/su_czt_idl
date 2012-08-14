;runs main.pro for all events and get histograms for all events
PRO spectrum,data,event,efx,efz,wpa,wpc,wpst,spe,clouddiv=divcloud
  
;INPUT
;-------------------------------
;data    : geant data
;efx,efz : used as electric field in main
;wpa,wpc,wpst : weightin potential used in main
;OUTPUT
;-------------------------------
;spe     : struct spe with anode,cathode and steer arrays

  IF NOT keyword_set(divcloud) THEN divcloud = 1

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
  perc=1
  ;count=11

  print, 'calculating sigma data...'
  tcal = dblarr(divcloud,1000)

  cloudsize,sigma,timearr,ftime=1e-6
  FOR i=0,999 DO BEGIN 
     grid_dist,sigma[i],divcloud,calc
     tcal[0:divcloud-1,i] = calc
  ENDFOR

  print,'starts the job...'
  itime = systime(1)
  ;doing the loop for all events
  FOR i=0,count-1 DO BEGIN
     main2,data,event,efx,efz,wpa,wpc,wpst,i+1,time,qc,qa,qst, $
         qainde,qaindh,qcinde,qcindh,qstinde,qstindh,clouddiv=divcloud,calct=tcal,/div

     ;to understand program is working...
     IF floor((i+1)*100./count) ge perc THEN BEGIN
        time=create_struct('hour',lonarr(2),'min',lonarr(2),'sec',lonarr(2))
        pasttime = floor(systime(1)-itime)
        alltime = floor(pasttime*100/perc)
        tarr = [pasttime,alltime]
        time.hour = floor(tarr/3600)
        tarr = tarr - time.hour*3600
        time.min = floor(tarr/60)
        tarr = tarr - time.min*60
        time.sec = tarr

        print,perc,' %',count-i,' events to go....        '   , $
              '[',strtrim(time.hour[0],1),':', strtrim(time.min[0],1),':',strtrim(time.sec[0],1),']-->', $
              '[',strtrim(time.hour[1],1),':', strtrim(time.min[1],1),':',strtrim(time.sec[1],1),']'
        perc = perc + 1
     ENDIF

     ;takes the max of signal between 0 and te
     FOR j=0,15 DO anarr[j,i] = max(qa[j,0:te])
     FOR j=0,15 DO caarr[j,i] = max(qc[j,0:te])
     FOR j=0,4 DO starr[j,i] = max(qst[j,0:te])
     
  ENDFOR

  ;writing results to histograms
  FOR i=0,15 DO anode[i,0:130] = histogram(anarr[i,0:count-1],min=0,max=130)
  FOR i=0,15 DO cathode[i,0:130] = histogram(caarr[i,0:count-1],min=0,max=130)
  FOR i=0,4 DO steer[i,0:130] = histogram(starr[i,0:count-1],min=0,max=130)

  ;creating spe struct
  spe = create_struct('anode',anode,'cathode',cathode,'steer',steer)

END
