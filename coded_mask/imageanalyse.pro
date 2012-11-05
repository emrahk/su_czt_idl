;****************************************************************************
;this program is written for analysing pixenergy datas
;----------------------------------------------------------------------------
pro imageanalyse,odata=data,omask=mask,odetector=detector,obackgrnd=backgrnd
;----------------------------------------------------------------------------
; Yigit Dallilar 04.11.2012
; OPTIONAL INPUT
; data     : data structure can be added from outside
; mask     : mask structure can be added from outside
; detector : detector structure can be added from outside
; backgrnd : background amplitude can be added from outside 
;----------------------------------------------------------------------------
  form_struct,tnofsource,tsource,tmask,tdetector,tbackgrnd	
  if ~ keyword_set(data) then restore,'data/pixenergy.sav'
  if ~ keyword_set(mask) then mask=tmask 
  if ~ keyword_set(detector) then detector=tdetector
  if ~ keyword_set(backgrnd) then backgrnd=tbackgrnd

  ndx=bytarr(n_elements(data))
  for i=0,n_elements(data)-1 do begin
    cmask = compare_struct(data[i].mask,mask)
    cdetector = compare_struct(data[i].detector,detector)
    if cmask[0].ndiff eq 0 and cdetector[0].ndiff eq 0 then ndx[i]=1
  endfor
  ndx=where(ndx eq 1)

  pixenergy = detector.pixenergy

  if ndx[0] ne -1 then begin
    device,decomposed=0
    window,0,xsize=1000,ysize=1000
    !p.multi=[0,4,4]
    loadct,11

    for i=0,n_elements(ndx)-1 do begin
      image = convol_fft(data[ndx[i]].mask.apert*2-1,rotate(data[ndx[i]].pixenergy,2))
      maxndx = where(image eq max(image))
      image[maxndx] = image[maxndx]*2 
      contour,image,/fill,nlev=40
    endfor     	
    print_struct,data[ndx].source,["postype","dirtype","radius","nofphot", $
	"pos","angle"]

  endif else begin

    print,"no match for mask and detector"
    pmask = data[0].mask
    pdetector = data[0].detector

    for i=1,n_elements(data)-1 do begin

      cntrl=1
      for j=0,n_elements(pdetector)-1 do begin
        cdetector = compare_struct(pdetector[j],data[i].detector)
        if cdetector[0].ndiff eq 0 then begin
          cntrl=0
          break
        endif 
      endfor
      if cntrl eq 1 then pdetector=[pdetector,data[i].detector]  

      cntrl=1
      for j=0,n_elements(pmask)-1 do begin
        cmask = compare_struct(pmask[j],data[i].mask)
        if cmask[0].ndiff eq 0 then begin
	  cntrl=0
          break
        endif 
      endfor  
      if cntrl eq 1 then pmask=[pmask,data[i].mask]

    endfor

    print,"available masks"
    print_struct,pmask,["pixsize","num","array"]
    print,"available detectors"
    print_struct,pdetector,["length","z","pixsize"]

  endelse

end
;****************************************************************************
