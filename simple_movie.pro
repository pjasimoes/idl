pro simple_movie,aia_map1,aia_map2

   ;; example from IDL-EXELIS page, plus my notes
   ;; P.Simoes, 2015

   video_file = 'dg_movie_ex_blabla.mp4'
   video = idlffvideowrite(video_file)
   framerate = 10 ;; adjust this - don't touch unless necessary
   
   framedims = [640,512] ;; adjust this <----

   stream = video.addvideostream(framedims[0], framedims[1], framerate,bit_rate=5e6)
   set_plot, 'z', /copy
   device, set_resolution=framedims, set_pixel_depth=24, decomposed=0

   !p.multi=[0,2,1]
   nframes = 49 ;; number of frames, suggest to use n_elements(images)
   for i=0, nframes-1 do begin

     ;; if the number of frames are different:
     ;; choose a reference map: map1 for example
     j=closest(anytim(map2.time),anytim(map1[i].time))
     plot_map,aia_map1[i],charsiz=1e-3,/noaxe,/log ;; whatever choices you want
     plot_map,aia_map2[j],charsiz=1e-3,/noaxe
     ;; --

     ;; if maps have the same number of frames
     ;plot_map,aia_map1[i],charsiz=1e-3,/noaxe,/log ;; whatever choices you want
     ;plot_map,aia_map2[i],charsiz=1e-3,/noaxe
     ;; --


     ;; oplot,lines
     ;; time labels -> al_legend,aia_map1[i].time,box=0,char=1,textcol='white'
	  ;;;plot,indgen(i) ;; plot whatever you need as you'd do on the screen
     timestamp = video.put(stream, tvrd(true=1))
   endfor
   device, /close
   set_plot, strlowcase(!version.os_family) eq 'windows' ? 'win' : 'x'
   video.cleanup
   !p.multi=0

end