;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Yiğit Dallılar 17/06/2012
;functions :
;-getdata(/data,/cnt)
;-getinfo(/pos,/ener,/numb)
;-eventcount()
;-eventgetinfo(evindex,/pos,/ener,/numb)
;-coulombfield(apos,aener,onindex,cloudnumb)
;-geteventindex()
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;returns infromations from file according to keywrods
;data -> returns all characters form file as bytes
;cnt -< returns number of characters
;return -1 if keyword fails
FUNCTION getdata,data=data,cnt=cnt
;getting values as bytes from file
openr,1,"../data/electron_clouds.bin"
nbyte = fstat(1)
ndata = nbyte.size/4
fdata=bytarr (4,ndata)
readu,1,fdata
close,1

;return data to double format
data=dblarr(ndata)
data = double(fdata(0,*))+(double(fdata(1,*))*256)+$
(double(fdata(2,*))*256*256)+(double(fdata(3,*))*256*256*256)
negval = where (data GT 2147483647)
data(negval) = data(negval) - 4294967295

IF keyword_set(cnt) THEN RETURN, ndata
IF keyword_set(data) THEN RETURN, data

RETURN, -1

END


;reads from file and return according to keywords
;pos -> return position vector of all clouds
;ener -> return energy of all clouds
;numb -> return index of all clouds
;if keyword is not specified return -1
FUNCTION getinfo,pos=pos,ener=ener,numb=numb

data=getdata(/data)
ndata=getdata(/cnt)

;;return information as keyword specified 

ncloud = ndata/5

anumb=dblarr(1,ncloud);creation of final arrays
apos=dblarr(3,ncloud)
aener=dblarr(1,ncloud)

;writing data to arrays
FOR i = 0,(ncloud-1) DO anumb(0,i)=data(5*i)
FOR i = 0,(ncloud-1) DO apos(0,i)=data(5*i+1)/1000000
FOR i = 0,(ncloud-1) DO apos(1,i)=data(5*i+2)/1000000
FOR i = 0,(ncloud-1) DO apos(2,i)=data(5*i+3)/1000000
FOR i = 0,(ncloud-1) DO aener(0,i)=data(5*i+4)/1000

;return as the keyword specified
IF keyword_set(pos) THEN RETURN, apos
IF keyword_set(ener) THEN RETURN, aener
IF keyword_set(numb) THEN RETURN, anumb

;if the keyword is not specified return -1
RETURN,-1

END


;return information as keyword specified
;returns number of events
;if keyword fails return -1
FUNCTION eventcount
data = getdata(/data)
numb = getinfo(/numb)
index = where (numb eq 0,count)
RETURN, count
END

;returns index of the first clouds and one more imaginary event
FUNCTION geteventindex
nofevents=eventcount()
data = getdata(/data)
numb = getinfo(/numb)
aindex = where (numb eq 0)
index=dblarr(nofevents+1)
index(0:nofevents-1) = aindex
index(nofevents)=getdata(/cnt)/5
RETURN,index
END

;return information as keyword specified
;numb returns index of clouds
;pos returns x,y,z position of clouds
;ener returns energy deposition of the clouds
;if keyword fails return -1
;evindex should be small from (count-1) otherwise return -2
FUNCTION eventgetinfo,evindex,pos=pos,ener=ener,numb=numb

data = getdata(/data)

;if evindex is greater than number of events return -2
nofevents=eventcount()
IF (evindex GT nofevents) THEN RETURN, -2

;getting data specified to an event which is controlled by evindex
;index=dblarr(nofevents+1)
;index(0:nofevents-1) = eventcount(/ind)
;index(nofevents)=getdata(/cnt)/5
index=geteventindex()
anumb = getinfo(/numb)
apos = getinfo(/pos)
aener = getinfo(/ener) 

fnumb=dblarr(1,index(evindex)-index(evindex-1))
fener=dblarr(1,index(evindex)-index(evindex-1))
fpos=dblarr(3,index(evindex)-index(evindex-1))

fnumb(0,*) = anumb(0,(index(evindex-1)):(index(evindex)-1))
fpos(0,*) = apos(0,(index(evindex-1)):(index(evindex)-1))
fpos(1,*) = apos(1,(index(evindex-1)):(index(evindex)-1))
fpos(2,*) = apos(2,(index(evindex-1)):(index(evindex)-1))
fener(0,*) = aener(0,(index(evindex-1)):(index(evindex)-1))

;returning data
IF keyword_set(pos) THEN RETURN, fpos
IF keyword_set(ener) THEN RETURN, fener
IF keyword_set(numb) THEN RETURN, fnumb

;no keyword returns -1
RETURN, -1

END
