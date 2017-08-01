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

  area = "asia"

  
  outfile = "diff-gginit-al"

  ;--------------------------
  ;;;; read data totp
  ;--------------------------
  f1 = addfile("./ecearth-init/al.nc", "r")
  al = f1->al
  
  lon = f1->lon
  lon(319) = 360

  al&lon = lon
  al@missing_value = -5.960464e-08
  al@_FillValue = -5.960464e-08
  
  ;---Graphics
  wks  = gsn_open_wks("eps", outfile)

  cnres                             = True
  cnres@gsnMaximize                 = True
  cnres@gsnDraw                     = True
  cnres@gsnFrame                    = True
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
  cnres@lbBoxMinorExtentF = 0.2
  ;cnres@lbLabelStride = 4

  ;cnres@cnLevelSelectionMode = "ExplicitLevels" ;"AutomaticLevels"          ; set explicit contour levels
  ;cnres@cnLevelSpacingF = 1.0
  ;cnres@cnLevels    = (/ 1., 2., 3., 4., 5., 6., 7., 8., 9., 10., 11., 12., 13., 14., 15., 16. /)
  ;cnres@cnFillColors = (/ 5, 20, 35, 50, 65, 80, 95, 110, 125, 140, 155, 170, 185, 200, 215, 230, 245 /)

  

  cnres@tiMainString = ""
  cnres@gsnLeftString = ""
  cnres@gsnRightString = ""

 

  plot = gsn_csm_contour_map_ce(wks, al(0,:,:), cnres)


  print("========="+outfile+"==========")


end


