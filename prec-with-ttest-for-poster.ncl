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
  
  mode = 2

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
  outfile = exp1+"-"+exp2+"-prect-"+area+"-for-poster"

  ;--------------------------
  ;;;; read data totp
  ;--------------------------
  f1 = addfile("./data/"+exp1+".totp.JJA.mean.nc", "r")
  totp1 = f1->totp
  totp1 = totp1 * 86400
  totp1@units = "mm/day"

  lon = f1->lon
  lon(319) = 360.
  
  totp1&lon = lon
  
  f2 = addfile("./data/"+exp2+".totp.JJA.mean.nc", "r")
  totp2 = f2->totp
  totp2 = totp2 * 86400
  totp2&lon = lon
  totp2@units = "mm/day"

  data = totp1-totp2
  copy_VarMeta(totp1,data)
  ;----------------------------------
  
  ;---Graphics
  wks  = gsn_open_wks("eps", outfile)

  cnres                             = True
  cnres@gsnMaximize                 = True
  cnres@gsnDraw                     = False
  cnres@gsnFrame                    = False
  cnres@cnFillOn                    = True
  cmap = read_colormap_file("WhiteYellowOrangeRed")
  cnres@cnFillPalette               = cmap(:,:)
  cnres@cnLinesOn                   = False
  cnres@mpFillOn                    = False
  cnres@mpGeophysicalLineColor      = "Grey18"
  cnres@mpGeophysicalLineThicknessF = 1.5
  cnres@gsnAddCyclic                = False

  cnres@lbAutoManage  = False
  cnres@lbOrientation =   "vertical" 
  ;cnres@lbTitleDirection = "vertical"
  cnres@lbTitleString = "mm/day"
  cnres@lbTitleFontHeightF = 0.015
  cnres@lbBoxLineThicknessF = 0.5
  cnres@lbLabelJust = "CenterRight"
  cnres@lbLabelFontHeightF = 0.01
  cnres@lbBoxMinorExtentF = 0.15
  cnres@lbTitleOffsetF = -0.01        ;define distance between lb title to lb box
  ;cnres@lbLabelPosition = "Left"     ;define which side of lb box dose the markers on
  cnres@lbLabelOffsetF = 0.04
  cnres@lbLeftMarginF = -0.45
  ;cnres@lbLabelStride = 4

  cnres@cnLevelSelectionMode = "ExplicitLevels" ;"AutomaticLevels"          ; set explicit contour levels
  ;cnres@cnLevelSpacingF = 1.0
  cnres@cnLevels    = (/ 1., 2., 3., 4., 5., 6., 7., 8., 9., 10., 11., 12., 13., 14., 15., 16. /)
  cnres@cnFillColors = (/ 5, 20, 35, 50, 65, 80, 95, 110, 125, 140, 155, 170, 185, 200, 215, 230, 245 /)

  if(area.eq."global") then
    cnres@mpCenterLonF = 0
  else
    cnres@mpMinLonF = 60
    cnres@mpMaxLonF = 140
    cnres@mpMinLatF = 5
    cnres@mpMaxLatF = 45
  end if

  cnres@tiMainString = ""
  cnres@gsnLeftString = ""
  cnres@gsnRightString = ""

  pr_plot = new(3,graphic)

  pr_plot(0) = gsn_csm_contour_map_ce(wks,dim_avg_n_Wrap(totp1,0),cnres)
  pr_plot(1) = gsn_csm_contour_map_ce(wks,dim_avg_n_Wrap(totp2,0),cnres)

  delete(cnres@cnLevels)
  delete(cnres@cnFillColors)
  ;cnres@cnLevelSpacingF = 0.3
  levels = (/ -3.75,-3.5, -3.25, -3., -2.75, -2.5, -2.25, -2.,-1.75,-1.5,-1.25,-1.,-0.75,-0.5,-0.25, 0., 0.25, 0.5, 0.75, 1., 1.25, 1.5, 1.75, 2., 2.25, 2.5, 2.75, 3., 3.25, 3.5, 3.75 /)
  cnres@cnLevels    = levels
  ;cnres@cnFillColors = (/ 235,225,215,205,195,185,175,165,155,145,135, 90,80,70,60,50,40,30,20,15, 7, 2 /)
  cnres@cnFillColors = (/ 5,10,15,20,25,30,35,40,45,50,55,60,65,75,85,95,  125,135,140,145,150,155,160,165,170,175,180,185,190,195,200,205,210,215 /)
  
  delete(cnres@cnFillPalette)
  delete(cmap)
  cmap = read_colormap_file("BlueWhiteOrangeRed")
  cnres@cnFillPalette = cmap(15:,:)
  cnres@lbLabelStrings = sprintf("%1.1f", levels)

  pr_plot(2) = gsn_csm_contour_map_ce(wks,dim_avg_n_Wrap(data,0),cnres)


  ;----------------------------------------------------------------
  ; to superimpose ttest picture on pr_plot
  ;----------------------------------------------------------------
  xAve = dim_avg_n_Wrap(totp1,0)
  yAve = dim_avg_n_Wrap(totp2,0)

  xVar = dim_stddev_n_Wrap(totp1,0) ;计算方差
  yVar = dim_stddev_n_Wrap(totp2,0) 

  iflag= False                        ; population variance similar
  prob = ttest(xAve,xVar^2, 100, yAve,yVar^2, 100, iflag, False)
  copy_VarCoords(totp1(0,:,:),prob)

  restt   = True
  restt@gsnDraw         = False
  restt@gsnFrame        = False
  restt@cnFillOn        = False
  restt@cnLinesOn       = False
  restt@cnLineLabelsOn  = False
  restt@cnInfoLabelOn   = False
  restt@gsnLeftString   = ""
  restt@gsnRightString  = ""
  restt@cnLevelSelectionMode = "ExplicitLevels"
  restt@cnLevels       = (/ 0.05 /)
  plott2 = gsn_csm_contour(wks, prob, restt)

  opt                   = True
  opt@gsnShadeFillType  = "Pattern"
  opt@gsnShadeLow       = 17
  plott2 = gsn_contour_shade(plott2, 0.05, -999, opt)
  overlay(pr_plot(2),plott2)

  ;---------------------------------------
  ; create panel resources
  ;---------------------------------------
  pres = True
  pres@gsnFrame = False
  pres@gsnMaximize = True
  pres@lbAutoManage = "False"
  pres@lbTitleString = ""
  pres@lbTitlePosition = ""
  pres@txString  = "Difference in Total Precipitation"
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


