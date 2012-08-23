;************************************************************************
;to visualise posxz and evlist datas
;------------------------------------------------------------------------

PRO analyse,posxz,evlist,rangex=rx,rangez=rz,grange=gry,gthick=gth,cathodeno=catno,anodeno=andno,steerno=stno,symbol=sym,option=vopt
  
;------------------------------------------------------------------------
;Yiğit Dallılar 22.08.2012
;------------------------------------------------------------------------
;INPUT
;posxz      :  x and z positions of the first clouds
;evlist     :  evlist data as general output
;OPTIONAL
;range(x,z) :  x and z range for the events
;grange     :  result range for the graph
;cathodeno  :  cathode index starting from left to right (1,2,...,16)
;anodeno    :  anode index starting from left to right (1,2,....,16)
;steerno    :  index for middle three steering electrodes from left to right
;symbol     :  symbol for the plot procedure
;gthick     :  thickness for the plotting symbol
;option     :  options for the program
;     *use positions as parameter : 
;       - 0 :  cathode energies with respect to z
;       - 1 :  anode energies with respect to z
;       - 2 :  anode energies with respect to x
;       - 3 :  anode/cathode ratio with respect to z
;       - 4 :  cathode/anode ratio with respect to z
;       - 5 :  steering electrode energies with respect to z
;       - 6 :  steering electrode energies with respect to x
;     *use energies as parameter :
;       - 7 :  specified anode energy vs. previous neighbour anode energy
;       - 8 :  specified anode energy vs. specified cathode energy
;       - 9 :  specifide anode energy vs. specified steering electrode energy
;       - 10:  specified steering energy vs. specified cathode energy
;------------------------------------------------------------------------
;NOTES 
;-just to remember for evlist : 1,16 cathodes / 17,32 anodes / 33,35 steering..
;-option 2 and 6 can give an idea about the positions of electrodes 
;------------------------------------------------------------------------

  if not keyword_set(rx) then rx = [0.,19.54]
  if not keyword_set(rz) then rz = [0.,5.]
  if not keyword_set(gth) then gth = 1
  if not keyword_set(catno) then catno = 11
  if not keyword_set(andno) then andno = 10
  if not keyword_set(stno) then stno = 2
  if not keyword_set(sym) then sym = 3
  if not keyword_set(vopt) then vopt = 0

  ;for anode no 
  andno = andno + 16
  stno = stno + 32

  index = where (posxz[0,*] gt rx[0] and posxz[0,*] lt rx[1] and posxz[1,*] gt rz[0] and posxz[1,*] lt rz[1])  
  xx = posxz[0,index]
  zz = posxz[1,index]

  cnt = n_elements(vopt) 
  ;for now 
  cnt = 1
  
  ;does all the options as specified above
  for i=0, cnt -1 do begin

     case vopt[i] of

        0 : begin
           if keyword_set(gry) then begin
               plot,zz,evlist[catno,index],xrange=rz,psym=sym,yrange=gry,thick=gth, $
                    ytitle='cathode '+strtrim(catno,1)+' (keV)',xtitle='distance from bottom (mm)'
            endif else begin
               plot,zz,evlist[catno,index],xrange=rz,psym=sym,thick=gth, $
                    ytitle='cathode '+strtrim(catno,1)+' (keV)',xtitle='distance from bottom (mm)'
            endelse
        end
        
        1 : begin
           if keyword_set(gry) then begin
              plot,zz,evlist[andno,index],xrange=rz,psym=sym,yrange=gry,thick=gth, $
                   ytitle='anode '+strtrim(andno-16,1)+' (keV)',xtitle='distance from bottom (mm)'
           endif else begin
              plot,zz,evlist[andno,index],xrange=rz,psym=sym,thick=gth, $
                   ytitle='anode '+strtrim(andno-16,1)+' (keV)',xtitle='distance from bottom (mm)'
           endelse
        end
        
        2 : begin
           if keyword_set(gry) then begin
              plot,xx,evlist[andno,index],xrange=rx,psym=sym,yrange=gry,thick=gth, $
                   ytitle='anode '+strtrim(andno-16,1)+' (keV)',xtitle='distance from left (mm)'
           endif else begin
              plot,xx,evlist[andno,index],xrange=rx,psym=sym,thick=gth, $
                   ytitle='anode '+strtrim(andno-16,1)+' (keV)',xtitle='distance from left (mm)'
           endelse
        end
        
        3 : begin
           if keyword_set(gry) then begin
              plot,zz,evlist[andno,index]/evlist[catno,index],xrange=rz,psym=sym,yrange=gry,thick=gth, $
                   ytitle='anode'+strtrim(andno-16,1)+'/cathode'+strtrim(catno,1)+' ratio',xtitle='distance from bottom (mm)'
           endif else begin
              plot,zz,evlist[andno,index]/evlist[catno,index],xrange=rz,psym=sym,thick=gth, $
                   ytitle='anode'+strtrim(andno-16,1)+'/cathode'+strtrim(catno,1)+' ratio',xtitle='distance from bottom (mm)'
           endelse
        end

        4 : begin
           if keyword_set(gry) then begin
              plot,zz,evlist[catno,index]/evlist[andno,index],xrange=rz,psym=sym,yrange=gry,thick=gth, $
                   ytitle='cathode'+strtrim(catno,1)+'/anode'+strtrim(andno-16,1)+' ratio',xtitle='distance from bottom (mm)'
           endif else begin
              plot,zz,evlist[catno,index]/evlist[andno,index],xrange=rz,psym=sym,thick=gth, $
                   ytitle='cathode'+strtrim(catno,1)+'/anode'+strtrim(andno-16,1)+' ratio',xtitle='distance from bottom (mm)'
           endelse
        end

         5 : begin
           if keyword_set(gry) then begin
              plot,zz,evlist[stno,index],xrange=rz,psym=sym,yrange=gry,thick=gth, $
                   ytitle='steer'+strtrim(stno-32,1)+' (keV)',xtitle='distance from bottom (mm)'
           endif else begin
              plot,zz,evlist[stno,index],xrange=rz,psym=sym,thick=gth, $
                   ytitle='steer'+strtrim(stno-32,1)+' (keV)',xtitle='distance from bottom (mm)'
           endelse
        end

         6 : begin
           if keyword_set(gry) then begin
              plot,xx,evlist[stno,index],xrange=rx,psym=sym,yrange=gry,thick=gth, $
                   ytitle='steer'+strtrim(stno-32,1)+' (keV)',xtitle='distance from left (mm)'
           endif else begin
              plot,xx,evlist[stno,index],xrange=rx,psym=sym,thick=gth, $
                   ytitle='steer'+strtrim(stno-32,1)+' (keV)',xtitle='distance from left (mm)'
           endelse
        end

         7 : begin
           if keyword_set(gry) then begin
              plot,evlist[andno,index],evlist[andno-1,index],psym=sym,yrange=gry,thick=gth, $
                   ytitle='anode'+strtrim(andno-17,1)+' (keV)',xtitle='anode'+strtrim(andno-16,1)+' (keV)'
           endif else begin
              plot,evlist[andno,index],evlist[andno-1,index],psym=sym,thick=gth, $
                   ytitle='anode'+strtrim(andno-17,1)+' (keV)',xtitle='anode'+strtrim(andno-16,1)+' (keV)'
           endelse
        end

         8 : begin
           if keyword_set(gry) then begin
              plot,evlist[andno,index],evlist[catno,index],psym=sym,yrange=gry,thick=gth, $
                   ytitle='cathode'+strtrim(catno,1)+' (keV)',xtitle='anode'+strtrim(andno-16,1)+' (keV)'
           endif else begin
              plot,evlist[andno,index],evlist[catno,index],psym=sym,thick=gth, $
                   ytitle='cathode'+strtrim(catno,1)+' (keV)',xtitle='anode'+strtrim(andno-16,1)+' (keV)'
           endelse
        end

         9 : begin
           if keyword_set(gry) then begin
              plot,evlist[andno,index],evlist[stno,index],psym=sym,yrange=gry,thick=gth, $
                   ytitle='steer'+strtrim(stno-32,1)+' (keV)',xtitle='anode'+strtrim(andno-16,1)+' (keV)'
           endif else begin
              plot,evlist[andno,index],evlist[stno,index],psym=sym,thick=gth, $
                   ytitle='steer'+strtrim(stno-32,1)+' (keV)',xtitle='anode'+strtrim(andno-16,1)+' (keV)'
           endelse
        end

         10 : begin
           if keyword_set(gry) then begin
              plot,evlist[stno,index],evlist[catno,index],psym=sym,yrange=gry,thick=gth, $
                   ytitle='cathode'+strtrim(catno,1)+' (keV)',xtitle='steer'+strtrim(stno,1)+' (keV)'
           endif else begin
              plot,evlist[stno,index],evlist[catno,index],psym=sym,thick=gth, $
                   ytitle='cathode'+strtrim(catno,1)+' (keV)',xtitle='steer'+strtrim(stno,1)+' (keV)'
           endelse
        end

     endcase

  endfor
       
END
