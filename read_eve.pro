FUNCTION read_eve,file,data=data,aia=aia,diode=diode,flags=flags,scflags=scflags,photons=photons

;+
; eve = read_eve(file)
; 
; wrapper for eve_read_whole_fits
; returns simplified data (time,wavelengths,spectra or lines)
; history: 
; Written by PJA Simoes, Glasgow, early 2014
; ??/Aug/2014 - PJAS, modified to read spectrum files
; 13/Nov/2014 - PJAS, added keyword photons to retrieve spectra count_rate (EVS)
; 02/Dec/2014 - PJAS, added keyword diode to retrieve diode data frmo EVL
;-

  flagset=0
  scflagset=0
  flags=[]
  scflags=[]
  is_line = stregex(file[0],'EVL')
  is_spec = stregex(file[0],'EVS')

if is_line ne -1 and is_spec ne -1 then message,'input EVS *or* EVL.'

if is_line ne -1 then begin ;; process line files

 data = eve_read_whole_fits(file[0])
 ;; wavelengths
 ws=data.linesmeta.wave_center
 
;; DIODE
ndiode=n_elements(data.diodemeta.type)
for j=0,ndiode-1 do begin
  irr=[]
  time=[]
  for i=0,n_elements(file)-1 DO BEGIN  
       data = eve_read_whole_fits(file[i])
       ;; time at start of observation (tai,tai+10sec)
       time=[time,tai2utc(data.linesdata.tai)]
       ;; data
       irr=[irr,data.linesdata.diode_irradiance[j]]
       name=data.diodemeta[j].name
    ENDFOR 
    ri={time:time,irr:irr,name:name} 
    IF j EQ 0 THEN diode=replicate(ri,ndiode) ELSE diode[j]=ri 
 ENDFOR 

 ;; AIA bands
 aiabands = n_elements(where(data.bandsmeta.type EQ 'AIA '))
 ;; read reconstructed AIA filters
 FOR j=0,aiabands-1 DO BEGIN 
    irr=[]
    time=[]
    FOR i=0,n_elements(file)-1 DO BEGIN  
       data = eve_read_whole_fits(file[i])
       ;; time at start of observation (tai,tai+10sec)
       time=[time,tai2utc(data.linesdata.tai)]
       ;; data
       irr=[irr,data.linesdata.band_irradiance[j]]
       name=data.bandsmeta[j].name
    ENDFOR 
    ri={time:time,irr:irr,name:name} 
    IF j EQ 0 THEN aia=replicate(ri,aiabands) ELSE aia[j]=ri 
 ENDFOR 

 ;; read EVE lines
 FOR j=0,n_elements(ws)-1 DO BEGIN  
    irr=[]
    acc=[]
    prc=[]
    time=[]
    FOR i=0,n_elements(file)-1 DO BEGIN  
       ;; wave in nm
       data = eve_read_whole_fits(file[i])

       ;; wavelength
       w=data.linesmeta.wave_center

       ;;j=closest(w,wave[k])
       ;; atom name and ionisation level
       name=data.linesmeta[j].name
       logt=data.linesmeta[j].logt
       wmin=data.linesmeta[j].wave_min
       wmax=data.linesmeta[j].wave_max
       blends=data.linesmeta[j].blends

       ;; check flags
       IF total(data.linesdata[j].flags) NE 0 THEN flagset=1
       IF total(data.linesdata[j].sc_flags) NE 0 THEN scflagset=1 ;;print,'SC_FLAGS ne 0, spacecraft issues, verify.'

       ;; time at start of observation (tai,tai+10sec)
       time=[time,tai2utc(data.linesdata.tai)]
       ;; data
       irr=[irr,data.linesdata.line_irradiance[j]*1d3]
       acc=[acc,data.linesdata.line_accuracy[j]]
       prc=[prc,data.linesdata.line_precision[j]]
       wv=w[j]
       unit='mW m^-2'       
       ;; flags
        if j eq 0 then flags=[flags,data.linesdata.flags]
        if j eq 0 then scflags=[scflags,data.linesdata.sc_flags]

    ENDFOR 
    
    ri={time:time,irr:irr,unit:unit,acc:acc,prc:prc,name:name,wv:wv,logt:logt,wmin:wmin,wmax:wmax,blends:blends,file:file_basename(file)} 
    IF j EQ 0 THEN r=replicate(ri,n_elements(w)) ELSE r[j]=ri 
 ENDFOR 

if flagset then print,'FLAGS ne 0, data may be suspect, verify.'
if scflagset then print,'SPACECRAFT FLAGS ne 0, data may be suspect, verify.'
endif 

if is_spec ne -1 then begin

  data = eve_read_whole_fits(file[0])
  wv=data.spectrummeta.wavelength
  tut=anytim(tai2utc(data.spectrum.tai),/ecs)
  spec=keyword_set(photons) ? data.spectrum.count_rate:data.spectrum.irradiance
  prec=data.spectrum.precision

    for i=1,n_elements(file)-1 do begin 
      data = eve_read_whole_fits(file[i])
      t=anytim(tai2utc(data.spectrum.tai),/ecs)
      s=keyword_set(photons) ? data.spectrum.count_rate:data.spectrum.irradiance
      pr=data.spectrum.precision
      tut=[tut,t]
      spec=[[spec],[s]]
      prec=[[prec],[pr]]
    endfor 
      r={time:tut,wave:wv,irr:spec,prec:prec,file:file_basename(file),unit:'W m^-2 nm^-1'}
  endif 
 return, r

END 
