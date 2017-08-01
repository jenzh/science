;-------------------------------------------------------
;  生成两个模式的wind独立图及差异图
;  要求前两图的色标一致
;
;  注意：低层850hPa才需要叠加降水，高层200hPa不需要
;-------------------------------------------------------
;  Johnny
;  2016-07-07
;-------------------------------------------------------
load "/usr/share/ncarg/nclscripts/csm/gsn_code.ncl"   
load "/usr/share/ncarg/nclscripts/csm/gsn_csm.ncl"   
load "/usr/share/ncarg/nclscripts/csm/contributed.ncl"

begin
;------------------------------------------------------
;   configure var 
;
; mode: 1 for vegetation
;       2 for orb
;       3 for two force
; hgt:  level
; area: global or box
;------------------------------------------------------
  
  mode = 1

  hgt = 850
  area = "asia"

  if(mode.eq.1) then
    exp1 = "G505"
    exp2 = "B6KA"
  end if

  if(mode.eq.2) then
    exp1 = "B6KA"
    exp2 = "B400"
  end if
  if(mode.eq.3) then
    exp1 = "G505"
    exp2 = "B400"
  end if
  outfile = exp1+"-"+exp2+"-wind-"+area+"-"+hgt

  ;---------------------------------
	;  read data wind
  ;---------------------------------
  f1 = addfile("./data/"+exp1+".u.JJA.mean.nc","r")
  u1 = f1->u(:,{hgt*100},:,:)
  f2 = addfile("./data/"+exp1+".v.JJA.mean.nc","r")
  v1 = f2->v(:,{hgt*100},:,:)
  
  ;lon = f1->lon
  ;lon(319) = 360.
  ;u1&lon = lon
  ;v1&lon = lon

  f3 = addfile("./data/"+exp2+".u.JJA.mean.nc","r")
  u2 = f3->u(:,{hgt*100},:,:)
  f4 = addfile("./data/"+exp2+".v.JJA.mean.nc","r")
  v2 = f4->v(:,{hgt*100},:,:)
  ;u2&lon = lon
  ;v2&lon = lon
  
  ;---Graphics
  wks  = gsn_open_wks("eps", outfile)

  ;----------------------------------------------------------------
  ; to superimpose wind picture and ttest picture on pr_plot
  ;----------------------------------------------------------------

  vcres                         = True
  vcres@gsnDraw                 = False
  vcres@gsnFrame                = False

  ;vcres@vcGlyphStyle            = "CurlyVector"
  
  vcres@vcFillArrowsOn          = True
  vcres@gsnRightString          = ""
  vcres@gsnLeftString           = ""
  vcres@vcRefMagnitudeF         = 20.0             ; define vector ref mag
  
  vcres@vcMinFracLengthF        = 0.2
  vcres@vcMinDistanceF          = 0.01   ;NOTICE WARNING!!!!!!

  vcres@vcRefAnnoString2On      = False
  vcres@vcRefAnnoOrthogonalPosF = -0.99
  vcres@vcRefAnnoParallelPosF   = 0.995
  ;vcres@vcRefAnnoFontAspectF    = 1.2             ; define vector ref font size
  vcres@vcRefLengthF            = 0.03             ; define vector ref box length
  vcres@vcRefAnnoFontHeightF    = 0.006            ; define vector ref box height

  ;vcres@gsnAddCyclic = True
  
  if(area.eq."global") then
    
  else
    vcres@mpCenterLonF = 0
    vcres@mpMinLonF = 60
    vcres@mpMaxLonF = 140
    vcres@mpMinLatF = 10
    vcres@mpMaxLatF = 50
  end if

  uv_plot = new(3, graphic)
  uv_plot(0)  = gsn_csm_vector_map(wks,dim_avg_n_Wrap(u1,0),dim_avg_n_Wrap(v1,0),vcres)
  uv_plot(1)  = gsn_csm_vector_map(wks,dim_avg_n_Wrap(u2,0),dim_avg_n_Wrap(v2,0),vcres)
  
  ;-------------------------------------------------------------
  ; superimpose ttest of U on uv_plot(2)
  ; only for U wind because only Asia moonsoon be noticed
  ;-------------------------------------------------------------
  xAve = dim_avg_n_Wrap(u1,0)
  yAve = dim_avg_n_Wrap(u2,0)
  ;printVarSummary(xAve)
  xVar = dim_stddev_n_Wrap(u1,0) ;计算方差
  yVar = dim_stddev_n_Wrap(u2,0) 

  iflag= False                        ; population variance similar
  prob = ttest(xAve,xVar^2, 100, yAve,yVar^2, 100, iflag, False)
  copy_VarCoords(u1(0,:,:),prob)

  printMinMax(prob, 0)
  ;---------------------------------------------------------------
  ; NOTES:
  ; left the value in u1 when the valeu of prob <= 0.05
  ; u = mask(u1, (prob.le.0.05), True)
  ; delete the value in u1 when the value of prob <= 0.05
  ; u = mask(u1, (prob.le.0.05), False)
  ;---------------------------------------------------------------

  u = dim_avg_n_Wrap(u1-u2, 0)
  v = dim_avg_n_Wrap(v1-v2, 0)

  u = mask(u, (prob.le.0.05), True)
  v = mask(v, (prob.le.0.05), True)

  copy_VarMeta(u1(0,:,:),u)
  copy_VarMeta(v1(0,:,:),v)

  ; debug
  ;f = addfile("prob.nc", "c")
  ;f->prob = prob
  ;f->u = u
  ;f->v = v
  ;f->u1 = u1
  ;f->v1 = v1

  uv_plot(2)  = gsn_csm_vector_map(wks,u,v,vcres)

  ;---------------------------------------
  ; create panel resources
  ;---------------------------------------
  pres = True
  pres@gsnFrame = False
  pres@gsnMaximize = True
  pres@lbAutoManage = "False"
  pres@lbTitleString = ""
  pres@lbTitlePosition = ""
  pres@txString  = "Wind Vectors at "+hgt+"hPa"
  ;pres@gsnLeftString = ""
  pres@gsnPanelFigureStrings= (/ exp1, exp2, exp1+"-"+exp2 /) ; add strings to panel
  pres@gsnPanelFigureStringsFontHeightF = 0.007
  pres@amJust   = "ButtonRight"

  ;pres@lbTitleDirection = "Across"
  ;pres@lbTitleFontHeightF = 0.015
  ;pres@lbLabelStride = 2
  gsn_panel(wks,uv_plot,(/3,1/),pres)

  frame(wks)

  print("========="+outfile+"==========")


end


