;*****************************************************************
; returns backprojected sky image
;-----------------------------------------------------------------
pro backprojection2,data,img,opix=pixenergy
;-----------------------------------------------------------------
; Yigit Dallilar  16.02.2013
;
; Under construction
;-----------------------------------------------------------------  
  
  if not keyword_set(pixenergy) then convolvewithmask,data,im,estpos,pixenergy else convolvewithmask,data,im,estpos,pixenergy,opix=pixenergy
  imginfo = create_struct('pos',[estpos[0],estpos[1]],'xbin',150.,'ybin',150.,'pixsize',50.,'dist',30000.)
  md = 1  ;divides mask pixels
  dd = 10  ;divides dedector pixels 
  dist = 30000
  
  getmask,[2,2],37,mask,pixsize=1.2
;  getpixenergy,data,pixenergy
  pe = pixenergy
  apert = mask.apert[1:73,1:73]
  apert[where(apert eq 0)] = 1.
  apert[where(apert eq 255)] = 0
  apert[36,36] = 0
  apert = rotate(apert,1)
  apert = congrid(apert,73*md,73*md)
  pe = congrid(pe,34*dd,34*dd)
  
  halfx = imginfo.xbin*imginfo.pixsize/2
  halfy = imginfo.ybin*imginfo.pixsize/2
  pixarea = imginfo.pixsize^2
  img = dblarr(imginfo.xbin,imginfo.ybin)
  reflen = 1.2*dist/(50.*md)
  refarea = reflen*reflen  
  maskpos = (findgen(73*md)-36.5*md+0.5)*1.2/md
  decpos = (findgen(34*dd)-17*dd+0.5)*1.2/dd
  
  print,"Initialision complete..."
  sum = 0. 
  inrange = dblarr(34*dd,34*dd,2,2)
  for i = 0 , 34*dd-1 do begin
    for j = 0 , 34*dd-1 do begin
      inrange[i,j,0,0] = long((50./dist*(-halfx+imginfo.pos[0]-decpos[i])+decpos[i]+maskpos[73*md-1])*md/1.2+0.5)+1
      inrange[i,j,0,1] = long((50./dist*(halfx+imginfo.pos[0]-decpos[i])+decpos[i]+maskpos[73*md-1])*md/1.2+0.5)-1
      inrange[i,j,1,0] = long((50./dist*(-halfy+imginfo.pos[1]-decpos[j])+decpos[j]+maskpos[73*md-1])*md/1.2+0.5)+1
      inrange[i,j,1,1] = long((50./dist*(halfy+imginfo.pos[1]-decpos[j])+decpos[j]+maskpos[73*md-1])*md/1.2+0.5)-1
      if inrange[i,j,0,0] lt 0 then inrange[i,j,0,0] = 0
      if inrange[i,j,1,0] lt 0 then inrange[i,j,1,0] = 0
      if inrange[i,j,0,1] gt 73*md-1 then inrange[i,j,0,1] = 73*md-1
      if inrange[i,j,0,0] gt 73*md-1 then inrange[i,j,0,0] = 73*md-1
      sum = sum + (inrange[i,j,0,1] - inrange[i,j,0,0] + 1)*(inrange[i,j,1,1] - inrange[i,j,1,0] + 1)
    endfor
  endfor

  print,"Unnecessary mask pixels eleminated..."
;  stop

  skydata = create_struct('pos',dblarr(2),'ener',0.)
  skydata = replicate(skydata,sum)	
    
  ; sky pixels are written with given energies
  cntr = long(0)
  ratio = imginfo.dist/50.
  for i = 0 ,34*dd-1 do begin
    for j = 0 , 34*dd-1 do begin
      for k = inrange[i,j,0,0] , inrange[i,j,0,1] do begin
        for l = inrange[i,j,1,0] , inrange[i,j,1,1] do begin        
          if apert[k,l] ne 0 then begin
            skydata[cntr].ener = apert[k,l]*pe[i,j]
            skydata[cntr].pos[0] = decpos[i] + (maskpos[k]-decpos[i])*ratio
            skydata[cntr].pos[1] = decpos[j] + (maskpos[l]-decpos[j])*ratio
            cntr = cntr + 1 
          endif
        endfor 
      endfor
    endfor
  endfor
  
;  stop 
  print,"Sky data is constructed..."
  
  skydata = skydata[where(skydata.ener ne 0)]        
  inside = bytarr(n_elements(skydata.ener),4)
  
;  print,"qqqqqqqqqq"
  
  ;looks for if given positions are inside the picture
  reflenovertwo = reflen/2
