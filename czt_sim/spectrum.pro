PRO spectrum,data,efx,efz,wpa,wpc,wpst,spe
  
  index = where(data[0,*] eq 0,count)
  te = 50
  anarr = dblarr(16,count)
  caarr = dblarr(16,count)
  starr = dblarr(5,count)
  anode = dblarr(16,131)
  cathode = dblarr(16,131)
  steer = dblarr(5,131)
  perc=0

  FOR i=0,count-1 DO BEGIN
     main,data,ndata,efx,efz,wpa,wpc,wpst,i+1,time,qc,qa,qst, $
         qainde,qaindh,qcinde,qcindh,qstinde,qstindh,clouddiv=3,/div

     IF floor((i+1)*100./count) ge perc THEN BEGIN
        print,perc,'%  ',count-i,'events to go....'
        perc = perc + 1
     ENDIF

     ;dont know how to read?
     FOR j=0,15 DO anarr[j,i] = qa[j,te]
     FOR j=0,15 DO caarr[j,i] = qc[j,te]
     FOR j=0,4 DO starr[j,i] = qst[j,te]
     
  ENDFOR
  
  FOR i=0,15 DO anode[i] = histogram(anode[i,*],min=0,max=130)
  FOR i=0,15 DO cathode[i] = histogram(cathode[i,*],min=0,max=130)
  FOR i=0,4 DO steer[i] = histogram(steer[i,*],min=0,max=130)

  spe = create_struct(name='anode',name='cathode',name='steer')

END
