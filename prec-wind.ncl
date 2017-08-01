;-------------------------------------------------------
;  生成两个模式的wind独立图及差异图
;  要求前两图的色标一致
;
;  注意：低层850hPa才需要叠加降水，高层200hPa不需要
;-------------------------------------------------------
;  Johnny
;  2016-07-07
;-------------------------------------------------------
load "$NCARG_ROOT/ncarg/nclscripts/csm/gsn_code.ncl"   
load "$NCARG_ROOT/ncarg/nclscripts/csm/gsn_csm.ncl"   
load "$NCARG_ROOT/ncarg/nclscripts/csm/contributed.ncl"

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
  outfile = exp1+"-"+exp2+"-prect-wind-"+area+"-"+hgt

  ;---------------------------------
	;  read data wind
  ;---------------------------------
  f1 = addfile("./data/"+exp1+".u.JJA.mean.nc","r")
  u1 = f1->u(:,{hgt*100},:,:)
  f2 = addfile("./data/"+exp1+".v.JJA.mean.nc","r")
  v1 = f2->v(:,{hgt*100},:,:)

  lon = f1->lon
  lon(319) = 360.

  f3 = addfile("./data/"+exp2+".u.JJA.mean.nc","r")
  u2 = f3->u(:,{hgt*100},:,:)
  f4 = addfile("./data/"+exp2+".v.JJA.mean.nc","r")
  v2 = f4->v(:,{hgt*100},:,:)
  
  u = u1 - u2
  copy_VarMeta(u1,u)
  u&lon = lon

  v = v1 - v2
  copy_VarMeta(v1,v)
  v&lon = lon

  ;--------------------------
  ;;;; read data totp
  ;--------------------------
  f5 = addfile("./data/"+exp1+".totp.JJA.mean.nc", "r")
  totp1 = f5->totp
  totp1 = totp1 * 86400
  totp1&lon = lon
  totp1@units = "mm/day"

  f6 = addfile("./data/"+exp2+".totp.JJA.mean.nc", "r")
  totp2 = f6->totp
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

  cnres@lbAutoManage = False
  cnres@lbOrientation =   "vertical" 
  ;cnres@lbTitleDirection = "vertical"
  cnres@lbTitleString = "mm/day"
  cnres@lbTitleFontHeightF = 0.015
  cnres@lbBoxLineThicknessF = 0.5
  cnres@lbLabelJust = "CenterRight"
  cnres@lbLabelFontHeightF = 0.01
  cnres@lbBoxMinorExtentF = 0.2
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
    cnres@mpMinLatF = 10
    cnres@mpMaxLatF = 50
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
  cnres@cnLevels = levels
  ;cnres@cnFillColors = (/ 235,225,215,205,195,185,175,165,155,145,135, 90,80,70,60,50,40,30,20,15, 7, 2 /)
  cnres@cnFillColors = (/ 5,10,15,20,25,30,35,40,45,50,55,60,65,75,85,95,  125,135,140,145,150,155,160,165,170,175,180,185,190,195,200,205,210,215 /)
  
  delete(cnres@cnFillPalette)
  delete(cmap)
  cmap = read_colormap_file("BlueWhiteOrangeRed")
  cnres@cnFillPalette = cmap(15:,:)
  cnres@lbLabelStrings = sprintf("%2.1f", levels)
  pr_plot(2) = gsn_csm_contour_map_ce(wks,dim_avg_n_Wrap(data,0),cnres)


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
  vcres@vcRefMagnitudeF         = 5.0             ; define vector ref mag
  
  vcres@vcMinFracLengthF        = 0.3
  vcres@vcMinDistanceF          = 0.012

  vcres@vcRefAnnoString2On      = False
  vcres@vcRefAnnoOrthogonalPosF = -0.99
  vcres@vcRefAnnoParallelPosF   = 0.995
  ;vcres@vcRefAnnoFontAspectF    = 1.2             ; define vector ref font size
  vcres@vcRefLengthF            = 0.02             ; define vector ref box length
  vcres@vcRefAnnoFontHeightF    = 0.006            ; define vector ref box height

  uv_plot = new(3, graphic)
  uv_plot(0)  = gsn_csm_vector(wks,dim_avg_n_Wrap(u1,0),dim_avg_n_Wrap(v1,0),vcres)
  uv_plot(1)  = gsn_csm_vector(wks,dim_avg_n_Wrap(u2,0),dim_avg_n_Wrap(v2,0),vcres)
  uv_plot(2)  = gsn_csm_vector(wks,dim_avg_n_Wrap(u,0),dim_avg_n_Wrap(v,0),vcres)
  ;-------------------------------------------------------------

  do i=0,2
    overlay(pr_plot(i), uv_plot(i))
  end do

  ;---------------------------------------
  ; create panel resources
  ;---------------------------------------
  pres = True
  pres@gsnFrame = False
  pres@gsnMaximize = True
  pres@lbAutoManage = "False"
  pres@lbTitleString = ""
  pres@lbTitlePosition = ""
  pres@txString  = "Total Precipitation and Wind Vectors at "+hgt+"hPa (difference)"
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


