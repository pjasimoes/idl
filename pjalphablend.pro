function pjalphablend,foreGroundImage,backGroundImage,alpha
;; blends two truecolor images with transparency (alpha)
;; Paulo Simoes, 08-2016 (after an IDL Coyote routine)
return, (foreGroundImage * alpha) + (1 - alpha) * backGroundImage

end