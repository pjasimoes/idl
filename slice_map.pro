;+
;
; NAME:
;  slice_map
;
; PURPOSE:
;  Given a time sequence of SSW maps, allows the user to select (click) two 
;  points in the map FOV to produce "time-slice" diagrams (e.g. see Fig. 2 in
;  Simoes et al. ApJ 777 2013). 
; 
; CALL:
;  slice_map,map,slice,d,pnt=pnt,diff=diff,index=index,ct=ct,dx=dx,log=log
;     ,evtgrid=evtgrid,mapxr=mapxr,mapyr=mapyr,noplot=noplot,_EXTRA=_EXTRA
;
; INPUT:
;  map: array of SSW maps
;  OPTIONAL:
;   dx: width of the slice, in pixels (def=3)
;   pnt: pair of x,y points to be used (no clicking)
; 
; OUTPUT:
;  slice: time-slice diagram
;  d: distance along the slice in arcsecs
;  OPTIONAL:
;   pnt: if not defined as input, returns x,y positions of the clicked 
;        points (arcsec)
;        
; EXAMPLE:
;  slice_map,map,slice,d ;; click 2 points
;  ; to reproduce the time-slice diagram do:
;  utplot_image,slice,map.time,d
;
; AUTHOR:
;  Paulo J. A. Simoes (paulo.simoes@glasgow.ac.uk)
;  University of Glasgow
;
; HISTORY:
;  Change History::
;   Written by: Paulo J. A. Simões (2014, based on 2013 routine)
;   Modified: added gamma_ct, index verification, lightcurve oplot and doc.
;             Nov 2014 PJAS
;			  added histequal keyword: applies hist_equal to slice Dec 2015 PJAS
;
; TODO:
;
;-

pro slice_map,map,slice,d,pnt=pnt,diff=diff,index=index,ct=ct,dx=dx,log=log $
	,evtgrid=evtgrid,mapxr=mapxr,mapyr=mapyr,noplot=noplot,timeidx=timeidx $
	,lightcurve=lightcurve,ps=ps,debug=debug,histequal=histequal,_EXTRA=_EXTRA

tvlct,rold,gold,bold,/get
device,get_dec=dec
device,dec=0
if n_elements(ct) ne 0 then begin
if ct[0] gt 74 then aia_lct,wave=ct[0],/load else loadct,ct[0],/sil 
if n_elements(ct) gt 1 then gamma_ct,ct[1],current=0
endif 

if n_elements(dx) eq 0 then dx=3
n=n_elements(map)
s=size(map[0].data,/dim)

if n_elements(index) eq 0 then index=0
if keyword_set(timeidx) then index=closest(anytim(map.time),anytim(index))
if index ge n_elements(map) then $ 
		message,'Attempt to subscript MAP with INDEX is out of range.'
if n_elements(pnt) eq 0 then begin 

plot_map,map[index],/log,bot=2,xticklen=1,yticklen=1
al_legend,box=0,'Click in the map to define start/end of slice'
pj_click,x,y,2
pnt=[[x],[y]]
endif

print,'Points:'
print,'x0,y0=['+string([pnt[0,0],pnt[0,1]],form='(2(f0.2,:,","))')+']'
print,'x1,y1=['+string([pnt[1,0],pnt[1,1]],form='(2(f0.2,:,","))')+']'

;; map center
xcen=map[0].xc
ycen=map[0].yc

;; arcsec to pixel
xp=(get_map_xp(map[index]))[*,0]
yp=reform((get_map_yp(map[index]))[0,*])
x=closest(xp,pnt[*,0])
y=closest(yp,pnt[*,1])

m = float(y[1]-y[0])/float(x[1]-x[0])
b = y[0] - m*x[0]

print,'delta_x=',abs(x[1]-x[0])
print,'delta_y=',abs(y[1]-y[0])
;help,x,y
;distcent=sqrt( (pnt[*,0]-xcen)^2+(pnt[*,1]-ycen)^2)
;ss=sort(distcent)

;; SORT OUT THE CUT (MORE HORIZONTAL OR VERTICAL)
;print,ss
if abs(x[1]-x[0]) gt abs(y[1]-y[0]) then begin 
	;print,'x GT y'
	xgty=1
	print,'HORIZONTAL'
	xx=x[0] lt x[1] ? indgen(abs(x[1]-x[0]))+x[0] : x[0]-indgen(abs(x[1]-x[0]))
	if abs(y[1]-y[0]) lt 3 then yy=replicate(mean(y),n_elements(xx)) else yy=xx*m+b
	exptime=rebin(reform(map.dur,1,n_elements(map.dur)),n_elements(xx),n_elements(map.dur))
	;slice=transpose(map.data[xx,yy])/exptime
	;for i=-dx/2,dx/2 do slice+=transpose(map.data[xx,yy+i])/exptime
	;; check which end is closer to 1st click
	dd=sqrt( (xx[[0,-1]]-pnt[0,0])^2+(yy[[0,-1]]-pnt[0,1])^2)
	ss=sort(dd)
	;if ss[0] eq 1 then xx=reverse(xx)

	slice=fltarr(n_elements(map),n_elements(xx),dx)
	for i=0,dx-1 do slice[0,0,i]=transpose(map.data[xx,yy+i-dx/2.]/exptime)
	if dx gt 1 then slice=mean(slice,dim=3)
