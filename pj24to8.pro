function pj24to8,num24
;; P.Simoes, 2016. Convert RGB 8-bit values to 24-bit long
;; http://www.idlcoyote.com/code_tips/convert24to8.html
return,[num24 MOD 2L^8, (num24 MOD 2L^16)/2L^8, num24/2L^16]

;; finish later
if is_string(num24) then return,to_hex(pj24to8(cgcolor('blu3')))

end