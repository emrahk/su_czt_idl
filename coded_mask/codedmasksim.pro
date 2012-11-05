;*******************************************************************************
;this program is the combining part of the simulation
;-------------------------------------------------------------------------------
pro codedmasksim,data,backgrnd,omask=mask,odetector=detector, $
	plot=plot,verbose=verbose
;-------------------------------------------------------------------------------
;Yigit Dallilar 22.10.2012
;OUTPUT
;data        : data struct (every information about the simulation)
;backgrnd    : background noise amplitude can be get from .ini file
;KEYWORD
;plot        : realise some plots
;verbose     : information about program working
;-------------------------------------------------------------------------------

;getting structs
  form_struct,nofsource,source,fmask,fdetector,backgrnd
  if ~ keyword_set(mask) then mask=fmask
  if ~ keyword_set(detector) then detector=fdetector

;data struct for output can be improved later ...
  data=create_struct("pixenergy",detector.pixenergy,"source",source[0], $
			"detector",detector,"mask",mask)
  data=replicate(data,nofsource)
  len=sqrt(n_elements(pixenergy))
 
;run photonshoot1.pro for number of sources
  if keyword_set(verbose) then print,'NUMBER OF SOURCES : ',nofsource
  for i=0, nofsource-1 do begin 
     data[i].source=source[i]
     photonshoot1,source[i],detector,mask,pixenergy
   ;stop ;;;;;;;;;;;;;;
     data[i].pixenergy=pixenergy ;+ backgrnd*randomn(systime(1)+i,len,len)
     if keyword_set(verbose) then print,i+1,'. source completed...'
  endfor

;imaging for just control,
  if keyword_set(plot) then begin
    device,decomposed=0
    loadct,5
    window,0,xsize=900,ysize=300
    !p.multi=[0,3,1]
    contour,pixenergy,nlevel=20,/fill;,xr=[15,60],yr=[15,60]		
    image=convol_fft(mask.apert*2-1,rotate(pixenergy,2))
    contour,image,nlevel=20,/fill;,xr=[15,60],yr=[15,60]	
    image=convol_fft(image,exp(-shift(dist(3,3),1,1))^2)
    contour,image,nlevel=20,/fill;,xr=[15,60],yr=[15,60]	
  endif

end
;*******************************************************************************
