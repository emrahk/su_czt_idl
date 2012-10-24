;*******************************************************************************
;this program will be for image analysing but should be improved some way:)
;-------------------------------------------------------------------------------
pro imageanalyse,pixenergy,aperture,image,takeimage=takeimage
;-------------------------------------------------------------------------------
;Yigit Dallilar 22.10.2012
;INPUT
;pixenergy   : written energies in the pixel
;aperture    : mask aperture function
;KEYWORD
;takeimage   : if keyword is specified takes image from codedmasksim.pro
;              no input values needed
;-------------------------------------------------------------------------------
;gets data from codedmasksim.pro
;options for the simulation is inside "codedmaksim.ini"
  if keyword_set(takeimage) then codedmasksim,pixenergy,aperture

;imaging part
;!! look for imaging codes
r=double(convol(long(aperture),long(pixenergy)) 
end
;*******************************************************************************
