#######################################################
#                                                     #
#  Encounter Command Logging File                     #
#  Created on Wed Jun  6 02:41:41 2018                #
#                                                     #
#######################################################

#@(#)CDS: First Encounter v08.10-p004_1 (32bit) 11/04/2008 14:34 (Linux 2.6)
#@(#)CDS: NanoRoute v08.10-p008 NR081027-0018/USR58-UB (database version 2.30, 67.1.1) {superthreading v1.11}
#@(#)CDS: CeltIC v08.10-p002_1 (32bit) 10/23/2008 22:04:14 (Linux 2.6.9-67.0.10.ELsmp)
#@(#)CDS: CTE v08.10-p016_1 (32bit) Oct 26 2008 15:11:51 (Linux 2.6.9-67.0.10.ELsmp)
#@(#)CDS: CPE v08.10-p009

loadConfig ./encounter.conf
floorPlan -r 1.0 0.6 20 20 20 20
addRing -spacing_bottom 5 -width_left 5 -width_bottom 5 -width_top 5 -spacing_top 5 -layer_bottom metal5 -width_right 5 -around core -center 1 -layer_top metal5 -spacing_right 5 -spacing_left 5 -layer_right metal6 -layer_left metal6 -nets { gnd vdd }
amoebaPlace
sroute -noBlockPins -noPadRings
trialRoute
buildTimingGraph
setCteReport
report_timing  -nworst 10 -net -late  > timing.rep.1.placed
setLayerPreference hinst -isVisible 0
setLayerPreference fence -isVisible 0
setLayerPreference guide -isVisible 0
setLayerPreference obstruct -isVisible 0
setLayerPreference region -isVisible 0
setLayerPreference screen -isVisible 0
setLayerPreference inst -isVisible 0
setLayerPreference stdCell -isVisible 0
setLayerPreference coverCell -isVisible 0
setLayerPreference block -isVisible 0
setLayerPreference io -isVisible 0
setLayerPreference areaIo -isVisible 0
setLayerPreference net -isVisible 0
setLayerPreference power -isVisible 0
setLayerPreference term -isVisible 0
setLayerPreference ruler -isVisible 0
setLayerPreference text -isVisible 0
setLayerPreference relFPlan -isVisible 0
setLayerPreference yieldCell -isVisible 0
setLayerPreference yieldMap -isVisible 0
setLayerPreference sdpConnect -isVisible 0
setLayerPreference densityMap -isVisible 0
setLayerPreference hinst -isVisible 1
setLayerPreference fence -isVisible 1
setLayerPreference guide -isVisible 1
setLayerPreference obstruct -isVisible 1
setLayerPreference region -isVisible 1
setLayerPreference screen -isVisible 1
setLayerPreference inst -isVisible 1
setLayerPreference stdCell -isVisible 1
setLayerPreference coverCell -isVisible 1
setLayerPreference block -isVisible 1
setLayerPreference io -isVisible 1
setLayerPreference areaIo -isVisible 1
setLayerPreference net -isVisible 1
setLayerPreference power -isVisible 1
setLayerPreference term -isVisible 1
setLayerPreference ruler -isVisible 1
setLayerPreference text -isVisible 1
setLayerPreference relFPlan -isVisible 1
setLayerPreference yieldCell -isVisible 1
setLayerPreference yieldMap -isVisible 1
setLayerPreference sdpConnect -isVisible 1
setLayerPreference densityMap -isVisible 1
setLayerPreference hinst -isSelectable 0
setLayerPreference fence -isSelectable 0
setLayerPreference guide -isSelectable 0
setLayerPreference obstruct -isSelectable 0
setLayerPreference region -isSelectable 0
setLayerPreference screen -isSelectable 0
setLayerPreference inst -isSelectable 0
setLayerPreference stdCell -isSelectable 0
setLayerPreference coverCell -isSelectable 0
setLayerPreference block -isSelectable 0
setLayerPreference io -isSelectable 0
setLayerPreference areaIo -isSelectable 0
setLayerPreference net -isSelectable 0
setLayerPreference power -isSelectable 0
setLayerPreference term -isSelectable 0
setLayerPreference ruler -isSelectable 0
setLayerPreference text -isSelectable 0
setLayerPreference relFPlan -isSelectable 0
setLayerPreference yieldCell -isSelectable 0
setLayerPreference yieldMap -isSelectable 0
setLayerPreference sdpConnect -isSelectable 0
setLayerPreference densityMap -isSelectable 0
setLayerPreference hinst -isSelectable 1
setLayerPreference fence -isSelectable 1
setLayerPreference guide -isSelectable 1
setLayerPreference obstruct -isSelectable 1
setLayerPreference region -isSelectable 1
setLayerPreference screen -isSelectable 1
setLayerPreference inst -isSelectable 1
setLayerPreference stdCell -isSelectable 1
setLayerPreference coverCell -isSelectable 1
setLayerPreference block -isSelectable 1
setLayerPreference io -isSelectable 1
setLayerPreference areaIo -isSelectable 1
setLayerPreference net -isSelectable 1
setLayerPreference power -isSelectable 1
setLayerPreference term -isSelectable 1
setLayerPreference ruler -isSelectable 1
setLayerPreference text -isSelectable 1
setLayerPreference relFPlan -isSelectable 1
setLayerPreference yieldCell -isSelectable 1
setLayerPreference yieldMap -isSelectable 1
setLayerPreference sdpConnect -isSelectable 1
setLayerPreference densityMap -isSelectable 1
setLayerPreference hinst -isSelectable 0
setLayerPreference fence -isSelectable 0
setLayerPreference guide -isSelectable 0
setLayerPreference obstruct -isSelectable 0
setLayerPreference region -isSelectable 0
setLayerPreference screen -isSelectable 0
setLayerPreference inst -isSelectable 0
setLayerPreference stdCell -isSelectable 0
setLayerPreference coverCell -isSelectable 0
setLayerPreference block -isSelectable 0
setLayerPreference io -isSelectable 0
setLayerPreference areaIo -isSelectable 0
setLayerPreference net -isSelectable 0
setLayerPreference power -isSelectable 0
setLayerPreference term -isSelectable 0
setLayerPreference ruler -isSelectable 0
setLayerPreference text -isSelectable 0
setLayerPreference relFPlan -isSelectable 0
setLayerPreference yieldCell -isSelectable 0
setLayerPreference yieldMap -isSelectable 0
setLayerPreference sdpConnect -isSelectable 0
setLayerPreference densityMap -isSelectable 0
setLayerPreference hinst -isSelectable 1
setLayerPreference fence -isSelectable 1
setLayerPreference guide -isSelectable 1
setLayerPreference obstruct -isSelectable 1
setLayerPreference region -isSelectable 1
setLayerPreference screen -isSelectable 1
setLayerPreference inst -isSelectable 1
setLayerPreference stdCell -isSelectable 1
setLayerPreference coverCell -isSelectable 1
setLayerPreference block -isSelectable 1
setLayerPreference io -isSelectable 1
setLayerPreference areaIo -isSelectable 1
setLayerPreference net -isSelectable 1
setLayerPreference power -isSelectable 1
setLayerPreference term -isSelectable 1
setLayerPreference ruler -isSelectable 1
setLayerPreference text -isSelectable 1
setLayerPreference relFPlan -isSelectable 1
setLayerPreference yieldCell -isSelectable 1
setLayerPreference yieldMap -isSelectable 1
setLayerPreference sdpConnect -isSelectable 1
setLayerPreference densityMap -isSelectable 1
setLayerPreference guide -isVisible 0
setLayerPreference guide -isVisible 1
setLayerPreference guide -isVisible 0
setLayerPreference guide -isVisible 1
setLayerPreference fence -isVisible 0
setLayerPreference fence -isVisible 1
setLayerPreference hinst -isVisible 0
setLayerPreference hinst -isVisible 1
setLayerPreference stdCell -isVisible 0
setLayerPreference stdCell -isVisible 1
setLayerPreference stdCell -isVisible 0
setLayerPreference stdCell -isVisible 1
zoomSelected
fit
viewSnapshot -dir {/home/icic/Desktop/lumos } -view {fplan amoeba place }
createSnapshot -name snap
setLayerPreference hinst -isVisible 0
setLayerPreference fence -isVisible 0
setLayerPreference guide -isVisible 0
setLayerPreference obstruct -isVisible 0
setLayerPreference region -isVisible 0
setLayerPreference screen -isVisible 0
setLayerPreference inst -isVisible 0
setLayerPreference stdCell -isVisible 0
setLayerPreference coverCell -isVisible 0
setLayerPreference block -isVisible 0
setLayerPreference io -isVisible 0
setLayerPreference areaIo -isVisible 0
setLayerPreference net -isVisible 0
setLayerPreference power -isVisible 0
setLayerPreference term -isVisible 0
setLayerPreference ruler -isVisible 0
setLayerPreference text -isVisible 0
setLayerPreference relFPlan -isVisible 0
setLayerPreference yieldCell -isVisible 0
setLayerPreference yieldMap -isVisible 0
setLayerPreference sdpConnect -isVisible 0
setLayerPreference densityMap -isVisible 0
setLayerPreference hinst -isVisible 1
setLayerPreference fence -isVisible 1
setLayerPreference guide -isVisible 1
setLayerPreference obstruct -isVisible 1
setLayerPreference region -isVisible 1
setLayerPreference screen -isVisible 1
setLayerPreference inst -isVisible 1
setLayerPreference stdCell -isVisible 1
setLayerPreference coverCell -isVisible 1
setLayerPreference block -isVisible 1
setLayerPreference io -isVisible 1
setLayerPreference areaIo -isVisible 1
setLayerPreference net -isVisible 1
setLayerPreference power -isVisible 1
setLayerPreference term -isVisible 1
setLayerPreference ruler -isVisible 1
setLayerPreference text -isVisible 1
setLayerPreference relFPlan -isVisible 1
setLayerPreference yieldCell -isVisible 1
setLayerPreference yieldMap -isVisible 1
setLayerPreference sdpConnect -isVisible 1
setLayerPreference densityMap -isVisible 1
setLayerPreference hinst -isVisible 0
setLayerPreference fence -isVisible 0
setLayerPreference guide -isVisible 0
setLayerPreference obstruct -isVisible 0
setLayerPreference region -isVisible 0
setLayerPreference screen -isVisible 0
setLayerPreference inst -isVisible 0
setLayerPreference stdCell -isVisible 0
setLayerPreference coverCell -isVisible 0
setLayerPreference block -isVisible 0
setLayerPreference io -isVisible 0
setLayerPreference areaIo -isVisible 0
setLayerPreference net -isVisible 0
setLayerPreference power -isVisible 0
setLayerPreference term -isVisible 0
setLayerPreference ruler -isVisible 0
setLayerPreference text -isVisible 0
setLayerPreference relFPlan -isVisible 0
setLayerPreference yieldCell -isVisible 0
setLayerPreference yieldMap -isVisible 0
setLayerPreference sdpConnect -isVisible 0
setLayerPreference densityMap -isVisible 0
setLayerPreference hinst -isVisible 1
setLayerPreference fence -isVisible 1
setLayerPreference guide -isVisible 1
setLayerPreference obstruct -isVisible 1
setLayerPreference region -isVisible 1
setLayerPreference screen -isVisible 1
setLayerPreference inst -isVisible 1
setLayerPreference stdCell -isVisible 1
setLayerPreference coverCell -isVisible 1
setLayerPreference block -isVisible 1
setLayerPreference io -isVisible 1
setLayerPreference areaIo -isVisible 1
setLayerPreference net -isVisible 1
setLayerPreference power -isVisible 1
setLayerPreference term -isVisible 1
setLayerPreference ruler -isVisible 1
setLayerPreference text -isVisible 1
setLayerPreference relFPlan -isVisible 1
setLayerPreference yieldCell -isVisible 1
setLayerPreference yieldMap -isVisible 1
setLayerPreference sdpConnect -isVisible 1
setLayerPreference densityMap -isVisible 1
