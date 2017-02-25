;+
; read_fermi, specfile, drmfile, fermi,spex_units=spex_units,obj=obj,timerange=timerange
;
; Simple routine to read FERMI/GBM fits into a structure.
;
; INPUTS:
; specfile: FERMI/GBM data fits file
; drmfile: response matrix fits
; 
; OPTIONAL KEYWORD INPUTS:
; spex_units: select data in 'count' (default), 'rate', 'flux'
; timerange: 2-element array with desired time range (in anytim() formats)
; obj: ospex obj
;
; OUTPUT:
; fermi: struct with data, time, energy arrays
;
; HISTORY:
; written by P.Simoes (2013)
; extended structure (HSH) 25-Oct-2013
; 
;-

pro read_fermi,specfile,drmfile,fermi,spex_units=spex_units,obj=obj,$
  timerange=timerange,qdebug=qdebug,data=data 

 ;; read FERMI/GBM fits into OSPEX object
 if not is_class(obj,'SPEX',/quiet) then obj = ospex(/no_gui)   
 obj-> set, spex_specfile=specfile
 if n_elements(drmfile) ne '' then obj-> set, spex_drmfile=drmfile

 ;; counts, rate or flux
 IF n_elements(spex_units) EQ 0 THEN spex_units='rate'
 print, 'reading FERMI/GBM data in '+spex_units

 ;; read data
 data = obj->getdata(class='spex_data',spex_units=spex_units)
 time = anytim(obj->getaxis(/ut),/ecs)
 energy = obj->getaxis(/ct_energy,/edges_2)

 ;; select time range (or not)
 IF n_elements(timerange) EQ 2 THEN BEGIN 
    near=min(abs((anytim(time)-anytim(timerange[0]))),j1) 
    near=min(abs((anytim(time)-anytim(timerange[1]))),j2) 
    j=[j1,j2]
    print,'time range selected: ',time[j[0]],' - ',time[j[1]]
 ENDIF ELSE j=[0,n_elements(time)-1]
 
 ;; cos = gbm_get_det_cos(time[j[0]:j[1]],ut_cos=ut_cos,status=status)
 ;; det = (strmid(specfile,11,1))
 ;; print,'------->>>> ',det
 ;; IF det EQ 'a' THEN det=10 ELSE IF det EQ 'b' THEN det=11
 ;; det=fix(det)
 ;; detcos = reform(cos[det,*])

 ;; prepare simple output
 fermi={time:time[j[0]:j[1]],data:data.data[*,j[0]:j[1]],error:data.edata[*,j[0]:j[1]],energy:energy,$
    unit:spex_units};;,cos:detcos,ut_cos:ut_cos,status:status}
 if keyword_set(qdebug) then stop
 obj_destroy, obj
end   
;;*****************************************************************************

