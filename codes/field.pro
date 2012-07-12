;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Yiğit Dallılar 08/07/2012
;
;coulombfield(apos,aener,onindex,cloudnumb)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;returns electric field :::: in progress
FUNCTION elecfield,apos,onindex,cloudnumb

efield=dblarr(3,cloudnumb)
efield(2,onindex)=efield(2,onindex)+100000

RETURN,efield

END


;returns coulomb field related to all clouds
;onindex controls if the cloud is available
FUNCTION coulombfield,apos,aener,onindex,cloudnumb

cfield=dblarr(3,cloudnumb)

;some values
apos = apos*1000 ;mm to m
cntr=0
cnst=1.30968e-10;(conste)/(4*pi*epsilon)
bandgap = 2

;all work is here
;i represents cloudnumber, calculations is done for all clouds
FOR i=0,cloudnumb-1 DO BEGIN 

   fieldvector=dblarr(3,cloudnumb)
   selcloud=dblarr(3,cloudnumb)
   rcube=dblarr(cloudnumb)
   
   ;no calculation for the clouds which is not available
   IF (i EQ onindex(cntr)) THEN BEGIN

    ;selcloud holds information for selected cloud
    fieldvector(*,onindex)=apos(*,onindex)
    FOR j=0,2 DO selcloud(j,*) = selcloud(j,*) + apos (j,i)
    fieldvector(*,onindex) = selcloud(*,onindex) - apos(*,onindex)

    ;;;; think about they all should be zero
    newindex = WHERE ( (fieldvector(0,*)+fieldvector(1,*)+fieldvector(2,*)) NE 0 )
    ;calculation of r^(-3)
    rcube(newindex) = SQRT(fieldvector(0,newindex)^(2)+fieldvector(1,newindex)^(2)+fieldvector(2,newindex)^(2))^(-3)

    FOR j=0,2 DO fieldvector(j,newindex) = rcube(newindex)*fieldvector(j,newindex)
    
    ;for selected cloud information is sent to cfield
    FOR k=0,2 DO BEGIN
       FOR j=0,cloudnumb-1 DO cfield(k,i)=cfield(k,i)+fieldvector(k,j)*cnst*aener(j)/bandgap
    ENDFOR

    cntr = cntr + 1

  ENDIF
ENDFOR

RETURN, cfield
END
