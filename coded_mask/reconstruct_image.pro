;***************************************************************************
; This program will help us to reconstruct image from pixenergies.
;---------------------------------------------------------------------------
pro reconstruct_image,data,pixenergy,image
;---------------------------------------------------------------------------
; Yigit Dallilar
; 24.01.2013
; INPUT
; OUTPUT
; OPTIONAL INPUT
;---------------------------------------------------------------------------

getmask,[2,2],17,mask,pixsize = 1.2

pixenergy = dblarr(34,34)

data[1:2,*] = floor((data[1:2,*] + 20.4)/1.2)

length = n_elements(data[1,*]) - 1 

for ndx = 0, length do begin
  if data[1,ndx] ge 0. and data[1,ndx] lt 34. and data[2,ndx] ge 0. and data[2,ndx] lt 34.then begin
    pixenergy(data[1,ndx],data[2,ndx]) = pixenergy(data[1,ndx],data[2,ndx]) + data[4,ndx]
  endif
endfor

device,decomposed=0
;window,0,xsize=1000,ysize=1000
image = convol_fft(rotate(mask.apert*2-1,3),rotate(pixenergy,2))

end
;***************************************************************************

