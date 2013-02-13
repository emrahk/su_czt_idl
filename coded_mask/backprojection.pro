pro backprojection,data
  
  getmask,[2,2],37,mask,pixsize=1.2
  getpixenergy,data,pixenergy
  pe = pixenergy
  apert = mask.apert[1:73,1:73]
  apert[where(apert eq 0)] = 1.
  apert[where(apert eq 255)] = 0
  apert[36,36] = 0
  apert = rotate(apert,1)
  
  maskpos = (findgen(73)-36)*1.2
  decpos = (findgen(34)-16.5)*1.2
  skydata = create_struct('pos',dblarr(2),'ener',dblarr(1))
  skydata = replicate(skydata,74*74*34*34)
  
  for i = 0 , 33 do begin
    for j = 0 , 33 do begin
      for k = 0 , 73 do begin
        for l = 0 , 73 do begin
          ndx = i*34*74*74 + j*74*74 + k*74 + l
          skydata[ndx].ener = apert[k,l]*pe[i,j]
          skydata[ndx].pos[0] = decpos[i] + maskpos[k]*30050/50.
          skydata[ndx].pos[1] = decpos[j] + maskpos[l]*30050/50.
        endfor 
      endfor
    endfor
  endfor
  
  skydata = skydata[where(skydata.ener ne 0)]
  reflen = 1.2*30050/50.
  refarea = reflen*reflen  
    
  imginfo = create_struct('pos',[0.,0.],'xbin',100.,'ybin',100.,'pixsize',10.)
  halfx = imginfo.xbin*pixsize/2
  halfy = imginfo.ybin*pixsize/2
  xbin = imginfo.xbin
  ybin = imginfo.ybin
  pixarea = imginfo.pixsize^2
  img = dblarr(imginfo.xbin,imginfo.ybin)
  
  inside = bytarr(n_elements(skydata.ener),4)
  
  for i = 0, n_elements(skydata.ener) - 1 do begin
    xmp = [skydata[i].pos[0]-reflen/2,skydata[i].pos[0]+reflen/2]
    ymp = [skydata[i].pos[1]-reflen/2,skydata[i].pos[1]+reflen/2]
    if xmp[0] lt halfx and xmp[0] gt -halfx $
       ymp[0] lt halfy and ymp[0] gt -halfy then inside[i,0] = 1
    if xmp[1] lt halfx and xmp[1] gt -halfx $
       ymp[0] lt halfy and ymp[0] gt -halfy then inside[i,1] = 1
    if xmp[1] lt halfx and xmp[1] gt -halfx $
       ymp[1] lt halfy and ymp[1] gt -halfy then inside[i,2] = 1
    if xmp[0] lt halfx and xmp[0] gt -halfx $
       ymp[1] lt halfy and ymp[1] gt -halfy then inside[i,3] = 1
  endfor 
  
  for i = 0, n_elements(inside[*,0])-1 do begin
    ndx = where(inside[i,*] eq 1) 
    cnt = n_elements(ndx)
    
    case cnt of
      1 : begin
            if ndx[0] eq 1 then begin
              xmp = [skydata[i].pos[0]-reflen/2,skydata[i].pos[0]+reflen/2] + halfx
              ymp = [skydata[i].pos[1]-reflen/2,skydata[i].pos[1]+reflen/2] + halfy
              xfill = long((xmp[1])/imginfo.pixsize) + 1
              yfill = long((ymp[1])/imginfo.pixsize) + 1
              img[xfill:xbin,yfill:ybin] = img[xfill:xbin,yfill:ybin] + skydata[i].ener*pixarea/refarea
              img[xfill-1,yfill:ybin] = img[xfill-1,yfill:ybin] + skydata[i].ener*(imginfo.pixsize*(-xmp[1]+imginfo.pixsize*xfill))/refarea 
              img[xfill:xbin,yfill-1] = img[xfill:bin,yfill-1] + skydata[i].ener*(imginfo.pixsize*(-ymp[1]+imginfo.pixsize*yfill))/refarea
              img[xfill-1,yfill-1] = img[xfill-1,yfill-1] + skydata[i].ener*((ymp[1]-imginfo.pixsize*yfill)*(xmp[1]-imginfo.pixsize*xfill))/refarea  
            endif
            if ndx[1] eq 1 then begin
              xmp = [skydata[i].pos[0]-reflen/2,skydata[i].pos[0]+reflen/2] + halfx
              ymp = [skydata[i].pos[1]-reflen/2,skydata[i].pos[1]+reflen/2] + halfy
              xfill = long((xmp[1])/imginfo.pixsize) - 1
              yfill = long((ymp[1])/imginfo.pixsize) + 1
              img[0:xfill,yfill:ybin] = img[0:xfill,yfill:ybin] + skydata[i].ener*pixarea/refarea
              img[xfill+1,yfill:ybin] = img[xfill+1,yfill:ybin] + skydata[i].ener*(imginfo.pixsize*(xmp[1]-imginfo.pixsize*xfill))/refarea 
              img[0:xfill,yfill-1] = img[0:xfill,yfill-1] + skydata[i].ener*(imginfo.pixsize*(-ymp[1]+imginfo.pixsize*yfill))/refarea
              img[xfill+1,yfill-1] = img[xfill+1,yfill-1] + skydata[i].ener*((-ymp[1]+imginfo.pixsize*yfill)*(xmp[1]-imginfo.pixsize*xfill))/refarea  
            endif
            if ndx[2] eq 1 then begin
              xmp = [skydata[i].pos[0]-reflen/2,skydata[i].pos[0]+reflen/2] + halfx
              ymp = [skydata[i].pos[1]-reflen/2,skydata[i].pos[1]+reflen/2] + halfy
              xfill = long((xmp[1])/imginfo.pixsize) - 1 
              yfill = long((ymp[1])/imginfo.pixsize) - 1
              img[0:xfill,0:yfill] = img[0:xfill,0:yfill] + skydata[i].ener*pixarea/refarea
              img[xfill+1,0:yfill] = img[xfill+1,0:yfill] + skydata[i].ener*(imginfo.pixsize*(xmp[1]-imginfo.pixsize*xfill))/refarea 
              img[0:xfill,yfill+1] = img[0:xfill,yfill+1] + skydata[i].ener*(imginfo.pixsize*(ymp[1]-imginfo.pixsize*yfill))/refarea
              img[xfill+1,yfill+1] = img[xfill+1,yfill+1] + skydata[i].ener*((ymp[1]-imginfo.pixsize*yfill)*(xmp[1]-imginfo.pixsize*xfill))/refarea  
            endif        
            if ndx[3] eq 1 then begin
              xmp = [skydata[i].pos[0]-reflen/2,skydata[i].pos[0]+reflen/2] + halfx
              ymp = [skydata[i].pos[1]-reflen/2,skydata[i].pos[1]+reflen/2] + halfy
              xfill = long((xmp[1])/imginfo.pixsize) + 1 
              yfill = long((ymp[1])/imginfo.pixsize) - 1
              img[xfill:xbin,0:yfill] = img[xfill:xbin,0:yfill] + skydata[i].ener*pixarea/refarea
              img[xfill-1,0:yfill] = img[xfill-1,0:yfill] + skydata[i].ener*(imginfo.pixsize*(-xmp[1]+imginfo.pixsize*xfill))/refarea 
              img[xfill:xbin,yfill+1] = img[xfill:xbin,yfill+1] + skydata[i].ener*(imginfo.pixsize*(ymp[1]-imginfo.pixsize*yfill))/refarea
              img[xfill:xbin,yfill+1] = img[xfill:xbin,yfill+1] + skydata[i].ener*((ymp[1]-imginfo.pixsize*yfill)*(-xmp[1]+imginfo.pixsize*xfill))/refarea  
            endif
      
          end
      
      2 : begin
             
          end
    
      3 : begin 
          
          end
    
    endcase
    
  endfor

end
