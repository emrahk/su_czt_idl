;reads geant data from binary file
PRO readgeantdata,data

  openr,1,'/data1/geant/ggg/mask_sim/bin/Linux-g++/output/data.bin'
  openr,2,'/data1/geant/ggg/mask_sim/bin/Linux-g++/output/runinfo.bin'
  n=fstat(1)
  count=floor(n.size/36.)
  
  data=dblarr(5,count)

  pos = read_binary(2,data_type=5,data_dims=3)
  fill = read_binary(2,data_type=3,data_dims=1)
  
  FOR i=0,count-1 DO BEGIN

    ;data_type : 3 for integer, 5 for double
    data[0,i]=read_binary(1,data_type=3,data_dims=1)
    data[1:4,i]=read_binary(1,data_type=5,data_dims=4)

  ENDFOR

  fname = 'x' + strtrim(string(long(pos[0])),1) + 'y' + strtrim(string(long(pos[1])),1) + 'z' + strtrim(string(long(pos[2])),1)
  if fill eq 1 then fname = fname + '-filled.sav' else fname = fname + '.sav'
  
  ff = findfile('data/'+fname,count=count)
  
  if count eq 0 then begin
    save,data,filename='data/'+fname 
    print, "data is written to  : " , fname
  endif else begin
    print,"File is already exist ..." 
  endelse  
  
  close,1

END
