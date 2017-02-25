pro gbm_angle,time_range
;+
; simple wrapper to show the cosine of angles of Fermi/GBM NaI 
; detectors in respect to the Sun, fora given time interval (anytim format)
; CALL: gbm_angle,[start_time,end_time]
; Written by P.Simoes, Glasgow, 2014-2015
;
;-
cos = gbm_get_det_cos(time_range, ut_cos=ut_cos, status=status)
if status then begin
ave = average(cos, 2)
s = reverse(sort(ave))
ndet=6
dets = 'NAI_'+trim(indgen(12),'(i2.2)')
 utplot_obj = obj_new('utplot', ut_cos, transpose(cos[s[0:ndet],*]), $
    dim1_ids = dets[s[0:ndet]],dim1_sum=0, id='Fermi GBM Cosine of Detector Angle to Sun', $
    data_unit='cosine')

if ~is_class(plotman_obj,'PLOTMAN') then plotman_obj = plotman()
  plotman_obj -> new_panel, input=utplot_obj, desc='GBM detector cosines'
endif 
  end