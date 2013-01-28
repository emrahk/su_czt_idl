;***************************************************************************
; This program will help us to reconstruct image from pixenergies.
;---------------------------------------------------------------------------
reconstruct_image,data,pixenergy
;---------------------------------------------------------------------------
; Yigit Dallilar
; 24.01.2013
; INPUT
; OUTPUT
; OPTIONAL INPUT
;---------------------------------------------------------------------------

getmask,[2,2],17,mask,pixsize = 1.2

pixenergy = dblarr(34,34)

data[1:2,*] = floor(data[1:2,*] + 20.4)

length = n_elements(data[1,*]) - 1 

for ndx = 0, length do begin
  pixenergy(data[1,ndx],data[2,ndx]) = pixenergy(data[1,ndx],data[2,ndx]) + data[4,ndx]
endfor

;image reconstruction starts here ...

;***************************************************************************

