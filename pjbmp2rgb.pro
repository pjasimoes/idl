function pjbmp2rgb,y,ct=ct,aia=aia,reverse=reverse,true=true,alpha=alpha
;; returns RGB image for a given grayscale image and a colortable

tvlct,rold,gold,bold,/get
if n_elements(ct) ne 0 then begin 
    if keyword_set(aia) then aia_lct,r,g,b,wave=ct $
    else begin 
        loadct,ct,/sil
        tvlct,r,g,b,/get
    endelse
endif else tvlct,r,g,b,/get

n=size(y,/dim)
nalpha = n_elements(alpha)
has_alpha = nalpha ne 0

rgb=bytarr(n[0],n[1],3+has_alpha)
rgb[*,*,0]=r[y]
rgb[*,*,1]=g[y]
rgb[*,*,2]=b[y]
if has_alpha then rgb[*,3]=alpha

tvlct,rold,gold,bold
return,rgb

end