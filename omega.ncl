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
  outfile = exp1+"-"+exp2+"-w"

  ;---------------------------------
  ;  read data w
  ;---------------------------------

  f2 = addfile("./data/"+exp1+".w.JJA.mean.nc","r")
  w1 = f2->w(:,:,:,:)

  lon = f2->lon
  ;lon(319) = 180.
  lon = 180. - lon

  f4 = addfile("./data/"+exp2+".w.JJA.mean.nc","r")
  w2 = f4->w(:,:,:,:)


  w1&lon = lon
  w2&lon = lon

  w3 = w1 - w2
  copy_VarCoords(w1, w3)

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
  
  levels = (/ -0.1,-0.09,-0.08,-0.06,-0.05,-0.04,-0.03,-0.02,-0.01,0.,0.005,0.01,0.015,0.02,0.025,0.03,0.035,0.04,0.045,0.05 /)
  
  cnres@cnLevels = levels
  cnres@cnFillColors = (/ 28,38,48,58,68,78,88,98,108,118,128, 160,165,170,175,180,185,190,195,200,205,210,215,220 /)

  ;cnres@mpCenterLonF = 0
 
  cnres@tiMainString = ""
  cnres@gsnLeftString = ""
  cnres@gsnRightString = ""

  pr_plot = new(3,graphic)
  cnres@lbLabelStrings = sprintf("%2.3f", levels)

  o1 = dim_avg_n_Wrap(w1(:,:,{5:35},:), 0)
  pr_plot(0) = gsn_csm_pres_hgt(wks,dim_avg_n_Wrap(o1,1),cnres)
  o2 = dim_avg_n_Wrap(w2(:,:,{5:35},:), 0)
  pr_plot(1) = gsn_csm_pres_hgt(wks,dim_avg_n_Wrap(o2,1),cnres)

  delete(cnres@cnLevels)
  delete(cnres@cnFillColors)
  levels2 = (/ -0.06,-0.055,-0.05,-0.045,-0.04,-0.035,-0.03,-0.025,-0.02,-0.015,-0.01,-0.005,0.,0.005,0.01,0.015,0.02 /)
  cnres@cnLevels = levels2
  cnres@cnFillColors = (/ 10,15,25,35,45,55,65,75,85,95,105,115,125, 160,170,180,190,200,210,220 /)
  
  ;;delete(cnres@cnFillPalette)
  ;;delete(cmap)
  ;cmap = read_colormap_file("BlueWhiteOrangeRed")
  ;;cnres@cnFillPalette = cmap(15:,:)
  delete(cnres@lbLabelStrings)
  cnres@lbLabelStrings = sprintf("%2.3f", levels2)
  o3 = dim_avg_n_Wrap(w3(:,:,{5:35},:), 0)
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
  pres@txString  = "Omega"
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


