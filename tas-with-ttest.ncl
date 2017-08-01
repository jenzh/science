;-------------------------------------------------------
;  生成两个模式的tas独立图及差异图
;  要求前两图的色标一致
;
;  Johnny
;  2016-07-07
;-------------------------------------------------------
load "/usr/share/lib/ncarg/nclscripts/csm/gsn_code.ncl"   
load "/usr/share/lib/ncarg/nclscripts/csm/gsn_csm.ncl"   
load "/usr/share/lib/ncarg/nclscripts/csm/contributed.ncl"   
begin

  mode = 3
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
  outfile = exp1+"-"+exp2+".tas.annual."+area

  f1 = addfile("./data/"+exp1+".tas.annual.nc", "r")
  tas1 = f1->tas
  tas1 = tas1 - 273.15
  lon = f1->lon
  lon(319) = 360.
  tas1&lon = lon
  
  f2 = addfile("./data/"+exp2+".tas.annual.nc", "r")
  tas2 = f2->tas
  tas2 = tas2 - 273.15
  tas2&lon = lon

  data = tas1 - tas2
  copy_VarMeta(tas1,data)

  printMinMax(tas1,0)
  printMinMax(tas2,0)
  printMinMax(data,0)

;************************************************
; create plot
;************************************************
  wks_type = "eps"
  ;wks_type@wkWidth = 1980
  ;wks_type@wkHeight = 1980
  wks = gsn_open_wks(wks_type, outfile)  

  cnres                             = True
  cnres@gsnMaximize                 = True
  cnres@gsnDraw                     = False
  cnres@gsnFrame                    = False

  cmap = read_colormap_file("BlueWhiteOrangeRed")
  cnres@cnLinesOn                   = False
  cnres@cnFillOn                    = True
  cnres@cnFillPalette               = cmap(15:,:)
  
  cnres@mpGeophysicalLineColor      = "Grey18"
  cnres@mpGeophysicalLineThicknessF = 1.5
  cnres@gsnAddCyclic                = False

  cnres@lbAutoManage = False
  cnres@lbOrientation =   "vertical"
  cnres@lbLabelJust = "CenterRight"  ; define label text close to right. depend on lbAutoManage = False
  cnres@lbLabelFontHeightF = 0.01
  cnres@lbTitleString = "Units: ~S~o~N~C"
  cnres@lbTitleFontHeightF = 0.01
  cnres@lbBoxLineThicknessF = 0.5
  cnres@lbBoxMinorExtentF = 0.2


  cnres@cnLevelSelectionMode = "ExplicitLevels"         ; set explicit contour levels
  ;cnres@cnLevelSpacingF = 1.0
  cnres@cnLevels    = (/ -10, -8, -6, -4, -2, 0, 2, 4, 6, 8, 10, 12, 14, 16, 18, 20, 22, 24, 26, 28 /)
  cnres@cnFillColors = (/ 45, 55,65,75,85,95,125,135,140,145,150,155,160,165,170,175,180,185,190,195,200 /)
  
  if(area.eq."global") then
    cnres@mpCenterLonF = 0
  else
    cnres@mpMinLonF = 80
    cnres@mpMaxLonF = 160
    cnres@mpMinLatF = 10
    cnres@mpMaxLatF = 60
  end if

  cnres@tiMainString = ""
  cnres@gsnLeftString = ""
  cnres@gsnRightString = ""
  
  plot = new(3,graphic)
  plot(0) = gsn_csm_contour_map(wks, dim_avg_n_Wrap(tas1,0), cnres)
  plot(1) = gsn_csm_contour_map(wks, dim_avg_n_Wrap(tas2,0), cnres)

  delete(cnres@cnLevels)
  delete(cnres@cnFillColors)
  ;levels = (/ -3.25,-3.,-2.75,-2.5,-2.25,-2.,-1.75,-1.5,-1.25,-1.,-0.75,-0.50,-0.25, 0, 0.25, 0.5, 0.75, 1.0, 1.25, 1.5, 1.75, 2., 2.25, 2.5, 2.75, 3.,3.25 /)
  levels = (/ -3.0,-2.7,-2.4,-2.1,-1.8,-1.5,-1.2,-0.9,-0.6,-0.3, 0, 0.3, 0.6, 0.9, 1.2, 1.5, 1.8, 2.1, 2.4, 2.7, 3.0 /)
  cnres@cnLevels = levels
  cnres@cnFillColors = (/ 15,30,40,50,55,60,65,70,75,85,95, 130,140,150,160,165,170,175,180,185,195,205 /)
  
  cnres@lbLabelStrings = sprintf("%2.1f",levels)   ; Format the labels
  cnres@lbLabelAlignment = "InteriorEdges"
  plot(2) = gsn_csm_contour_map(wks, dim_avg_n_Wrap(data,0), cnres)

  ;-----------------------------------------------------------------
  ; superimpose ttest on plot
  ;-----------------------------------------------------------------
  
  xAve = dim_avg_n_Wrap(tas1,0)
  yAve = dim_avg_n_Wrap(tas2,0)

  xVar = dim_stddev_n_Wrap(tas1,0) ;计算方差
  yVar = dim_stddev_n_Wrap(tas2,0) 

  iflag= False                        ; population variance similar
  prob = ttest(xAve,xVar^2, 100, yAve,yVar^2, 100, iflag, False)
  copy_VarCoords(tas1(0,:,:),prob)

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
  overlay(plot(2),plott2)
  ;------------------------------------------------------------------
  
  ;panel resources
  pres = True
  pres@gsnFrame = False
  pres@gsnMaximize = True
  pres@txString  = "Difference of Air Temperature (Annual mean)"
  ;pres@gsnLeftString = "Units:degC"
  pres@gsnPanelFigureStrings= (/ exp1, exp2, exp1+"-"+exp2 /) ; add strings to panel
  pres@gsnPanelFigureStringsFontHeightF = 0.007
  pres@amJust = "ButtonRight"

  ;pres@lbTitleDirection = "Across"
  ;pres@lbTitleFontHeightF = 0.015
  ;pres@lbLabelStride = 2
  gsn_panel(wks,plot,(/3,1/),pres)
  
  frame(wks)

  print("================="+outfile+"=============")

end
