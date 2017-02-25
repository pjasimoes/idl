function get_goes,st,ed,bk=bk

search_network,/enable

;; read GOES data from server
o = ogoes()
tstart = anytim(st,/yoh)
tend = anytim(ed,/yoh)
print,'--------------------   ',tstart,' - ',tend    ;; PRINT
o->set,tstart=tstart,tend=tend
g = o->getdata(/struct,bk=bk)
obj_destroy,o
;class = goes_value2class(max(g.yclean[*,0]))
return, g

end 