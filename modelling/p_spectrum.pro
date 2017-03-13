;runs main4_ek.pro for given events and get histograms for all events with
;the given event numbers. useful if you want to divide number of events

PRO p_spectrum,data,efx,efz,wpa,wpc,wpst,spe,anarr,caarr,starr,evlist,clouddiv=divcloud,vcount=count,verbose=verbose,timetrap=timetrap,noiselev=levnoise
  
;INPUT
;-------------------------------
;data    : geant data
;efx,efz : used as electric field in main
;wpa,wpc,wpst : weightin potential used in main
;OUTPUT
;-------------------------------
;spe     : struct spe with anode,cathode and steer arrays

  IF NOT keyword_set(divcloud) THEN divcloud = 1 ;may not be implemented

  IF NOT keyword_set(count) THEN BEGIN
     index = where(data[0,*] eq 0,tcount) ;getting indexes of first clouds 
     count= indgen(tcount,/long)+1L
  ENDIF
  
  ;what are these arbitrary numbers, now obsolete
  ;te = 1000
  ;th = 1450

                                ;define energy array

  nelc=n_elements(count)
  anarr = dblarr(16,nelc)
  caarr = dblarr(16,nelc)
  starr = dblarr(5,nelc)

  ;gets spectrum array
  anode = dblarr(16,151)
  cathode = dblarr(16,151)
  steer = dblarr(5,151)
  perc=0.1
  ;count=11

  print, 'calculating sigma data... BUT NOT USED?'
  tcal = dblarr(divcloud,1001)

  cloudsize,sigma,timearr,ftime=1e-6
  FOR i=0,1000 DO BEGIN 
     grid_dist,sigma[i],divcloud,calc
     tcal[0:divcloud-1,i] = calc
  ENDFOR

  ;default value for noise level
  if not keyword_set(levnoise) then levnoise = 0

  print,'starts the job...'
  itime = systime(1)
  ;doing the loop for all events
  FOR i=0,nelc-1 DO BEGIN
     
     ;timetrap option added...
     if not keyword_set (timetrap) then begin
        
        main4_ek,data,efx,efz,wpa,wpc,wpst,count[i],time,qc,qa,qst,$
              noqc,noqa,noqst,noiselev=levnoise
        
     endif else begin
        
        main4_ek,data,efx,efz,wpa,wpc,wpst,count[i],time,qc,qa,qst,$
              noqc,noqa,noqst,noiselev=levnoise,/timetrap

     endelse

     ;to understand program is working...
     if keyword_set(verbose) then begin
        print,i
        IF floor((i+1)*100./nelc) ge perc THEN BEGIN
           time=create_struct('hour',lonarr(2),'min',lonarr(2),'sec',lonarr(2))
           pasttime = floor(systime(1)-itime)
           alltime = floor(pasttime*100/perc)
           tarr = [pasttime,alltime]
           time.hour = floor(tarr/3600)
           tarr = tarr - time.hour*3600
           time.min = floor(tarr/60)
           tarr = tarr - time.min*60
           time.sec = tarr
           
           print,perc,' %',nelc-i,' events to go....        '   , $
                 '[',strtrim(time.hour[0],1),':', strtrim(time.min[0],1),':',strtrim(time.sec[0],1),']-->', $
                 '[',strtrim(time.hour[1],1),':', strtrim(time.min[1],1),':',strtrim(time.sec[1],1),']'
           perc = perc + 1
        ENDIF
     endif

     ;takes the max of signal between 0 and te - wrong! te, th arbitrary
;     FOR j=0,15 DO anarr[j,i] = max(qa[j,0:te])
;     FOR j=0,15 DO caarr[j,i] = max(-qc[j,0:th])
;     FOR j=0,4 DO starr[j,i] = max(qst[j,0:te])

;take end of run, need to check what's going on here

     sz=size(qa)
     
     FOR j=0,15 DO anarr[j,i] = qa[j,sz[2]-1L]
     FOR j=0,15 DO caarr[j,i] = -qc[j,sz[2]-1L]
     FOR j=0,4 DO starr[j,i] = qst[j,sz[2]-1L]

     
  ENDFOR

  ;output definition for rena output
  evlist = dblarr (36,nelc)
  evlist[1:16,*] = caarr
  evlist[17:32,*] = anarr
  evlist[33:35,*] = starr[1:3,*]

  ;writing results to histograms
  FOR i=0,15 DO anode[i,0:150] = histogram(anarr[i,0:nelc-1],min=0,max=150)
  FOR i=0,15 DO cathode[i,0:150] = histogram(caarr[i,0:nelc-1],min=0,max=150)
  FOR i=0,4 DO steer[i,0:150] = histogram(starr[i,0:nelc-1],min=0,max=150)

  ;creating spe struct
  spe = create_struct('anode',anode,'cathode',cathode,'steer',steer)

END
