FUNCTION norm1,x,mean=mean,min=min

	y=x
	if keyword_set(mean) then y=y-mean(y)
	if keyword_set(min) then y=y-min(y)
	y=y/max(y,/nan)
	return,y

END 
