PRO grid_image,img,time,box,ngrid,intens,grid=grid,define_box=define_box $
               ,ref_image=ref_image,ps=ps,log=log,emis=emis,_EXTRA=_EXTRA

;+
;
; NAME:
; grid_image
;
; PURPOSE:
; Divide given image into user-defined cells and calculates
; the total intensity from each grid cell.
;
; CALL:
; grid_image,img,time,box,ngrid,intens,grid=grid,define_box=define_box $
;               ,ref_image=ref_image,ps=ps,_EXTRA=_EXTRA
;
; INPUTS:
; img - image array [x,y,nimgs]
; box - [x0,y0,x1,y1] in pixels (output if define_box keyword is set)
; ngrid - number of cells (grid x grid)
;        grid=1 one cell, i.e. entire box
;        grid=n n x n grid 
;
; OUTPUT:
; intens - intensity integrated for each grid cell
;
; KEYWORDS:
; grid: returns the grid points x,y 
; define_box - if set, asks the user to click on the map to define the
;              box corners.
; ref_image - index of reference image to plot (if not set, uses the
;             first)
; ps - if set, create a ps file instead of screen. Can be set with a
;      string for the name of the ps file.
; log - if set, plot the image in log scale
;
;
; DEPENDENCIES:
; SSW routines
;
; HISTORY:
; Written by Paulo Simoes, Feb-2013, Glasgow.
;
;-

 ;; sets the reference image to plot
 IF ~keyword_set(ref_image) then ref_image=0

 colortable=1
 if keyword_set(log) then data=alog10(img[*,*,ref_image]) ELSE data=img[*,*,ref_image]

 ;; define box by clicking
 if keyword_set(define_box) then BEGIN 
    IF !d.name NE 'X' THEN set_plot,'X'
    window,0,xsiz=600,ysiz=600
    !p.multi=0
    device,dec=0
    loadct,colortable,/silent
    plot_image,data,_EXTRA=_EXTRA
    al_legend,box=0,'Click: first box corner'
    cursor,x0,y0,/down
    plots,x0,y0,ps=1,symsi=2,thick=3,col=cgcolor('white')
    plots,x0,y0,ps=1,symsi=2,thick=1,col=cgcolor('black')
    al_legend,box=0,['','Click: second box corner']
    cursor,x1,y1,/down
    plots,x1,y1,ps=1,symsi=2,thick=3,col=cgcolor('white')
    plots,x1,y1,ps=1,symsi=2,thick=1,col=cgcolor('black')
    box=[x0,y0,x1,y1]
 ENDIF 

 ;; main box
 x0=min(box[[0,2]])
 x1=max(box[[0,2]])
 y0=min(box[[1,3]])
 y1=max(box[[1,3]])

 ;; box size
 dx=abs(x1-x0)
 dy=abs(y1-y0)

 ;; create cells
 n=ngrid+1
 xx=x0+dx*findgen(n)/float(n-1)
 yy=y0+dy*findgen(n)/float(n-1)
 grid=[[xx],[yy]]
 x=xx-0.5
 y=yy-0.5

 ;; cell size and check for error
 cx=dx/float(n-1)
 cy=dy/float(n-1)
 IF ((cx LT 1) OR (cy LT 1)) THEN BEGIN 
    print,'ERROR: grid cell size is smaller than a pixel.'
    print,'       Increase the box or define less grid divisions.'
    return
 ENDIF 
 
 ;; set PS plot: full FOV image plus grid
 if keyword_set(ps) then BEGIN 
    set_plot,'PS'
    IF is_string(ps) THEN file=ps ELSE file='grid_image.eps'
    device,xsiz=18,ysiz=18,yoff=2,file=file,/encap
 ENDIF 
 IF !d.name eq 'X' THEN window,0,xsiz=600,ysiz=600
 
 !p.multi=0
 device,dec=0
 loadct,colortable,/silent
 plot_image,data,_EXTRA=_EXTRA

 col=254;cgcolor('white')
 ;; plot grid over image
  FOR j=0,n-2 DO BEGIN 
    FOR i=0,n-2 DO BEGIN 
       plots,[[x[i],y[j]],[x[i+1],y[j]],[x[i+1],y[j+1]],[x[i],y[j+1]],[x[i],y[j]]] $
             ,col=col,lines=0
       ; xyouts,mean([x[i],x[i+1]]),mean([y[j],y[j+1]]) $
       ;        ,string(i+j*(n-1),format='(i0)'),align=0.5,col=col,charthi=1,charsiz=0.5
        xyouts,mean([x[i],x[i+1]]),mean([y[j],y[j+1]]), $
        string([i,j],form='(2(i0,:,","))'),align=0.5,col=col,charthi=1,charsiz=0.5
    ENDFOR 
 ENDFOR 
