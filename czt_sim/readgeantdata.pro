PRO readgeantdata,data

openr,1,'data/electron_clouds.bin'
n=fstat(1)
count=n.size/36
;numb=intarr(count)
;pos=dblarr(3,count)
;ener=dblarr(count)

data=dblarr(5,count)

FOR i=0,count-1 DO BEGIN

data[0,i]=read_binary(1,data_type=3,data_dims=1)
data[1:3,i]=read_binary(1,data_type=5,data_dims=3)
data[4,i]=read_binary(1,data_type=5,data_dims=1)

ENDFOR

close,1

END
