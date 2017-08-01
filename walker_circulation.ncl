;----------------------------------------------------------------------
; h_lat_7.ncl
;----------------------------------------------------------------------
; These files are loaded by default in NCL V6.2.0 and newer
load "/usr/share/ncarg/nclscripts/csm/gsn_code.ncl"   
load "/usr/share/ncarg/nclscripts/csm/gsn_csm.ncl"
load "/usr/share/ncarg/nclscripts/csm/contributed.ncl"   
;----------------------------------------------------------------------
begin

  mode = 1

  hgt = 200
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
  outfile = exp1+"-"+exp2+"-omega-u-vertor"

  ;---Read in variables
  f1   = addfile("./data/"+exp1+".t.JJA.mean.nc","r")
  t1    = f1->t             ; temperature (K)
  f2   = addfile("./data/"+exp1+".u.JJA.mean.nc","r")
  u1    = f2->u             ; meridional wind (m/s)
  f3   = addfile("./data/"+exp1+".w.JJA.mean.nc","r")
  w1    = f3->w         ; units: Pa/s

  f4   = addfile("./data/"+exp2+".t.JJA.mean.nc","r")
  t2    = f4->t             ; temperature (K)
  f5   = addfile("./data/"+exp2+".u.JJA.mean.nc","r")
  u2    = f5->u             ; meridional wind (m/s)
  f6   = addfile("./data/"+exp2+".w.JJA.mean.nc","r")
  w2    = f6->w         ; units: Pa/s

  ;lon = f1->lon
  ;lon(160:319) = lon(160:319) - 360.
  ;lon(160:) = lon(160:) - 360.
  ;t1&lon = lon
  ;t2&lon = lon
  ;u1&lon = lon
  ;u2&lon = lon
  ;w1&lon = lon
  ;w2&lon = lon

  p    = conform(w1, w1&lev, 1)
  p@units = "Pa"

  wc1 =  omega_to_w( w1, p, t1 )
  wc1 = wc1 * 100

  wc2 =  omega_to_w( w2, p, t2 )
  wc2 = wc2 * 100

  du1 = dim_avg_n_Wrap(dim_avg_n_Wrap(u1(:,:,{5:33},:),0),1)
  du2 = dim_avg_n_Wrap(dim_avg_n_Wrap(u2(:,:,{5:33},:),0),1)
  du3 = du1 - du2
  copy_VarCoords(du1, du3)

  dw1 = dim_avg_n_Wrap(dim_avg_n_Wrap(wc1(:,:,{5:33},:),0),1)
  dw2 = dim_avg_n_Wrap(dim_avg_n_Wrap(wc2(:,:,{5:33},:),0),1)
  dw3 = dw1 - dw2
  copy_VarCoords(dw1, dw3)

  ;printVarSummary(du3)
  ;printMinMax(du3,0)
  ;printVarSummary(dw3)
  ;printMinMax(dw3,0)

  ;print(dim_avg_n_Wrap(dw1(:,{80:90}),1))
  ;print(dim_avg_n_Wrap(du1(:,{80:90}),1))
  
