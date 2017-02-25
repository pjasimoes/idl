PRO aia3channel,m1,m2,m3,img,log=log,factor=factor,diff=diff,labsize=labsize,negative=negative $
	,noplot=noplot,dmin=dmin,dmax=dmax,_EXTRA=_EXTRA

 IF n_elements(dmin) EQ 1 THEN dmin=[dmin,dmin,dmin] 
 IF n_elements(dmax) EQ 1 THEN dmax=[dmax,dmax,dmax]
 IF n_elements(dmin) EQ 0 THEN dmin=[0,0,0] 
 IF n_elements(dmax) EQ 0 THEN dmax=[max(m1.data),max(m2.data),max(m3.data)]
 
 if ~keyword_set(factor) then factor=[1.,1.,1.]

 s=size(m1.data,/dim)
 IF factor[0] NE 0 THEN img1 = cgscalevector(m1.data,minv=dmin[0],maxv=dmax[0],0b,factor[0]) 
 IF factor[1] NE 0 THEN img2 = cgscalevector(m2.data,minv=dmin[1],maxv=dmax[1],0b,factor[1]) 
 IF factor[2] NE 0 THEN img3 = cgscalevector(m3.data,minv=dmin[2],maxv=dmax[2],0b,factor[2]) 

;img1=bytscl(m1.data,min=dmin[0],max=dmax[0],top=byte(255b*factor[0]))
;img2=bytscl(m2.data,min=dmin[1],max=dmax[1],top=byte(255b*factor[0]))
;img3=bytscl(m3.data,min=dmin[2],max=dmax[2],top=byte(255b*factor[0]))
 ;; img1=factor[0]*(m1.data>dmin[0]) / max(m1.data,/nan)
 ;; img2=factor[1]*(m2.data>dmin[1]) / max(m2.data,/nan)
 ;; img3=factor[2]*(m3.data>dmin[2]) / max(m3.data,/nan)

 if keyword_set(diff) then BEGIN 
    img1=img1-smooth(img1,3,/edge_tr)
    img2=img2-smooth(img2,3,/edge_tr)
    img3=img3-smooth(img3,3,/edge_tr)
 ENDIF 

 img=[[[img1]],[[img2]],[[img3]]]
 if keyword_set(log) then  img=alog10(img)
 img=bytscl(img)
 if keyword_set(negative) then img=255b-img

 if ~keyword_set(noplot) then BEGIN 
    plot_image,img,_EXTRA=_EXTRA
    tcol = keyword_set(negative) ? ['cyan','magenta','yellow'] : ['red','green','blue']
    al_legend,[[m1.id+' '+m1.time],[m2.id+' '+m2.time],[m3.id+' '+m3.time]],box=0,textcol=tcol,/bot,charsize=labsize
 ENDIF 

END 

;; k=14
;; !p.multi=[0,3,2]
;; aia3channel,s304[49],s304[k],s304[0]
;; aia3channel, s94[49] ,s94[k], s94[0]
;; aia3channel,s131[49],s131[k],s131[0]
;; aia3channel,s171[49],s171[k],s171[0]
;; aia3channel,s193[49],s193[k],s193[0]
;; aia3channel,s1600[49/2],s1600[k/2],s1600[0]
;; !p.multi=0
