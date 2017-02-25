FUNCTION pj_box,x,y

 x0=minmax(x)
 y0=minmax(y)
 
 dx=x0[1]-x0[1]
 dy=y0[1]-y0[0]

 box=[[x0[0],y0[0]] $
      ,[x0[1],y0[0]] $
      ,[x0[1],y0[1]] $
      ,[x0[0],y0[1]] $
      ,[x0[0],y0[0]] ]
 
 return,box

END 
