pro backprojection2,data,img,pixenergy
  
  getmask,[2,2],37,mask,pixsize=1.2
  getpixenergy,data,pixenergy
  pe = pixenergy
  md = 4
  dd = 1
  apert = mask.apert[1:73,1:73]
  apert[where(apert eq 0)] = 1.
  apert[where(apert eq 255)] = 0
  apert[36,36] = 0
  apert = rotate(apert,1)
  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  apert = congrid(apert,73*md,73*md)
  pe = rebin(pe,34*dd,34*dd)
  
  maskpos = (findgen(73*md)-36*md)*1.2/md
  decpos = (findgen(34*dd)-16.5*dd)*1.2/dd
  skydata = create_struct('pos',dblarr(2),'ener',0.)
  skydata = replicate(skydata,34*dd,34*dd,73*md,73*md)
  
  for i = 0 ,34*dd-1 do begin
    for j = 0 , 34*dd-1 do begin
      for k = 0 , 73*md-1 do begin
        for l = 0 , 73*md-1 do begin
        
          skydata[i,j,k,l].ener = apert[k,l]*pe[i,j]
          skydata[i,j,k,l].pos[0] = decpos[i] + (maskpos[k]-decpos[i])*30000/50.
          skydata[i,j,k,l].pos[1] = decpos[j] + (maskpos[l]-decpos[j])*30000/50.
        endfor 
      endfor
    endfor
  endfor
  
  skydata = skydata[where(skydata.ener ne 0)]
  reflen = 1.2*30050/50.
  refarea = reflen*reflen  
    
  imginfo = create_struct('pos',[0.,0.],'xbin',88.*2,'ybin',88.*2,'pixsize',90.)
  halfx = imginfo.xbin*imginfo.pixsize/2
  halfy = imginfo.ybin*imginfo.pixsize/2
  xbin = imginfo.xbin - 1
  ybin = imginfo.ybin - 1
  pixarea = imginfo.pixsize^2
  img = dblarr(imginfo.xbin,imginfo.ybin)
  
  inside = bytarr(n_elements(skydata.ener),4)
  
  for i = 0, n_elements(skydata.ener) - 1 do begin
    xmp = [skydata[i].pos[0]-reflen/2,skydata[i].pos[0]+reflen/2]
    ymp = [skydata[i].pos[1]-reflen/2,skydata[i].pos[1]+reflen/2]
    if xmp[0] lt halfx and xmp[0] gt -halfx and $
       ymp[0] lt halfy and ymp[0] gt -halfy then inside[i,0] = 1
    if xmp[1] lt halfx and xmp[1] gt -halfx and $
       ymp[0] lt halfy and ymp[0] gt -halfy then inside[i,1] = 1
    if xmp[1] lt halfx and xmp[1] gt -halfx and $
       ymp[1] lt halfy and ymp[1] gt -halfy then inside[i,2] = 1
    if xmp[0] lt halfx and xmp[0] gt -halfx and $
       ymp[1] lt halfy and ymp[1] gt -halfy then inside[i,3] = 1
  endfor 
  
  for i = 0, n_elements(inside[*,0])-1 do begin
    ndx = where(inside[i,*] eq 1) 
    cnt = n_elements(ndx)
    if cnt eq 4 then begin
      xmp = [skydata[i].pos[0]-reflen/2,skydata[i].pos[0]+reflen/2] + halfx
      ymp = [skydata[i].pos[1]-reflen/2,skydata[i].pos[1]+reflen/2] + halfy
      xfill = [long((xmp[0])/imginfo.pixsize) + 1,long((xmp[1])/imginfo.pixsize) - 1]
      yfill = [long((ymp[0])/imginfo.pixsize) + 1,long((ymp[1])/imginfo.pixsize) - 1]
      ;if xmp[1]/imginfo.pixsize mod 1 eq 0 then xfill[1] = xfill[1] - 1
      ;if ymp[1]/imginfo.pixsize mod 1 eq 0 then yfill[1] = yfill[1] - 1
      img[xfill[0]:xfill[1],yfill[0]:yfill[1]] = img[xfill[0]:xfill[1],yfill[0]:yfill[1]] + skydata[i].ener*pixarea/refarea
      img[xfill[0]-1,yfill[0]:yfill[1]] = img[xfill[0]-1,yfill[0]:yfill[1]] + skydata[i].ener*imginfo.pixsize*(-xmp[0]+imginfo.pixsize*xfill[0])/refarea
      img[xfill[1]+1,yfill[0]:yfill[1]] = img[xfill[1]+1,yfill[0]:yfill[1]] + skydata[i].ener*imginfo.pixsize*(xmp[1]-imginfo.pixsize*(xfill[1]+1))/refarea
      img[xfill[0]:xfill[1],yfill[0]-1] = img[xfill[0]:xfill[1],yfill[0]-1] + skydata[i].ener*imginfo.pixsize*(-ymp[0]+imginfo.pixsize*yfill[0])/refarea
      img[xfill[0]:xfill[1],yfill[1]+1] = img[xfill[0]:xfill[1],yfill[1]+1] + skydata[i].ener*imginfo.pixsize*(ymp[1]-imginfo.pixsize*(yfill[1]+1))/refarea
      img[xfill[0]-1,yfill[0]-1] = img[xfill[0]-1,yfill[0]-1] + skydata[i].ener*(-xmp[0]+imginfo.pixsize*xfill[0])*(-ymp[0]+imginfo.pixsize*yfill[0])/refarea
      img[xfill[0]-1,yfill[1]+1] = img[xfill[0]-1,yfill[1]+1] + skydata[i].ener*(-xmp[0]+imginfo.pixsize*xfill[0])*(ymp[1]-imginfo.pixsize*(yfill[1]+1))/refarea
      img[xfill[1]+1,yfill[0]-1] = img[xfill[1]+1,yfill[0]-1] + skydata[i].ener*(xmp[1]-imginfo.pixsize*(xfill[1]+1))*(-ymp[0]+imginfo.pixsize*yfill[0])/refarea
      img[xfill[1]+1,yfill[1]+1] = img[xfill[1]+1,yfill[1]+1] + skydata[i].ener*(xmp[1]-imginfo.pixsize*(xfill[1]+1))*(ymp[1]-imginfo.pixsize*(yfill[1]+1))/refarea
    endif    
  endfor

end
