PRO UTPOLYFILL,X0, Y, base_time, $
        channel=channel, $
        clip=clip, color=color, device=device, $
        linestyle=linestyle, noclip=noclip, data=data, $
        normal=normal, nsum=nsum, polar=polar, $
        psym=psym, symsize=symsize, $
        t3d=t3d, thick=thick, max_value=max_value,line_fill=line_fill, $
        pattern=pattern,spacing=spacing,transparent=transparent, $       
        orientation=orientation

on_error,2
;+
; NAME:
;	UTPOLYFILL
; PURPOSE:
;	polyfill version for over a previously drawn plot (using UTPLOT) with
;	universal time labelled X axis.  If start and end times have been
;	set, only data between those times is displayed. Useful to
;	plot error strips, vertical/horizontal bars on utplots
; CATEGORY:
; CALLING SEQUENCE:
;	UTPOLYFILL,X,Y
;	UTPOLYFILL,X,Y, base_time
; INPUTS:
;       X -     X array providing the time coordinates of the points to be
;               connected to plot. At least 3 elements.
;               (MDM) Structures allowed
;       Y -     Y array providing the Y coordinates of the points to
;               be connected. At least 3 elements.
;	base_time - reference time, formerly called...
;       	xst or utstring.  It's purpose is to fully define the time
;		in the input parameter, x0.  The start of the plot is fully
;		defined by utbase and xst, both in utcommon and the two are identical
;		after a call to Utplot.  When x0 is passed as a double precision
;		vector, it is assumed to be relative to utbase.  Any other form
;		for the time should be complete.  
;		This parameter should only be used for seconds arrays relative to
;		a base other than Utbase, the base just used for plotting.
;	MANY KEYWORDS FROM IDL POLYFILL CAN BE USED.
; OUTPUTS:
;	None.
; OPTIONAL OUTPUT PARAMETERS:
;	None.
; COMMON BLOCKS:
;	None.
; SIDE EFFECTS:
;	Overlays polygon (X,Y) on existing plot.
; RESTRICTIONS:
;	Can only be used after issuing UTPLOT command.
; PROCEDURE:
;	If UTSTRING parameter is passed, a temporary X array is created 
;	containing the original X array offset by the new base
;	time minus the old base time (used in UTPLOT command).  POLYFILL is 
;	called to plot the temporary polygon X,Y.
; MODIFICATION HISTORY:
;	Written by Paulo Simoes 02/2014
;	Shamelessly based on OUTPLOT procedude (SSW)
; EXAMPLE:
;; create some data
; x = findgen(1000) ;; time array
; utbase='2014-02-14'
; y = gaussian(x,[1,500,100])+.5 +randomu(seed,1000)/20. ;; data
; ;; time array for error strip
; xx= [x,reverse(x)]
; ;; error strip
; yy= [y+0.1,reverse(y)-0.1]
;
; ;; utplot data (generate utplot window)
; utplot,x,y,utbase,/nodat,yr=[0,2],timer='2014-02-14 '+['0:01','0:14'],/xs
; ;; polyfill vertical bars
; utpolyfill,utbase+[' 00:08',' 00:08',' 00:10',' 00:10'],[0,2,2,0],col=150 $
;            ,noclip=0,LINE_FILL=1,ORIENT=45,SPACING=.2
; ;; polyfill error strip
; utpolyfill,xx,yy,col=100,noclip=0 
; ;; now outplot data
; outplot,x,y,col=200
;
;-
@utcommon
;
	;save some values which could be changed inside t_utplot, utbase, and xst
	utbase_old=utbase
	xst_old   =xst
	t_utplot, x0, xplot=x, utbase=utbase, xstart=xst, base_time=base_time
	x = x + (anytim(xst,/sec))(0) - (anytim(xst_old,/sec))(0)
	utbase = utbase_old
	xst    = xst_old
;
;    
psave = !p
        !p.channel=fcheck(channel,!p.channel)
        !p.clip=fcheck(clip,!p.clip)
        !p.color=fcheck(color,!p.color)
        !p.linestyle=fcheck(linestyle,!p.linestyle)
        !p.noclip=fcheck(noclip,!p.noclip)
        !p.nsum=fcheck(nsum,!p.nsum)
        !p.psym=fcheck(psym,!p.psym)
        !p.t3d=fcheck(t3d,!p.t3d)
        !p.thick=fcheck(thick,!p.thick)

;; here is the polyfill bit (PS)
polyfill,x,y, noclip=noclip, $
         line_fill=line_fill, $
         pattern=pattern,spacing=spacing,transparent=transparent, $       
         orientation=orientation
;oplot,x,y, polar=fcheck(polar), symsize=fcheck(symsize,1), $	;MDM patch 23-Oct-92 because of change to IDL
;	max_value=max_value
!p = psave
;
;.........................................................................

return
end

