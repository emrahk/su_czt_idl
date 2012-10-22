;******************************************************************************
;creates photons on the source shoots them over the mask and holds
;placement data on the detector for the ones who passes the mask
;------------------------------------------------------------------------------
pro photonshoot1,source,detector,mask, $
                pixenergy,maskhit,dethit, $
                plot=plot
;------------------------------------------------------------------------------
;compile_opt strictarrsubs
;------------------------------------------------------------------------------
;Yigit Dallilar 14.10.2012
;INPUT 
;source      : source struct 
;detector    : detector struct
;mask        : mask struct
;(they are defined in codedmasksim.pro)
;OUTPUT
;maskhit     : mask hit positions
;dethit      : detector hit positions
;pixenergy   : energy values on the detector for every pixels
;KEYWORD
;plot        : visualise some plots
;------------------------------------------------------------------------------

;variable initialisation
  
  radius=[1,1,sqrt(randomu(systime(1),source.nofphot+1))]*(source.radius)
  angle=[!pi*0.2,-!pi*0.2,randomu(systime(1)+1,source.nofphot+1)*2*!pi]
  xp=radius[*]*cos(angle[*])
  yp=radius[*]*sin(angle[*])
  photenergy=dblarr(source.nofphot)+source.energy
  pos=dblarr(source.nofphot,3)
  maskhit=dblarr(source.nofphot,2)
  maskpix=lonarr(source.nofphot,2)
  refpos=dblarr(2,3)
  denom=dblarr(3)
 
; sphrical to cartesian  
  if source.postype eq 1 then begin
     r=source.pos[0]
     theta=source.pos[1]*!pi
     phi=source.pos[2]*!pi
     source.pos[0]=r*sin(theta)*cos(phi)
     source.pos[1]=r*sin(theta)*sin(phi)
     source.pos[2]=r*cos(theta)
  endif

; direction
  case source.dirtype of
     0 : begin
        
     end
     1 : begin
        source.angle[0]=!pi*0.5-theta+source.angle[0]
        source.angle[1]=!pi+phi+source.angle[1]
        denom[0]=source.pos[0]
        denom[1]=source.pos[1]
        denom[2]=source.pos[2]
     end
     2 : begin
        source.angle[0]=!pi*0.5-atan(sqrt(source.pos[0]^2+source.pos[1]^2)/ $
                                     (source.pos[2]-detector.z))+ $
                        source.angle[0]
        source.angle[1]=!pi+phi+source.angle[1]
        denom[0]=source.pos[0]
        denom[1]=source.pos[1]
        denom[2]=source.pos[2]-detector.z
     end
  endcase  

;cartesian coordinates calculation
  for i=0,source.nofphot-1 do begin
     pos[i,0] = +xp[i+2]*sin(source.angle[1])+ $
                yp[i+2]*sin(source.angle[0])*cos(source.angle[1])+source.pos[0]
     pos[i,1] = -xp[i+2]*cos(source.angle[1])+ $
                yp[i+2]*sin(source.angle[0])*sin(source.angle[1])+source.pos[1]
     pos[i,2] = yp[i+2]*cos(source.angle[0])+source.pos[2]
  endfor

;mask hit positions and pixels are written z=0
  for i=0,source.nofphot-1 do begin
     maskhit[i,0]= -(denom[0]/denom[2])*pos[i,2]+pos[i,0]
     maskhit[i,1]= -(denom[1]/denom[2])*pos[i,2]+pos[i,1]
     maskpix[i,0]=where(maskhit[i,0] lt mask.pos[*,0,0]+mask.pixsize*0.5 and $
                maskhit[i,0] gt mask.pos[*,0,0]-mask.pixsize*0.5)
     maskpix[i,1]=where(maskhit[i,1] lt mask.pos[0,*,1]+mask.pixsize*0.5 and $
                maskhit[i,1] gt mask.pos[0,*,1]-mask.pixsize*0.5)               
  endfor

  inmask=where(maskhit[*,0] ne -1 and maskhit[*,1] ne -1)
  source.nofphot=n_elements(inmask)
  dethit=dblarr(source.nofphot,2)
  
;detector hit positions and energy distributed to pixels are calculated
  for i=0,source.nofphot-1 do begin
     dethit[i,0]=((denom[0]/denom[2])* $
                  (-pos[inmask[i],2]+detector.z)+pos[inmask[i],0])* $
                 mask.apert[maskpix[inmask[i],0],maskpix[inmask[i],1]]
     dethit[i,1]=((denom[1]/denom[2])* $
                  (-pos[inmask[i],2]+detector.z)+pos[inmask[i],1])* $
                 mask.apert[maskpix[inmask[i],0],maskpix[inmask[i],1]]

     if mask.apert[maskpix[inmask[i],0],maskpix[inmask[i],1]] gt 0 then begin
        ndx=where(dethit[i,0] le detector.pos[*,0,0]+detector.pixsize*0.5 and $
                  dethit[i,0] ge detector.pos[*,0,0]-detector.pixsize*0.5)
        ndy=where(dethit[i,1] le detector.pos[0,*,1]+detector.pixsize*0.5 and $
                  dethit[i,1] ge detector.pos[0,*,1]-detector.pixsize*0.5)
        if ndx[0] ne -1 and ndy[0] ne -1 then $
        detector.pixenergy[ndx[0],ndy[0]]=detector.pixenergy[ndx[0],ndy[0]]+ $
                                    photenergy[inmask[i]]
     endif
     ;stop

  endfor

  ;output value 
  pixenergy=detector.pixenergy
  aperture=mask.apert
  image=double(convol(long(aperture),long(pixenergy)))

  ;plotting image
  if keyword_set(plot) then begin
     window,0,xsize=1200,ysize=600
     !p.multi=[0,4,2]
     contour,(image/max(image))^1,nlevel=100,/fill,xr=[15,65],yr=[15,65]
     contour,(image/max(image))^41,nlevel=100,/fill,xr=[15,65],yr=[15,65]
     contour,(image/max(image))^301,nlevel=100,/fill,xr=[15,65],yr=[15,65]
     surface,(image/max(image))^1
     contour,detector.pixenergy,nlevel=100,/fill
     range=[-sqrt(n_elements(mask.apert))*mask.pixsize, $
            sqrt(n_elements(mask.apert))*mask.pixsize]
     plot,dethit[*,0],dethit[*,1],psym=3,xr=range,yr=range
     plot,maskhit[*,0],maskhit[*,1],psym=3,xr=range,yr=range,color=1000
     getmask,[1,1],73,/plot,pixsize=mask.pixsize
     plot,radius*cos(angle),radius*sin(angle),psym=3
     
  endif

end
;******************************************************************************
