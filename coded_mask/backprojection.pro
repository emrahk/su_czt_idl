pro backprojection,data,img,pixenergy
  
  getmask,[2,2],37,mask,pixsize=1.2
;  getpixenergy,data,pixenergy
  pe = pixenergy
  apert = mask.apert[1:73,1:73]
  apert[where(apert eq 0)] = 1.
  apert[where(apert eq 255)] = 0
  apert[36,36] = 0
  apert = rotate(apert,1)
  
  maskpos = (findgen(73)-36)*1.2
  decpos = (findgen(34)-16.5)*1.2
  skydata = create_struct('pos',dblarr(2),'ener',0.)
  skydata = replicate(skydata,73.*73*34*34)
  
  for i = 0 ,33 do begin
    for j = 0 , 33 do begin
      for k = 0 , 72 do begin
        for l = 0 , 72 do begin
          ndx = i*34.*73*73 + j*73.*73 + k*73. + l
          skydata[ndx].ener = apert[k,l]*pe[i,j]
          skydata[ndx].pos[0] = decpos[i] + (maskpos[k]-decpos[i])*30050/50.
          skydata[ndx].pos[1] = decpos[j] + (maskpos[l]-decpos[j])*30050/50.
        endfor 
      endfor
    endfor
  endfor
  
  skydata = skydata[where(skydata.ener ne 0)]
  reflen = 1.2*30050/50.
  refarea = reflen*reflen  
    
  imginfo = create_struct('pos',[0.,0.],'xbin',80.,'ybin',80.,'pixsize',200.)
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
    if ndx[0] ne -1 then count = n_elements(ndx) else count = -1
    
    case count of
      1 : begin
;            if inside[i,0] eq 1 then begin
;              xmp = [skydata[i].pos[0]-reflen/2,skydata[i].pos[0]+reflen/2] + halfx
;              ymp = [skydata[i].pos[1]-reflen/2,skydata[i].pos[1]+reflen/2] + halfy
;              xfill = long((xmp[0])/imginfo.pixsize) + 1
;              yfill = long((ymp[0])/imginfo.pixsize) + 1
;              img[xfill:xbin,yfill:ybin] = img[xfill:xbin,yfill:ybin] + skydata[i].ener*pixarea/refarea
;              img[xfill-1,yfill:ybin] = img[xfill-1,yfill:ybin] + skydata[i].ener*(imginfo.pixsize*(-xmp[0]+imginfo.pixsize*xfill))/refarea 
;              img[xfill:xbin,yfill-1] = img[xfill:xbin,yfill-1] + skydata[i].ener*(imginfo.pixsize*(-ymp[0]+imginfo.pixsize*yfill))/refarea
;              img[xfill-1,yfill-1] = img[xfill-1,yfill-1] + skydata[i].ener*((ymp[0]-imginfo.pixsize*yfill)*(xmp[0]-imginfo.pixsize*xfill))/refarea  
;            endif
;            if inside[i,1] eq 1 then begin
;              xmp = [skydata[i].pos[0]-reflen/2,skydata[i].pos[0]+reflen/2] + halfx
;              ymp = [skydata[i].pos[1]-reflen/2,skydata[i].pos[1]+reflen/2] + halfy
;              xfill = long((xmp[1])/imginfo.pixsize) - 1
;              yfill = long((ymp[0])/imginfo.pixsize) + 1
;              img[0:xfill,yfill:ybin] = img[0:xfill,yfill:ybin] + skydata[i].ener*pixarea/refarea
;              img[xfill+1,yfill:ybin] = img[xfill+1,yfill:ybin] + skydata[i].ener*(imginfo.pixsize*(xmp[1]-imginfo.pixsize*xfill))/refarea 
;              img[0:xfill,yfill-1] = img[0:xfill,yfill-1] + skydata[i].ener*(imginfo.pixsize*(-ymp[0]+imginfo.pixsize*yfill))/refarea
;              img[xfill+1,yfill-1] = img[xfill+1,yfill-1] + skydata[i].ener*((-ymp[0]+imginfo.pixsize*yfill)*(xmp[1]-imginfo.pixsize*xfill))/refarea  
;            endif
;            if inside[i,2] eq 1 then begin
;              xmp = [skydata[i].pos[0]-reflen/2,skydata[i].pos[0]+reflen/2] + halfx
;              ymp = [skydata[i].pos[1]-reflen/2,skydata[i].pos[1]+reflen/2] + halfy
;              xfill = long((xmp[1])/imginfo.pixsize) - 1 
;              yfill = long((ymp[1])/imginfo.pixsize) - 1
;              img[0:xfill,0:yfill] = img[0:xfill,0:yfill] + skydata[i].ener*pixarea/refarea
;              img[xfill+1,0:yfill] = img[xfill+1,0:yfill] + skydata[i].ener*(imginfo.pixsize*(xmp[1]-imginfo.pixsize*xfill))/refarea 
;              img[0:xfill,yfill+1] = img[0:xfill,yfill+1] + skydata[i].ener*(imginfo.pixsize*(ymp[1]-imginfo.pixsize*yfill))/refarea
;              img[xfill+1,yfill+1] = img[xfill+1,yfill+1] + skydata[i].ener*((ymp[1]-imginfo.pixsize*yfill)*(xmp[1]-imginfo.pixsize*xfill))/refarea  
;            endif        
;            if inside[i,3] eq 1 then begin
;              xmp = [skydata[i].pos[0]-reflen/2,skydata[i].pos[0]+reflen/2] + halfx
;              ymp = [skydata[i].pos[1]-reflen/2,skydata[i].pos[1]+reflen/2] + halfy
;              xfill = long((xmp[0])/imginfo.pixsize) + 1 
;              yfill = long((ymp[1])/imginfo.pixsize) - 1
;              img[xfill:xbin,0:yfill] = img[xfill:xbin,0:yfill] + skydata[i].ener*pixarea/refarea
;              img[xfill-1,0:yfill] = img[xfill-1,0:yfill] + skydata[i].ener*(imginfo.pixsize*(-xmp[0]+imginfo.pixsize*xfill))/refarea 
;              img[xfill:xbin,yfill+1] = img[xfill:xbin,yfill+1] + skydata[i].ener*(imginfo.pixsize*(ymp[1]-imginfo.pixsize*yfill))/refarea
;              img[xfill:xbin,yfill+1] = img[xfill:xbin,yfill+1] + skydata[i].ener*((ymp[1]-imginfo.pixsize*yfill)*(-xmp[0]+imginfo.pixsize*xfill))/refarea  
;            endif
      
          end
      
      2 : begin
