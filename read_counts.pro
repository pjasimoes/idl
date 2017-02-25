PRO read_counts,spec,srm,r

 if not is_class(o,'SPEX',/quiet) then o = ospex(/no_gui)                                       
 o-> set, spex_specfile= spec

 o-> set, $                                                                                
  spex_drmfile= srm
 
 data=o->getdata(class='spex_data',spex_units='rate') ;; can change it to rate or flux
 time=anytim(o->getaxis(/ut),/ecs)
 time2=anytim(o->getaxis(/ut,/edges_2),/ecs)
 energy=o->getaxis(/ct_energy,/edges_2)
 meanenergy=o->getaxis(/ct_energy,/mean)
 r={time:time,counts:data.data,energy:energy,t2:time2}

 obj_destroy,o
 ;save,file='RHESSI_counts-2014-02-13.save',r
END 
