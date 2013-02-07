;***************************************************************************
; This program will look for the energies of the radioactive source 
; from geant output
;---------------------------------------------------------------------------
pro radioactive_spectrum,data,energy
;---------------------------------------------------------------------------
; Yigit Dallilar
;
;
;---------------------------------------------------------------------------

len = n_elements(data[0,*]) - 2

energy=dblarr(1000)

temp_energy = 0

for i = 0, len do begin

  temp_energy = temp_energy + data[4,i]*1000

  if data[0,i] gt data[0,i+1] then begin
    energy[floor(temp_energy)] = energy[floor(temp_energy)] + 1
    temp_energy = 0
  endif
  
  if i eq len then begin
    temp_energy = temp_energy + data[4,i]*1000
    energy[floor(temp_energy)] = energy[floor(temp_energy)] + 1
  endif  
  
endfor

end
;***************************************************************************