;            if inside[i,0] eq 1 and inside[i,1] eq 1 then begin
;              xmp = [skydata[i].pos[0]-reflen/2,skydata[i].pos[0]+reflen/2] + halfx
;              ymp = [skydata[i].pos[1]-reflen/2,skydata[i].pos[1]+reflen/2] + halfy
;              xfill = [long((xmp[0])/imginfo.pixsize) + 1,long((xmp[1])/imginfo.pixsize) - 1]
;              yfill = long((ymp[0])/imginfo.pixsize) + 1
;              img[xfill[0]:xfill[1],yfill:ybin] = img[xfill[0]:xfill[1],yfill:ybin] + skydata[i].ener*pixarea/refarea
;              img[xfill[0]-1,yfill:ybin] = img[xfill[0]-1,yfill:ybin] + skydata[i].ener*imginfo.pixsize*(-xmp[0]+imginfo.pixsize*xfill[0])/refarea
;              img[xfill[1]+1,yfill:ybin] = img[xfill[1]+1,yfill:ybin] + skydata[i].ener*imginfo.pixsize*(xmp[1]-imginfo.pixsize*xfill[1])/refarea
;              img[xfill[0]:xfill[1],yfill-1] = img[xfill[0]:xfill[1],yfill-1] + skydata[i].ener*imginfo.pixsize*(-ymp[0]+imginfo.pixsize*yfill)/refarea
;              img[xfill[0]-1,yfill-1] = img[xfill[0]-1,yfill-1] + skydata[i].ener*(-ymp[0]+imginfo.pixsize*yfill)*(-xmp[0]+imginfo.pixsize*xfill[0])/refarea
;              img[xfill[1]+1,yfill-1] = img[xfill[1]+1,yfill-1] + skydata[i].ener*(-ymp[0]+imginfo.pixsize*yfill)*(xmp[1]-imginfo.pixsize*xfill[1])/refarea
;            endif
;            if inside[i,1] eq 1 and inside[i,2] eq 1 then begin
;              xmp = [skydata[i].pos[0]-reflen/2,skydata[i].pos[0]+reflen/2] + halfx
;              ymp = [skydata[i].pos[1]-reflen/2,skydata[i].pos[1]+reflen/2] + halfy
;              xfill = long((xmp[1])/imginfo.pixsize) - 1
;              yfill = [long((ymp[0])/imginfo.pixsize) + 1,long((ymp[1])/imginfo.pixsize) - 1]
;              img[0:xfill,yfill[0]:yfill[1]] = img[0:xfill,yfill[0]:yfill[1]] + skydata[i].ener*pixarea/refarea
;              img[0:xfill,yfill[0]-1] = img[0:xfill,yfill[0]-1] + skydata[i].ener*imginfo.pixsize*(-ymp[0]+imginfo.pixsize*yfill[0])/refarea 
;              img[0:xfill,yfill[1]+1] = img[0:xfill,yfill[1]+1] + skydata[i].ener*imginfo.pixsize*(ymp[1]-imginfo.pixsize*yfill[1])/refarea
;              img[xfill+1,yfill[0]:yfill[1]] = img[xfill+1,yfill[0]:yfill[1]] + skydata[i].ener*imginfo.pixsize*(xmp[1]-imginfo.pixsize*xfill)/refarea 
;              img[xfill+1,yfill[0]-1] = img[xfill+1,yfill[0]-1] + skydata[i].ener*(xmp[1]-imginfo.pixsize*xfill)*(-ymp[0]+imginfo.pixsize*yfill[0])/refarea 
;              img[xfill+1,yfill[1]+1] = img[xfill+1,yfill[1]+1] + skydata[i].ener*(xmp[1]-imginfo.pixsize*xfill)*(ymp[1]-imginfo.pixsize*yfill[1])/refarea
;            endif
;            if inside[i,2] eq 1 and inside[i,3] eq 1 then begin
;              xmp = [skydata[i].pos[0]-reflen/2,skydata[i].pos[0]+reflen/2] + halfx
;              ymp = [skydata[i].pos[1]-reflen/2,skydata[i].pos[1]+reflen/2] + halfy
;              xfill = [long((xmp[0])/imginfo.pixsize) + 1,long((xmp[1]/imginfo.pixsize)) - 1]
;              yfill = long((ymp[1])/imginfo.pixsize) - 1 
;              img[xfill[0]:xfill[1],0:yfill] = img[xfill[0]:xfill[1],0:yfill] + skydata[i].ener*pixarea/refarea
;              img[xfill[0]-1,0:yfill] = img[xfill[0]-1,0:yfill] + skydata[i].ener*imginfo.pixsize*(-xmp[0]+imginfo.pixsize*xfill[0])/refarea 
;              img[xfill[1]+1,0:yfill] = img[xfill[1]+1,0:yfill] + skydata[i].ener*imginfo.pixsize*(xmp[1]-imginfo.pixsize*xfill[1])/refarea
;              img[xfill[0]:xfill[1],yfill+1] = img[xfill[0]:xfill[1],yfill+1] + skydata[i].ener*imginfo.pixsize*(ymp[1]-imginfo.pixsize*yfill)/refarea
;              img[xfill[0]-1,yfill+1] = img[xfill[0]-1,yfill+1] + skydata[i].ener*(ymp[1]-imginfo.pixsize*yfill)*(-xmp[0]+imginfo.pixsize*xfill[0])/refarea
;              img[xfill[1]+1,yfill+1] = img[xfill[1]+1,yfill+1] + skydata[i].ener*(ymp[1]-imginfo.pixsize*yfill)*(xmp[1]-imginfo.pixsize*xfill[1])/refarea
;            endif
;            if inside[i,3] eq 1 and inside[i,0] eq 1 then begin          
;              xmp = [skydata[i].pos[0]-reflen/2,skydata[i].pos[0]+reflen/2] + halfx
;              ymp = [skydata[i].pos[1]-reflen/2,skydata[i].pos[1]+reflen/2] + halfy
;              xfill = long((xmp[0])/imginfo.pixsize) + 1
;              yfill = [long((ymp[0])/imginfo.pixsize) + 1,long((ymp[1])/imginfo.pixsize) - 1]
;              img[xfill:xbin,yfill[0]:yfill[1]] = img[xfill:xbin,yfill[0]:yfill[1]] + skydata[i].ener*pixarea/refarea
;              img[xfill:xbin,yfill[0]-1] = img[xfill:xbin,yfill[0]-1] + skydata[i].ener*imginfo.pixsize*(-ymp[0]+imginfo.pixsize*yfill[0])/refarea
;              img[xfill:xbin,yfill[1]+1] = img[xfill:xbin,yfill[1]+1] + skydata[i].ener*imginfo.pixsize*(ymp[1]-imginfo.pixsize*yfill[1])/refarea
;              img[xfill-1,yfill[0]:yfill[1]] = img[xfill-1,yfill[0]:yfill[1]] + skydata[i].ener*imginfo.pixsize*(-xmp[0]+imginfo.pixsize*xfill)/refarea
;              img[xfill-1,yfill[0]-1] = img[xfill-1,yfill[0]-1] + skydata[i].ener*(-xmp[0]+imginfo.pixsize*xfill)*(-ymp[0]+imginfo.pixsize*yfill[0])/refarea
;              img[xfill-1,yfill[1]+1] = img[xfill-1,yfill[1]+1] + skydata[i].ener*(xmp[1]-imginfo.pixsize*xfill)*(ymp[1]-imginfo.pixsize*yfill[0])/refarea
;            endif
          end
    
      4 : begin 
            xmp = [skydata[i].pos[0]-reflen/2,skydata[i].pos[0]+reflen/2] + halfx
            ymp = [skydata[i].pos[1]-reflen/2,skydata[i].pos[1]+reflen/2] + halfy
            xfill = [long((xmp[0])/imginfo.pixsize) + 1,long((xmp[1])/imginfo.pixsize) - 1]
            yfill = [long((ymp[0])/imginfo.pixsize) + 1,long((ymp[1])/imginfo.pixsize) - 1]
            img[xfill[0]:xfill[1],yfill[0]:yfill[1]] = img[xfill[0]:xfill[1],yfill[0]:yfill[1]] + skydata[i].ener*pixarea/refarea
            img[xfill[0]-1,yfill[0]:yfill[1]] = img[xfill[0]-1,yfill[0]:yfill[1]] + skydata[i].ener*imginfo.pixsize*(-xmp[0]+imginfo.pixsize*xfill[0])/refarea
            img[xfill[1]+1,yfill[0]:yfill[1]] = img[xfill[1]+1,yfill[0]:yfill[1]] + skydata[i].ener*imginfo.pixsize*(xmp[1]-imginfo.pixsize*(xfill[1]+1))/refarea
            img[xfill[0]:xfill[1],yfill[0]-1] = img[xfill[0]:xfill[1],yfill[0]-1] + skydata[i].ener*imginfo.pixsize*(-ymp[0]+imginfo.pixsize*yfill[0])/refarea
            img[xfill[0]:xfill[1],yfill[1]+1] = img[xfill[0]:xfill[1],yfill[1]+1] + skydata[i].ener*imginfo.pixsize*(ymp[1]-imginfo.pixsize*(yfill[1]+1))/refarea
            img[xfill[0]-1,yfill[0]-1] = img[xfill[0]-1,yfill[0]-1] + skydata[i].ener*(-xmp[0]+imginfo.pixsize*xfill[0])*(-ymp[0]+imginfo.pixsize*yfill[0])/refarea
            img[xfill[0]-1,yfill[1]+1] = img[xfill[0]-1,yfill[1]+1] + skydata[i].ener*(-xmp[0]+imginfo.pixsize*xfill[0])*(ymp[1]-imginfo.pixsize*(yfill[1]+1))/refarea
            img[xfill[1]+1,yfill[0]-1] = img[xfill[1]+1,yfill[0]-1] + skydata[i].ener*(xmp[1]-imginfo.pixsize*(xfill[1]+1))*(-ymp[0]+imginfo.pixsize*yfill[0])/refarea
            img[xfill[1]+1,yfill[1]+1] = img[xfill[1]+1,yfill[1]+1] + skydata[i].ener*(xmp[1]-imginfo.pixsize*(xfill[1]+1))*(ymp[1]-imginfo.pixsize*(yfill[1]+1))/refarea
          end
          
      -1: begin 
          
          end  
    endcase
    
  endfor

end
