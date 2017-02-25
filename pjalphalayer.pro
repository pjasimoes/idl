function pjalphalayer,foreGroundImage,backGroundImage,alpha
;; blends two truecolor images with transparency (alpha)
;; Paulo Simoes, 08-2016 (after an IDL Coyote routine)
return, ((foreGroundImage) * (alpha) + backGroundImage) <255b>0

end