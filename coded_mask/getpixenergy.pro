;***************************************************************************
; This program will help us to reconstruct image from pixenergies.
;---------------------------------------------------------------------------
pro getpixenergy,data,pixenergy
;---------------------------------------------------------------------------
; Yigit Dallilar
; 24.01.2013
; INPUT
; OUTPUT
; OPTIONAL INPUT
;---------------------------------------------------------------------------

;getmask,[2,2],37,mask,pixsize = 1.2

pixenergy = dblarr(34,34)

pos = floor((data[1:2,*] + 20.4)/1.2)

length = n_elements(data[1,*]) - 1 

for ndx = 0, length do begin
  if pos[0,ndx] ge 0. and pos[0,ndx] lt 34. and pos[1,ndx] ge 0. and pos[1,ndx] lt 34.then begin
    pixenergy(pos[0,ndx],pos[1,ndx]) = pixenergy(pos[0,ndx],pos[1,ndx]) + data[4,ndx]
  endif
endfor

end
;***************************************************************************

