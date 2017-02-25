function pj8to24,r,g,b
;; P.Simoes, 2016. Convert RGB 8-bit values to 24-bit long
;; http://www.idlcoyote.com/code_tips/convert24to8.html
if n_params() eq 3 then return,long(r + (g * 2L^8) + (b * 2L^16))
if n_params() eq 1 then return,long(r[0] + (r[1] * 2L^8) + (r[2] * 2L^16))
end