;Note: the vector components, omega (mb/day) and v (m/s)
;      which represent the vertical and meridional components 
;      have different units. No scaling is used in this example
;      but the user may wish do do so.
;***************************************
; PLOT
;**************************************
;---Graphics
  wks  = gsn_open_wks("eps", outfile)
  cmap = read_colormap_file("BlueWhiteOrangeRed")

  res                      = True
  res@gsnDraw              = False
  res@gsnFrame             = False

  res@tiMainString         = ""
  res@gsnLeftString        = ""
  res@gsnRightString       = ""
  res@cnFillPalette        = cmap
  res@cnFillOn             = True 
  res@cnLinesOn            = False   ; color on
  res@vpWidthF = 0.9
  res@vpHeightF = 0.5
  ;res@cnLevelSelectionMode = "ManualLevels"      ; manual contouring
  ;res@cnMinLevelValF       = 300.0               ; set min contour level
  ;res@cnMaxLevelValF       = 335.0               ; set max contour level
  ;res@cnLevelSpacingF      = 2                   ; set contour spacing
  res@cnLevelSelectionMode = "ExplicitLevels"
  levels = (/ -0.6,-0.5,-0.4,-0.3,-0.2,-0.1,0.,0.1,0.2,0.3,0.4,0.5,0.6,0.7,0.8,0.9,1.0,1.1,1.2,1.3,1.4,1.5,1.6,1.7,1.8 /)
  res@cnLevels = levels
  res@cnFillColors =  (/ 35,45,55,65,75,85,95,  145,150,155,160,165,170,175,180,185,190,195,200,205,210,215,220,225,230,235 /)

  
  res@lbLabelStride        = 2                   ; every other label bar label
  res@lbAutoManage = False
  res@lbOrientation =   "vertical"
  res@lbTitleString = "m/s"
  res@lbTitleFontHeightF = 0.015
  res@lbBoxLineThicknessF = 0.5
  res@lbLabelJust = "CenterRight"
  res@lbLabelFontHeightF = 0.01
  res@lbBoxMinorExtentF = 0.2


  ;res@vcRefAnnoOrthogonalPosF  = -0.165          ; move reference vec up
  ;res@pmLabelBarOrthogonalPosF = -0.05           ; move color label bar up
  ;res@vcRefMagnitudeF           = 0.04           ; define vector ref mag
  ;res@vcRefLengthF              = 0.045          ; define length of vec ref
  ;res@vcMapDirection           = False

  res@vcFillArrowsOn          = True
  res@vcRefMagnitudeF         = 15.0             ; define vector ref mag
  
  res@vcMinFracLengthF        = 0.6
  res@vcMinDistanceF          = 0.019

  res@vcRefAnnoString2On      = False
  res@vcRefAnnoOrthogonalPosF = -0.99
  res@vcRefAnnoParallelPosF   = 0.995
  ;vcres@vcRefAnnoFontAspectF    = 1.2             ; define vector ref font size
  res@vcRefLengthF            = 0.02               ; define vector ref box length
  res@vcRefAnnoFontHeightF    = 0.006         

  plot = new(3,graphic)
  plot(0)  = gsn_csm_pres_hgt_vector(wks,dw1,du1,dw1*5,res)
  plot(1)  = gsn_csm_pres_hgt_vector(wks,dw2,du2,dw2*5,res)
  delete(res@cnLevelSelectionMode)
  delete(res@cnLevels)
  delete(res@cnFillColors)
  res@cnLevelSelectionMode = "ExplicitLevels"
  res@cnLevels = (/ -0.2,-0.15,-0.1,-0.05,0.,0.05,0.1,0.15,0.2,0.25,0.3,0.35,0.4,0.45,0.5,0.55,0.6,0.65,0.7,0.75,0.8,0.85,0.9,0.95,1.0 /)
  res@cnFillColors =  (/ 55,65,75,85,95,  145,150,155,160,165,170,175,180,185,190,195,200,205,210,215,220,225,230,235,240,245 /)
  delete(res@vcRefMagnitudeF)
  res@vcRefMagnitudeF = 10.0
  plot(2)  = gsn_csm_pres_hgt_vector(wks,dw3,du3,dw3*5,res)
  ;---------------------------------------
  ; create panel resources
  ;---------------------------------------
  pres = True
  pres@gsnFrame = False
  pres@gsnMaximize = True
  ;pres@lbAutoManage = "False"
  ;pres@lbTitleString = ""
  ;pres@lbTitlePosition = ""
  pres@txString  = "Walker Circulation"
  ;pres@gsnLeftString = ""
  pres@gsnPanelFigureStrings= (/ exp1, exp2, exp1+"-"+exp2 /) ; add strings to panel
  pres@gsnPanelFigureStringsFontHeightF = 0.007
  pres@amJust   = "TopRight"

  ;pres@lbTitleDirection = "Across"
  ;pres@lbTitleFontHeightF = 0.015
  ;pres@lbLabelStride = 2
  gsn_panel(wks,plot,(/3,1/),pres)


  frame(wks)

  print("========="+outfile+"==========")

end
