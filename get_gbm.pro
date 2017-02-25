PRO get_gbm,timerange,file=file,det=det,show_sunward=show_sunward $
    ,type=type,sunward_dets=sunward_dets
;+
;  wrapper for SSW GBM routines to easily download Fermi/GBM NaI 
;  data and response matrix files for a given time range.
; 
;  call
;  get_gbm,[starttime,endtime],file=file,det=det,type=type,/show_sunward
;
;  input: time range [start,end] in anytim formats
;  optional keyword input: 
;  set keyword det to select a specific detector:
;  n0 n1 n2 n3 n4 n5 n6 n7 n8 n9 na nb
;  e.g. det='n4'
;  
;  type='cspec' (default) or 'ctime'
;
;  set keyword show_sunward to print the order of most 
;  sunward NaI detectors; the order is retured in the keyword sunward_dets
;
;  data and rsp file names are output through keyword file
;  (use read_fermi.pro to read the counts into an IDL structure)
;
;  written by Paulo Simoes, Glasgow, 2015
;-
 

if n_elements(type) eq 0 then type='cspec' ;; 'ctime'
 show_sunward = keyword_set(show_sunward) 

 f = gbm_cat() ;; see gbm_cat__define.pro for loads of info
 closest=1
 ebin=2
 r = f.whichflare(timerange,ebin=ebin,only_one=only_one $
                  ,biggest=biggest,closest=closest,structure=0 $
                  ,index=1,err_msg=err_msg,count=count)
 cat = f.whichflare(timerange,ebin=ebin,only_one=only_one $
                  ,biggest=biggest,closest=closest,structure=1 $
                  ,index=0,err_msg=err_msg,count=count)
 ;; notes:
 ;; closest can be useful to find flare near the timerange given
 print,'Fermi GBM: searching flare:'
 print,'Errors found: ',err_msg
 print,'Files found: ',count
 print,'index: ',r
 print,'FLARE INFO'
 print,'ID: ',cat.id
 print,'UT PEAK: ',anytim(cat.utpeak[ebin],/ecs)

 ;; get cosine info
 ;; cos = gbm_get_det_cos(timerange,ut_cos=ut_cos)
 ;; utplot,ut_cos,cos[0,*],yr=minmax(cos)
 ;; hsi_linecolors
 ;; FOR i=0,11 DO outplot,ut_cos,cos[i,*],col=i+1
 sunward_dets=f.sunward_dets(r,/array)
 print,'Sunward dets: ',sunward_dets
 IF show_sunward THEN return
 ;; get most sunward det unless a det is specified by user.
 det = n_elements(det) EQ 0 ? sunward_dets[0] : det

 ;; find GBM data
 tr=[cat.utstart,cat.utend]
 gbm_find_data, date=tr,pattern=type,det=det, /rsp $
                ,err=err,count=counts,file=file
 print,'Getting data...'
 print,'Errors found: ',err
 print,'Files found: ',count

END 
