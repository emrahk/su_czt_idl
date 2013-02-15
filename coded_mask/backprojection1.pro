pro backprojection1,data,img,pixenergy
  
  getmask,[2,2],37,mask,pixsize=1.2
  getpixenergy,data,pixenergy
  pe = pixenergy
  md = 1
  apert = mask.apert[1:73,1:73]
  apert[where(apert eq 0)] = 1.
  apert[where(apert eq 255)] = 0
  apert[36,36] = 0
  apert = rotate(apert,1)
  apert = congrid(apert,73*md,73*md)  
  maskpos = (findgen(73*md)-36*md)*1.2/md
  decpos = (findgen(34)-16.5)*1.2
  ener = dblarr(34,34,73*md,73*md)
  pos = create_struct('val',dblarr(2))
  pos = replicate(pos,34,34,73*md,73*md)
  
  print, "Initialisation complete..."
   
  for i = 0 ,33 do begin
    for j = 0 , 33 do begin
      for k = 0 , 73*md-1 do begin
        for l = 0 , 73*md-1 do begin
          ener[i,j,k,l] = apert[k,l]*pe[i,j]
          pos[i,j,k,l].val[0] = decpos[i] + (maskpos[k]-decpos[i])*30000/50.
          pos[i,j,k,l].val[1] = decpos[j] + (maskpos[l]-decpos[j])*30000/50.
        endfor 
      endfor
    endfor
  endfor
  
  print,"trajectories are drawn..."
  
  ener = ener[where(ener ne 0)]
  pos = pos[where(ener ne 0)]
  reflen = 1.2*30050/50.
  refarea = reflen*reflen  
    
  imginfo = create_struct('pos',[0.,0.],'xbin',44.,'ybin',44.,'pixsize',360.)
  halfx = imginfo.xbin*imginfo.pixsize/2
  halfy = imginfo.ybin*imginfo.pixsize/2
  xbin = imginfo.xbin - 1
  ybin = imginfo.ybin - 1
  pixarea = imginfo.pixsize^2
  img = dblarr(imginfo.xbin,imginfo.ybin)
  
  inside = bytarr(n_elements(ener),4)
  
  for i = 0, n_elements(ener) - 1 do begin
    xmp = [pos[i].val[0]-reflen/2,pos[i].val[0]+reflen/2]
    ymp = [pos[i].val[1]-reflen/2,pos[i].val[1]+reflen/2]
    if xmp[0] lt halfx and xmp[0] gt -halfx and $
       ymp[0] lt halfy and ymp[0] gt -halfy then inside[i,0] = 1
    if xmp[1] lt halfx and xmp[1] gt -halfx and $
       ymp[0] lt halfy and ymp[0] gt -halfy then inside[i,1] = 1
    if xmp[1] lt halfx and xmp[1] gt -halfx and $
       ymp[1] lt halfy and ymp[1] gt -halfy then inside[i,2] = 1
    if xmp[0] lt halfx and xmp[0] gt -halfx and $
       ymp[1] lt halfy and ymp[1] gt -halfy then inside[i,3] = 1
  endfor 
  
  print,"Erased data outside of the image..."
  
  for i = 0, n_elements(inside[*,0])-1 do begin
    ndx = where(inside[i,*] eq 1) 
    cnt = n_elements(ndx)
    if cnt eq 4 then begin
      xmp = [pos[i].val[0]-reflen/2,pos[i].val[0]+reflen/2] + halfx
      ymp = [pos[i].val[1]-reflen/2,pos[i].val[1]+reflen/2] + halfy
      xfill = [long((xmp[0])/imginfo.pixsize) + 1,long((xmp[1])/imginfo.pixsize) - 1]
      yfill = [long((ymp[0])/imginfo.pixsize) + 1,long((ymp[1])/imginfo.pixsize) - 1]
      img[xfill[0]:xfill[1],yfill[0]:yfill[1]] = img[xfill[0]:xfill[1],yfill[0]:yfill[1]] + ener[i]*pixarea/refarea
      img[xfill[0]-1,yfill[0]:yfill[1]] = img[xfill[0]-1,yfill[0]:yfill[1]] + ener[i]*imginfo.pixsize*(-xmp[0]+imginfo.pixsize*xfill[0])/refarea
      img[xfill[1]+1,yfill[0]:yfill[1]] = img[xfill[1]+1,yfill[0]:yfill[1]] + ener[i]*imginfo.pixsize*(xmp[1]-imginfo.pixsize*(xfill[1]+1))/refarea
      img[xfill[0]:xfill[1],yfill[0]-1] = img[xfill[0]:xfill[1],yfill[0]-1] + ener[i]*imginfo.pixsize*(-ymp[0]+imginfo.pixsize*yfill[0])/refarea
      img[xfill[0]:xfill[1],yfill[1]+1] = img[xfill[0]:xfill[1],yfill[1]+1] + ener[i]*imginfo.pixsize*(ymp[1]-imginfo.pixsize*(yfill[1]+1))/refarea
      img[xfill[0]-1,yfill[0]-1] = img[xfill[0]-1,yfill[0]-1] + ener[i]*(-xmp[0]+imginfo.pixsize*xfill[0])*(-ymp[0]+imginfo.pixsize*yfill[0])/refarea
      img[xfill[0]-1,yfill[1]+1] = img[xfill[0]-1,yfill[1]+1] + ener[i]*(-xmp[0]+imginfo.pixsize*xfill[0])*(ymp[1]-imginfo.pixsize*(yfill[1]+1))/refarea
      img[xfill[1]+1,yfill[0]-1] = img[xfill[1]+1,yfill[0]-1] + ener[i]*(xmp[1]-imginfo.pixsize*(xfill[1]+1))*(-ymp[0]+imginfo.pixsize*yfill[0])/refarea
      img[xfill[1]+1,yfill[1]+1] = img[xfill[1]+1,yfill[1]+1] + ener[i]*(xmp[1]-imginfo.pixsize*(xfill[1]+1))*(ymp[1]-imginfo.pixsize*(yfill[1]+1))/refarea
    endif    
  endfor

  print,"Complete..."

end
