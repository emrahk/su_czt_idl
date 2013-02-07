pro spectrum,energy,data

openr,1,'gammadata.bin'
n=fstat(1)
count=n.size/8

data=dblarr(count)
energy = dblarr(2,140)

FOR i=0,count-1 DO BEGIN

  data[i]=read_binary(1,data_type=5,data_dims=1)
  ;energy[floor(data[i])] = energy[floor(data[i])] + 1
  energy[floor(data[i]*1000)] = energy[floor(data[i]*1000)] + 1

ENDFOR

close,1


end

