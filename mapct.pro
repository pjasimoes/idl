PRO mapct,ct

 IF n_elements(ct) THEN loadct,ct,/silent

 tvlct,r,g,b,/get
 r=reverse(r)
 g=reverse(g)
 b=reverse(b)
 
 r[0]=0
 g[0]=0
 b[0]=0
 
 tvlct,r,g,b

END 
