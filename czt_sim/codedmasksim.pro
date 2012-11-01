;*******************************************************************************
; uses codedmasksim.ini for initial datas and run photonshoot1.pro for
; # of sources
;-------------------------------------------------------------------------------
pro codedmasksim,image,pixenergy,aperture,verbose=verbose
;-------------------------------------------------------------------------------
;Yigit Dallılar 21.10.2012
;INPUT      : comes from the file "codedmasksim.ini" 
;OUTPUT
;pixenergy  : detector pixel energies
;aperture   : mask aperture funtion
;KEYWORD
;verbose    : duration might be long so informs about the process 
;-------------------------------------------------------------------------------

;reads codedmasksim.ini and creates structs
  openr,2,"codedmasksim.ini"
  starcnt=0                     ;counts stars for option number
  nofsource=0                   ;number of source in the file
  sourcendx=0                   ;source index for control different sources

  while not eof(2) do begin
     tmp = ' '
     readf,2,tmp
     char = byte(tmp)
     if char[0] ne 35 then begin
        if char[0] eq 42 then begin
           starcnt = starcnt + 1
        endif else begin
           case starcnt of 
;gets # of source & creates sources for desired number
              0 : begin
                 nofsource = long(tmp)
                 source=create_struct('postype',0,'dirtype',0,'radius',0., $
                                     'nofphot',0.,'energy',0., $
                                      'pos',[0.,0.,0.],'angle',[0.,0.])
                 source=replicate(source,nofsource)
              end
;fills source data
              1 : begin
                 tmp = strsplit(tmp,' ',/extract)
                 source[sourcendx].postype = byte(long(tmp[0]))
                 source[sourcendx].dirtype = byte(long(tmp[1]))
                 source[sourcendx].radius = double(tmp[2])
                 source[sourcendx].nofphot = long(tmp[3])
                 source[sourcendx].energy = double(tmp[4])
                 source[sourcendx].pos = double([tmp[5],tmp[6],tmp[7]])
                 source[sourcendx].angle = double([tmp[8],tmp[9]])*!pi
                 sourcendx = sourcendx + 1
              end
;creates mask struct with the help of getmask.pro
              2 : begin
                 tmp = strsplit(tmp,' ',/extract)
                 getmask,long([tmp(1),tmp(2)]),long(tmp[0]), $
                         mask,pixsize=double(tmp[3])
              end
;creates detector struct
              3 : begin 
                 tmp = strsplit(tmp,' ',/extract)
                 detector=create_struct('z',double(tmp[2]), $
                                        'pixsize',double(tmp[1]), $
                                        'pixenergy',dblarr([tmp[0],tmp[0]]), $
                                        'pos',dblarr([tmp[0],tmp[0],2]))
                 tarray = (findgen(tmp[0])-(tmp[0]/2.-0.5))*detector.pixsize
                 for i=0,long(tmp[0])-1 do detector.pos[*,i,0]=tarray
                 for i=0,long(tmp[0])-1 do detector.pos[i,*,1]=tarray
              end
;random noise can be added, backgrnd is the amplitude
              4 : backgrnd = double(tmp)
              else : break
           endcase
        endelse
     endif
  endwhile

;close codedmasksim.ini
  close,2
  
  pixenergy=detector.pixenergy

  ;print,source
;run photonshoot1.pro for number of sources
  if keyword_set(verbose) then print,'NUMBER OF SOURCES : ',nofsource
  for i=0, nofsource-1 do begin 
     photonshoot1,source[i],detector,mask,opixenergy
     pixenergy=pixenergy+opixenergy
     if keyword_set(verbose) then print,i+1,'. source completed...'
  endfor

if backgrnd ne 0 then begin
  len=sqrt(n_elements(pixenergy))
  pixenergy = pixenergy + backgrnd*randomn(systime(1),len,len)
endif

;imaging for just control,
  device,decomposed=0
  loadct,5
  window,0,xsize=900,ysize=300
  !p.multi=[0,3,1]
  contour,pixenergy,nlevel=40,/fill;,xr=[15,60],yr=[15,60]		
  image=double(convol(long(mask.apert*2-1),long(pixenergy)))
  contour,image,nlevel=40,/fill;,xr=[15,60],yr=[15,60]	
  image=double(convol(image,exp(-shift(dist(3,3),1,1)))^2)
  contour,image,nlevel=40,/fill;,xr=[15,60],yr=[15,60]
  ;contour,(image/max(image))^10,nlevel=100,/fill;,xr=[15,60],yr=[15,60]	
    
end
;*******************************************************************************
