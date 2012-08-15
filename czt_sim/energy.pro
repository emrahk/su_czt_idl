PRO energy,num,count,ind,data,en

  ind = where(num eq 0)
  en = dblarr(n_elements(ind)-1)
  FOR i=0,count-1 DO BEGIN
     cn = ind[i+1]-ind[i]
     ener = data[4,ind[i]:ind[i+1]-1]
     sum = 0
     FOR j = 0 , cn -1 DO sum = sum + ener[j]
     en[i] = sum
  ENDFOR

  
END
