;+
; pj_click
;
; returns x,y locations of n cursor clicks on X window
; inputs/outputs: 
;   x,y will hold n values in device, data (default) or normalized units
; keywords:
;   device, data, norm: passed to cursor.pro (IDL) 
;   quiet: if set, inhibits psym marks on X window and print x,y
;
; history:
;   written by Paulo Simoes, pre-2016.
;-

PRO pj_click,x,y,n,norm=norm,device=device,data=data,quiet=quiet

    quiet=keyword_set(quiet)
     
    IF n_params() LE 2 THEN n=1

    x=fltarr(n)
    y=fltarr(n)

    FOR i=0,n-1 DO BEGIN 

        cursor,x0,y0,/down,norm=norm,device=device,data=data
        IF ~quiet THEN BEGIN
            print,x0,y0
            plots,x0,y0,ps=2,symsiz=1.5
            x[i]=x0
            y[i]=y0
        ENDIF

    ENDFOR 

    IF n EQ 1 THEN BEGIN 
        x=x[0]
        y=y[0]
    ENDIF 

END 
