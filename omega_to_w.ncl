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
  
  mode = 3

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
  outfile = exp1+"-"+exp2+"-omega_to_w"

  ;---------------------------------
  ;  read data t and w
  ;---------------------------------
  f1 = addfile("./data/"+exp1+".t.JJA.mean.nc","r")
  t1 = f1->t(:,:,:,:)
  f2 = addfile("./data/"+exp1+".w.JJA.mean.nc","r")
  w1 = f2->w(:,:,:,:)

  p    = conform(w1, w1&lev, 1)
  p@units = "Pa"
  ;print(p)

  omega1 =  omega_to_w( w1, p, t1 )

  printMinMax(omega1, 0)

  lon = f1->lon
  ;lon(319) = 180.
  lon = 180. - lon

  f3 = addfile("./data/"+exp2+".t.JJA.mean.nc","r")
  t2 = f3->t(:,:,:,:)
  f4 = addfile("./data/"+exp2+".w.JJA.mean.nc","r")
  w2 = f4->w(:,:,:,:)

  omega2 =  omega_to_w( w2, p, t2 )

  omega1&lon = lon
  omega2&lon = lon

  omega3 = omega1 - omega2
  copy_VarCoords(omega1, omega3)

  ;----------------------------------
  
  ;---Graphics
  wks  = gsn_open_wks("eps", outfile)

  cnres                             = True
  cnres@gsnMaximize                 = True
  cnres@gsnDraw                     = False
  cnres@gsnFrame                    = False
  cnres@cnFillOn                    = True
  cmap = read_colormap_file("ncl_default")
  cnres@cnFillPalette               = cmap(:,:)
  cnres@cnLinesOn                   = False
  ;;cnres@mpFillOn                    = False
  ;;cnres@mpGeophysicalLineColor      = "Grey18"
  ;;cnres@mpGeophysicalLineThicknessF = 1.5
  ;cnres@gsnAddCyclic                = False
  cnres@vpWidthF = 0.9
  cnres@vpHeightF = 0.5

  cnres@lbAutoManage = False
  cnres@lbOrientation =   "vertical" 
  ;cnres@lbTitleDirection = "vertical"
  cnres@lbTitleString = "m/s"
  cnres@lbTitleFontHeightF = 0.015
  cnres@lbBoxLineThicknessF = 0.5
  cnres@lbLabelJust = "CenterRight"
  cnres@lbLabelFontHeightF = 0.01
  cnres@lbBoxMinorExtentF = 0.2
  ;cnres@lbLabelStride = 4

  cnres@tmYRMode             = "Automatic" ; turn off special labels on right axis


  cnres@cnLevelSelectionMode = "ExplicitLevels"
  
  levels = (/ -0.006,-0.005,-0.004,-0.003,-0.002,-0.001,0,0.001,0.002,0.003,0.004,0.005,0.006,0.007,0.008,0.009,0.010,0.011,0.012,0.013,0.014,0.015 /)
  print(levels)
  cnres@cnLevels = levels
  cnres@cnFillColors = (/ 58,68,78,88,98,108,118,128, 129,140,145,150,155,160,165,170,175,180,185,190,195,200,210,210 /)

  ;cnres@mpCenterLonF = 0
 
  cnres@tiMainString = ""
  cnres@gsnLeftString = ""
  cnres@gsnRightString = ""

  pr_plot = new(3,graphic)

  o1 = dim_avg_n_Wrap(omega1(:,:,{5:35},:), 0)
  pr_plot(0) = gsn_csm_pres_hgt(wks,dim_avg_n_Wrap(o1,1),cnres)
  o2 = dim_avg_n_Wrap(omega2(:,:,{5:35},:), 0)
  pr_plot(1) = gsn_csm_pres_hgt(wks,dim_avg_n_Wrap(o2,1),cnres)

  ;;delete(cnres@cnLevels)
  ;;delete(cnres@cnFillColors)
  ;cnres@cnLevelSpacingF = 0.3
  ;;levels = (/ -3.75,-3.5, -3.25, -3., -2.75, -2.5, -2.25, -2.,-1.75,-1.5,-1.25,-1.,-0.75,-0.5,-0.25, 0., 0.25, 0.5, 0.75, 1., 1.25, 1.5, 1.75, 2., 2.25, 2.5, 2.75, 3., 3.25, 3.5, 3.75 /)
  ;;cnres@cnLevels = levels
  ;cnres@cnFillColors = (/ 235,225,215,205,195,185,175,165,155,145,135, 90,80,70,60,50,40,30,20,15, 7, 2 /)
  ;;cnres@cnFillColors = (/ 5,10,15,20,25,30,35,40,45,50,55,60,65,75,85,95,  125,135,140,145,150,155,160,165,170,175,180,185,190,195,200,205,210,215 /)
  
  ;;delete(cnres@cnFillPalette)
  ;;delete(cmap)
  ;cmap = read_colormap_file("BlueWhiteOrangeRed")
  ;;cnres@cnFillPalette = cmap(15:,:)
  ;;cnres@lbLabelStrings = sprintf("%2.1f", levels)
  o3 = dim_avg_n_Wrap(omega3(:,:,{5:35},:), 0)
  pr_plot(2) = gsn_csm_pres_hgt(wks,dim_avg_n_Wrap(o3,1),cnres)


  ;----------------------------------------------------------------
  ; to superimpose wind picture and ttest picture on pr_plot
  ;----------------------------------------------------------------
  

  ;---------------------------------------
  ; create panel resources
  ;---------------------------------------
  pres = True
  pres@gsnFrame = False
  pres@gsnMaximize = True
  pres@lbAutoManage = "False"
  pres@lbTitleString = ""
  pres@lbTitlePosition = ""
  pres@txString  = "Omega_to_w"
  ;pres@gsnLeftString = ""
  pres@gsnPanelFigureStrings= (/ exp1, exp2, exp1+"-"+exp2 /) ; add strings to panel
  pres@gsnPanelFigureStringsFontHeightF = 0.007
  pres@amJust   = "ButtonRight"

  ;pres@lbTitleDirection = "Across"
  ;pres@lbTitleFontHeightF = 0.015
  ;pres@lbLabelStride = 2
  gsn_panel(wks,pr_plot,(/3,1/),pres)


  frame(wks)

  print("========="+outfile+"==========")


end


