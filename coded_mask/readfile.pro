pro readfile,filename,data

  openr,1,filename
  n=fstat(1)
  count=n.size/56

  data = dblarr(7,count)
  
  for i = 0, count-1 do begin
    data[0:6,i] = read_binary(1,data_type=5,data_dims=7)
  endfor

  close,1
end