;  halfxpluspos = halfx+imginfo.pos[0]
;  halfypluspos = halfy+imginfo.pos[1]
;  halfxminuspos = halfx-imginfo.pos[0]
;  halfyminuspos = halfy-imginfo.pos[1]
;  for i = 0, n_elements(skydata.ener) - 1 do begin
;    xmp = [skydata[i].pos[0]-reflenovertwo,skydata[i].pos[0]+reflenovertwo]
;    ymp = [skydata[i].pos[1]-reflenovertwo,skydata[i].pos[1]+reflenovertwo]
;    if xmp[0] lt halfxpluspos and xmp[0] gt -halfxminuspos and $
;       ymp[0] lt halfypluspos and ymp[0] gt -halfyminuspos then inside[i,0] = 1
;    if xmp[1] lt halfxpluspos and xmp[1] gt -halfxminuspos and $
;       ymp[0] lt halfypluspos and ymp[0] gt -halfyminuspos then inside[i,1] = 1
;    if xmp[1] lt halfxpluspos and xmp[1] gt -halfxminuspos and $
;       ymp[1] lt halfypluspos and ymp[1] gt -halfyminuspos then inside[i,2] = 1
;    if xmp[0] lt halfxpluspos and xmp[0] gt -halfxminuspos and $
;       ymp[1] lt halfypluspos and ymp[1] gt -halfyminuspos then inside[i,3] = 1
;  endfor 
  
;  print,"elimination of useless data..."
  
  ;writes picture array
  halfxminuspos = halfx - imginfo.pos[0]
  halfyminuspos = halfy - imginfo.pos[1]
  pixoverarea = imginfo.pixsize/refarea 
  pixareaoverarea = pixarea/refarea
  for i = 0, n_elements(skydata.ener)-1 do begin
;    ndx = where(inside[i,*] eq 1) 
;    cnt = n_elements(ndx)
;    if cnt eq 4 then begin
      xmp = [skydata[i].pos[0]-reflenovertwo,skydata[i].pos[0]+reflenovertwo] + halfxminuspos
      ymp = [skydata[i].pos[1]-reflenovertwo,skydata[i].pos[1]+reflenovertwo] + halfyminuspos
      xfill = [long((xmp[0])/imginfo.pixsize) + 1,long((xmp[1])/imginfo.pixsize) - 1]
      yfill = [long((ymp[0])/imginfo.pixsize) + 1,long((ymp[1])/imginfo.pixsize) - 1]
      img[xfill[0]:xfill[1],yfill[0]:yfill[1]] = img[xfill[0]:xfill[1],yfill[0]:yfill[1]] + skydata[i].ener*pixareaoverarea
      img[xfill[0]-1,yfill[0]:yfill[1]] = img[xfill[0]-1,yfill[0]:yfill[1]] + skydata[i].ener*pixoverarea*(-xmp[0]+imginfo.pixsize*xfill[0])
      img[xfill[1]+1,yfill[0]:yfill[1]] = img[xfill[1]+1,yfill[0]:yfill[1]] + skydata[i].ener*pixoverarea*(xmp[1]-imginfo.pixsize*(xfill[1]+1))
      img[xfill[0]:xfill[1],yfill[0]-1] = img[xfill[0]:xfill[1],yfill[0]-1] + skydata[i].ener*pixoverarea*(-ymp[0]+imginfo.pixsize*yfill[0])
      img[xfill[0]:xfill[1],yfill[1]+1] = img[xfill[0]:xfill[1],yfill[1]+1] + skydata[i].ener*pixoverarea*(ymp[1]-imginfo.pixsize*(yfill[1]+1))
      img[xfill[0]-1,yfill[0]-1] = img[xfill[0]-1,yfill[0]-1] + skydata[i].ener*(-xmp[0]+imginfo.pixsize*xfill[0])*(-ymp[0]+imginfo.pixsize*yfill[0])/refarea
      img[xfill[0]-1,yfill[1]+1] = img[xfill[0]-1,yfill[1]+1] + skydata[i].ener*(-xmp[0]+imginfo.pixsize*xfill[0])*(ymp[1]-imginfo.pixsize*(yfill[1]+1))/refarea
      img[xfill[1]+1,yfill[0]-1] = img[xfill[1]+1,yfill[0]-1] + skydata[i].ener*(xmp[1]-imginfo.pixsize*(xfill[1]+1))*(-ymp[0]+imginfo.pixsize*yfill[0])/refarea
      img[xfill[1]+1,yfill[1]+1] = img[xfill[1]+1,yfill[1]+1] + skydata[i].ener*(xmp[1]-imginfo.pixsize*(xfill[1]+1))*(ymp[1]-imginfo.pixsize*(yfill[1]+1))/refarea
;    endif    
  endfor

  img = img - mean(img)
  img[where (img lt 0 )] = 0
  print,"image is construted..."

end
;*****************************************************************
