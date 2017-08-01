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

  hgt = 500
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
  outfile = exp1+"-"+exp2+"-geopotential-"+area+"-"+hgt

  ;---------------------------------
	;  read data wind
  ;---------------------------------
  f1 = addfile("./data/"+exp1+".z.JJA.mean.nc","r")
  z1 = f1->z(:,{hgt*100},:,:)
  z1 = z1 / 9.8

  lon = f1->lon
  lon(319) = 360.
  z1&lon = lon
  
  f2 = addfile("./data/"+exp2+".z.JJA.mean.nc","r")
  z2 = f2->z(:,{hgt*100},:,:)
  z2 = z2 / 9.8
  z2&lon = lon

  z = z1 - z2
  copy_VarCoords(z1, z)

  printMinMax(z1, True)
  printMinMax(z2, True)
  printMinMax(z, True)

  ;---Graphics
  wks  = gsn_open_wks("eps", outfile)

  res                = True
  res@gsnFrame       = False
  res@gsnDraw        = False
  res@gsnLeftString  = ""
  res@gsnRightString = ""


  cnres                             = res
  cnres@gsnMaximize                 = False
  cnres@cnFillOn                    = False
  cnres@cnLinesOn                   = True
  cnres@mpFillOn                    = True

  cmap = read_colormap_file("mch_default")
  cnres@cnFillPalette               = cmap(:,:)
 
  cnres@mpGeophysicalLineColor      = "Grey18"
  cnres@mpGeophysicalLineThicknessF = 1.5
  cnres@gsnAddCyclic                = False

  
  cnres@cnLevelSelectionMode = "ExplicitLevels" ; set explicit contour levels
  cnres@cnLineLabelsOn = True
  cnres@cnLineLabelFontHeightF = 0.006
  ;cnres@cnLineDashPattern = 0
  cnres@cnLineColor = cmap(3,:)
  cnres@cnLineLabelFontColor = cmap(3,:)
  cnres@cnLineLabelBackgroundColor = 0
  
  cnres@cnInfoLabelOn = False

  cnres@mpCenterLonF = 0

  if(area.eq."global") then
    ;cnres@cnLevels    = ispan(5400,5900,10)
  else
    cnres@cnLevels    = (/ 5800,5802,5804,5806,5808,5810,5812,5814,5816,5818,5820, 5822,5824,5826,5828,5830,5832,5834,5836,5838 /)
    cnres@mpMinLonF = 90
    cnres@mpMaxLonF = 150
    cnres@mpMinLatF = 10
    cnres@mpMaxLatF = 40
  end if

  cnres@tiMainString = ""
  cnres@gsnLeftString = ""
  cnres@gsnRightString = ""

  pr_plot = new(3,graphic)

  pr_plot(0) = gsn_csm_contour_map_ce(wks,dim_avg_n_Wrap(z1,0),cnres)
  pr_plot(1) = gsn_csm_contour_map_ce(wks,dim_avg_n_Wrap(z2,0),cnres)

  ;-------------------------------------------
  ;
  ;-------------------------------------------
  z = z1 - z2
  copy_VarCoords(z1, z)
  printMinMax(z,True)
  delete(cnres@cnLevels)
  cnres@cnLevels    = ispan(20, 50, 2)
  pr_plot(2) = gsn_csm_contour_map_ce(wks,dim_avg_n_Wrap(z,0),cnres)

  ;----------------------------------------------------------------
  ; to superimpose 5820 and ttest picture on pr_plot
  ;----------------------------------------------------------------
  slp_res                                = res
  ;slp_res@cnLineColor                    = ""
  ;slp_res@cnLineLabelBackgroundColor     = -1    ; transparent
  slp_res@cnLineThicknessF               = 2.5
  
  slp_res@cnInfoLabelOn = False
  ;slp_res@cnInfoLabelPerimOn             = True

  ;slp_res@cnFillOn = False
  slp_res@cnLinesOn = True
  slp_res@cnLevelSelectionMode = "ExplicitLevels"
  slp_res@cnLevels = (/ 5822 /)
  slp_res@cnFillColors = (/ 60 /)
  
  slp_res@cnLineLabelsOn = True
  slp_res@cnLineLabelFontHeightF = 0.006
  
  if(area.eq."global") then
    slp_res@cnHighLabelsOn                 = True
    slp_res@cnLowLabelsOn                  = True
    slp_res@cnHighLabelBackgroundColor     = -1
    slp_res@cnLowLabelBackgroundColor      = -1
  end if
  ln_plot = new(2,graphic)
  ln_plot(0) = gsn_csm_contour(wks,dim_avg_n_Wrap(z1,0),slp_res)
  ln_plot(1) = gsn_csm_contour(wks,dim_avg_n_Wrap(z2,0),slp_res)

  do i=0,1
    overlay(pr_plot(i), ln_plot(i))
  end do
 
  ;---------------------------------------
  ; create panel resources
  ;---------------------------------------
  pres = True
  pres@gsnFrame = False
  pres@gsnMaximize = False
  pres@lbAutoManage = False
  pres@lbTitleString = ""
  pres@lbTitlePosition = ""
  pres@txString  = "Geopotential at "+hgt+"hPa"
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


