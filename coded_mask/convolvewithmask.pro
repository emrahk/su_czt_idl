;*****************************************************************
;convolves pixenergies with a given mask
;-----------------------------------------------------------------
pro convolvewithmask,data,image,pixenergy,mask,apert
;-----------------------------------------------------------------
;
;-----------------------------------------------------------------

  getmask,[2,2],37,mask,pixsize=1.2
  apert = mask.apert[1:73,1:73]
  apert[where(apert eq 0)] = 1
  apert[where(apert eq 255)] = 0
  apert[36,36] = 0
  apert = rotate(apert,1)
  
  maskpos = (findgen(74)-36)*1.2
  getpixenergy,data,pixenergy
  
  image = convol_fft(apert*2-1,rotate(pixenergy,2))

  image1 = convol_fft(apert*2-1,rotate(pixenergy[0:15,0:15],2))
  image2 = convol_fft(apert*2-1,rotate(pixenergy[18:33,0:15],2))
  image3 = convol_fft(apert*2-1,rotate(pixenergy[18:33,18:33],2))
  image4 = convol_fft(apert*2-1,rotate(pixenergy[0:15,18:33],2))
  window,/free,xsize=1000,ysize=250
  !p.multi=[0,4,1]
  contour,image1,/fill,nlev=20
  contour,image2,/fill,nlev=20
  contour,image3,/fill,nlev=20
  contour,image4,/fill,nlev=20
  
  ndx = where(image eq max(image))
  xndx = ndx mod 73
  yndx = ndx / 73
  posx = maskpos[xndx]*30/0.05
  posy = maskpos[yndx]*30/0.05
  print,posx,posy
  
end
;*****************************************************************
