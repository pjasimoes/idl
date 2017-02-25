function pjblendimg,fore,back,alpha,screen=screen,overlay=overlay $
    ,lineardodge=lineardodge,colorburn=colorburn,hardlight=hardlight

if n_params() lt 3 then alpha=0.5
;; SCREEN
if keyword_set(screen) then return,byte(255*(1. - ((1.-back/255.)*(1.-fore/255.))))

;; OVERLAY
if keyword_set(overlay) then $
    return, byte((back>128.) * (255. - (255.*2.*( (back-128.)>0 ) )<255)* (255.-fore) ) + $
            byte((back<128.) * ((2.*back)<255.)*fore)

;; HARDLIGHT
if keyword_set(hardlight) then begin
    out=bytarr(size(fore,/dim))
    pp=where(fore gt 128,comp=qq)
    if pp[0] ne -1 then out[pp]=byte( 255. - (255. - 2.*(fore[pp]-128.)*(255.-back[pp])) /255.)
    if qq[0] ne -1 then out[qq]= byte(2.*fore[qq]*back[qq]/256.)
    return,out
endif

;; LINEAR DODGE
if keyword_set(lineardodge) then return,byte( ( float(fore)+float(back))<255b )

;; COLOUR BURN
if keyword_set(colorburn) then return,byte(255.- ((255.-float(back))/float(fore)<255>0) )

return, (fore * alpha) + (1 - alpha) * back

end