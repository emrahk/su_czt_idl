;reads geant data from binary file
PRO readgeantdata,data

openr,1,'data.bin'
n=fstat(1)
count=n.size/44 ;one cloud has 36 bytes

data=dblarr(6,count)

FOR i=0,count-1 DO BEGIN

;data_type : 3 for integer, 5 for double
data[0,i]=read_binary(1,data_type=3,data_dims=1)
data[1:5,i]=read_binary(1,data_type=5,data_dims=5)
;data[4,i]=read_binary(1,data_type=5,data_dims=1)
;data[5,i]=read_binary(1,data_type=5,data_dims=1)

ENDFOR

close,1

END
