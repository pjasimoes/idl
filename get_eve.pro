;+
;
; simple routine to download SDO/EVE data
;
; use:
; get_eve,st_date,ed_date,lines=lines,spectra=spectra
;
; input:
; st_date,ed_date: time range of interest (any format accepted by vso_search)
; set lines or spectra keyword to select the type of file (NOTE: at
; least one MUST be selected).
;
; History
; writen by PJA Simoes, 2013
; added: option to get ESP data, PJAS Dec-2014
;
;-

PRO get_eve,st_date,ed_date,lines=lines,spectra=spectra,esp=esp,files=files

 a = vso_search(st_date,ed_date $
                ,instr='eve' $ $
                ,count=count)

 IF count EQ 0 THEN BEGIN
    print,'no records found.'
    return
 ENDIF 

 print,string(count)+' file(s) found.'

 ;;a.info: 
 ;;L1ESP (ESP)
 ;;L2Spectra (MEGS)
 ;;L2Lines (merged)
 ;;L3 (merged)

 a1=a[where(stregex(a.info,'L1',/bool))]
 a2=a[where(stregex(a.info,'L2',/bool))]
 a3=a[where(stregex(a.info,'L3',/bool))]

 a2S=a2[where(stregex(a2.info,'Spectra',/bool))]
 a2L=a2[where(stregex(a2.info,'Lines',/bool))]
 a1E=a1[where(stregex(a1.info,'ESP',/bool))]

 if keyword_set(lines) then b=vso_get(a2L,filenames=files)
 if keyword_set(spectra) then b=vso_get(a2S,filenames=files)
 if keyword_set(esp) then b=vso_get(a1E,filenames=files)

END 
