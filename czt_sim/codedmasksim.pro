;********************************************************************************
; uses codedmasksim.ini and photonshoot1.pro
;--------------------------------------------------------------------------------
pro codedmasksim
;--------------------------------------------------------------------------------
;Yigit Dallılar 21.10.2012
;
;--------------------------------------------------------------------------------

;reads codedmasksim.ini
  openr,2,"codedmasksim.ini"
  starcnt=0
  nofsource=0
  sourcendx=0
  while not eof(2) do begin
     tmp = ' '
     readf,2,tmp
     char = byte(tmp)
     if char[0] ne 35 then begin
        if char[0] eq 42 then begin
           starcnt = starcnt + 1
        endif else begin
           case starcnt of 
              0 : begin
                 nofsource = long(tmp)
                 source=create_struct('postype',0,'dirtype',0,'radius',0., $
                                     'nofphot',0.,'energy',0.,'pos',[0.,0.,0.], $
                                     'angle',[0.,0.])
                 source=replicate(source,nofsource)
              end
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
              2 : begin
                 tmp = strsplit(tmp,' ',/extract)
                 getmask,long([tmp(1),tmp(2)]),long(tmp[0]), $
                         mask,pixsize=double(tmp[3])
              end
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
              4 : backgrnd = double(tmp)
              else : break
           endcase
        endelse
     endif
  endwhile

  close,2

;run photonshoot1.pro
  for i=0, nofsource-1 do begin 
     photonshoot1,source[i],detector,mask,pixenergy
     detector.pixenergy = detector.pixenergy + pixenergy
  endfor

  image=double(convol(long(mask.apert),long(pixenergy)))
  contour,(image/max(image))^1,nlevel=100,/fill,xr=[15,65],yr=[15,65]
  contour,(image/max(image))^41,nlevel=100,/fill,xr=[15,65],yr=[15,65]
  contour,(image/max(image))^301,nlevel=100,/fill,xr=[15,65],yr=[15,65]
  
end
;********************************************************************************
