pro script,data
	form_struct,nofsource,source,mask,detector,basckgrnd 
 	for i=1,6 do begin                                        
	mask.pixsize = mask.pixsize + i*0.3                               
	codedmasksim,data1,omask=mask,odetector=detector,/verb
        data=[data,data1]
	endfor
end