if keyword_set(ps) then BEGIN 
    device,/close
    set_plot,'X'
 ENDIF 

 nm=size(img,/dim) 
 emis=fltarr(n-1,n-1,nm[2])

 FOR j=0,n-2 DO BEGIN 
    FOR i=0,n-2 DO BEGIN 
      emis[i,j,*]=total(total(img[grid[i,0]:grid[i+1,0]-1,grid[j,1]:grid[j+1,1]-1,*],1),1)
       ;;;;b=total(total(img[xx[i]:xx[i+1],yy[j]:yy[j+1],*],1),1)
       ; a=total(img[xx[i]:xx[i+1],*,*],1)
       ; b=total(a[yy[j]:yy[j+1],*],1)
       ; emis[i,j,*]=b
    ENDFOR 
 ENDFOR 

;; set PS: zoom grid
 if keyword_set(ps) then BEGIN 
    set_plot,'PS'
    IF is_string(ps) THEN file=ps ELSE file='grid_image_zoom.eps'
    device,xsiz=18,ysiz=18,yoff=2,file=file,/encap
 ENDIF 
IF !d.name eq 'X' THEN window,2,xsiz=600,ysiz=600
plot_image,data[grid[0,0]:grid[n-1,0]-1,grid[0,1]:grid[n-1,1]-1],orig=[grid[0,0],grid[0,1]],xs=3,ys=3
FOR j=0,n-2 DO BEGIN 
    FOR i=0,n-2 DO BEGIN 
       plots,[[x[i],y[j]],[x[i+1],y[j]],[x[i+1],y[j+1]],[x[i],y[j+1]],[x[i],y[j]]] $
             ,col=col,lines=0
       ; xyouts,mean([x[i],x[i+1]]),mean([y[j],y[j+1]]) $
       ;        ,string(i+j*(n-1),format='(i0)'),align=0.5,col=col,charthi=1,charsiz=1
       xyouts,mean([x[i],x[i+1]]),mean([y[j],y[j+1]]), $
        string([i,j],form='(2(i0,:,","))'),align=0.5,col=col,charthi=1,charsiz=1
    ENDFOR 
 ENDFOR 
if keyword_set(ps) then BEGIN 
    device,/close
    set_plot,'X'
 ENDIF 

 ;; removes plot labels if there are too many cells
 charsize=n GT 6 ? 0.01 : 0.8

;; set PS: grid of lightcurves
if keyword_set(ps) then BEGIN 
    set_plot,'PS'
    IF is_string(ps) THEN file=ps ELSE file='grid_image_lc.eps'
    device,xsiz=18,ysiz=18,yoff=2,file=file,/encap
 ENDIF 

 IF !d.name eq 'X' THEN window,1,xsiz=600,ysiz=600
 !p.multi=[0,n-1,n-1]
 for j=n-2,0,-1 do BEGIN 
    for i=0,n-2 do begin 
       utplot,time,emis[i,j,*],yr=minmax(emis),/xs,ys=2 $
              ,col=cgcolor('cornflowerblue'),charsize=charsize
       ssw_legend,box=0, $
       string([i,j],form='(2(i0,:,","))')
       ;,string(i+j*(n-1),format='(i0)')
    ENDFOR 
 ENDFOR 
 !p.multi=0
 if keyword_set(ps) then BEGIN 
    device,/close
    set_plot,'X'
 ENDIF 

END 