endif else begin
	xgty=0
	yy=y[0] lt y[1] ? indgen(abs(y[1]-y[0]))+y[0] : y[0]-indgen(abs(y[1]-y[0]))
	if abs(x[1]-x[0]) lt 3 then xx=replicate(mean(x),n_elements(yy)) else xx=(yy-b)/m
	exptime=rebin(reform(map.dur,1,n_elements(map.dur)),n_elements(xx),n_elements(map.dur))
	;slice=transpose(map.data[xx,yy])
	;for i=-dx/2,dx/2 do slice+=transpose(map.data[xx+i,yy])
	;; check which end is closer to the map center
	dd=sqrt( (xx[[0,-1]]-xcen)^2+(yy[[0,-1]]-ycen)^2)
	slice=fltarr(n_elements(map),n_elements(xx),dx)
	for i=0,dx-1 do slice[0,0,i]=transpose(map.data[xx+i-dx/2.,yy]/exptime)
	if dx gt 1 then slice=mean(slice,dim=3)
endelse

if keyword_set(diff) then begin
slice=slice-smooth(slice,5,/edge_tr) 
min=-20
max=+20
endif else begin
	if keyword_set(log) then begin 
		slice=alog10(slice)
		min=1;alog10(10)
		max=max(slice,/nan)
	endif else begin
		min=0
		max=max(slice,/nan)
	endelse
endelse

mdx=map[index].dx ;; assumes dx=dy
last=n_elements(xx)-1
dc1=sqrt((xp[xx[0]]-map[index].xc)^2+(yp[yy[0]]-map[index].yc)^2)
dc2=sqrt((xp[xx[last]]-map[index].xc)^2+(yp[yy[last]]-map[index].yc)^2)
i = dc1 le dc2 ? 0 : last
xc=xx[i]
yc=yy[i]
print,dc1,dc2,i
d=sqrt(((xx-xc))^2+((yy-yc))^2)*mdx
distance=sqrt(abs(pnt[1,0]-pnt[0,0])^2+abs(pnt[1,1]-pnt[0,1])^2)
d=interpol([0,distance],n_elements(xx))

if ~keyword_set(noplot) then begin
;if keyword_set(ps) then  
!p.multi=[0,2,1]

plot_map,map[index],/log,bot=2,xr=mapxr,yr=mapyr

arrow2,xp[xx[0]],yp[yy[0]],xp[xx[last]],yp[yy[last]],/data,hsize=!d.x_size/200.,col=254
;oplot,xp[xx[[0,last]]],yp[yy[[0,last]]]
;; draw ticks onto arrow
;; create axis for cut
;ang=atan(m)
ang=atan(y[1]-y[0],x[1]-x[0])
print,m,ang,ang/!dtor,sin(ang),cos(ang)
t3d,/reset,matrix=rmat
t3d,rmat,trans=[0,0,0],matrix=rmat
t3d,rmat,rot=[0,0,ang/!dtor],matrix=rmat
t3d,rmat,trans=[xp[xx[0]],yp[yy[0]],0],matrix=rmat

ticklen=!d.X_CH_SIZE/3.
mintick=10. ;; arcsecs usually
ang=atan(m)
maxtick = max(d) - (max(d) mod mintick) + mintick
xi=indgen(maxtick/mintick)*mintick
yi=xi*0
ticks=yi-ticklen

zi = replicate(0.,n_elements(xi))
c = [[xi],[yi],[zi],[replicate(1.,n_elements(xi))]]
c = c # rmat

zi = replicate(0.,n_elements(xi))
cticks = [[xi],[ticks],[zi],[replicate(1.,n_elements(xi))]]
cticks = cticks # rmat
for i=0,n_elements(xi)-1 do oplot,[c[i,0],cticks[i,0]],[c[i,1],cticks[i,1]]
xyouts,c[0,0],c[0,1],' '+'0',orien=ang/!Dtor+90,align=-1,charsiz=0.5
xyouts,c[-1,0],c[-1,1],' '+string(maxtick-mintick,form='(i0)'),orien=ang/!Dtor+90,charsiz=0.5,align=-1
;; done

s1=size(slice,/dim)
s2=size(map.time,/dim)
s3=size(d,/dim)
if s1[0] ne s2 then stop
if s1[1] ne s3 then stop

if keyword_set(histequal) then begin 
	slice_old=slice
	slice=hist_equal(slice)
	max=[]
	min=[]
	;stop
endif
utplot_image,slice,map.time,d,min=min,max=max,bot=2,ytit='Distance along cut [arcsec]',_EXTRA=_EXTRA

if n_elements(lightcurve) then begin
	lc=total(total(map.data,1),1)/float(n_elements(map[0].data))/map.dur ;; DN/s/pix
	outplot,map.time,norm1(lc,/min)*0.9*max(d),col=cgcolor(lightcurve,1),_EXTRA=_EXTRA ;; oplot lightcurves scaled to the plot yrange
endif

if n_elements(evtgrid) ne 0 then evt_grid,evtgrid,lines=2
!p.multi=0
endif 
device,dec=dec
tvlct,rold,gold,bold
if keyword_set(debug) then stop

end 
