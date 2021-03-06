--[[

XLua Module, required by xlua_utils.lua
Licensed under the EUPL v1.2: https://eupl.eu/

]]
--[[ Table that contains the configuration Variables for the misc utils module ]]
local MiscUtils_Config_Vars = {
{"MISC_UTILS"},
{"MainTimerInterval",1},
{"SyncBaros",0},
}
--[[ List of Datarefs used by this module ]]
local Dref_List = {
    "sim/operation/failures/rel_conlock",	-- Controls locked
    "sim/operation/failures/rel_door_open",	-- Door Open
    "sim/operation/failures/rel_ex_power_on",	-- External power is on
    "sim/operation/failures/rel_pass_o2_on",	-- Passenger oxygen on
    "sim/operation/failures/rel_fuelcap",	-- Fuel Cap left off
    "sim/operation/failures/rel_fuel_water",	-- Water in fuel
    "sim/operation/failures/rel_fuel_type",	-- Wrong fuel type - JetA for props or Avgas for jets!
    "sim/operation/failures/rel_fuel_block0",	-- Fuel tank filter is blocked - tank 1
    "sim/operation/failures/rel_fuel_block1",	-- Fuel tank filter is blocked - tank 2
    "sim/operation/failures/rel_fuel_block2",	-- Fuel tank filter is blocked - tank 3
    "sim/operation/failures/rel_fuel_block3",	-- Fuel tank filter is blocked - tank 4
    "sim/operation/failures/rel_fuel_block4",	-- Fuel tank filter is blocked - tank 5
    "sim/operation/failures/rel_fuel_block5",	-- Fuel tank filter is blocked - tank 6
    "sim/operation/failures/rel_fuel_block6",	-- Fuel tank filter is blocked - tank 7
    "sim/operation/failures/rel_fuel_block7",	-- Fuel tank filter is blocked - tank 8
    "sim/operation/failures/rel_fuel_block8",	-- Fuel tank filter is blocked - tank 9
    "sim/operation/failures/rel_vasi",	-- VASIs Inoperative
    "sim/operation/failures/rel_rwy_lites",	-- Runway lites Inoperative
    "sim/operation/failures/rel_bird_strike",	-- Bird has hit the plane
    "sim/operation/failures/rel_wind_shear",	-- Wind shear/microburst
    "sim/operation/failures/rel_smoke_cpit",	-- Smoke in cockpit
    "sim/operation/failures/rel_brown_out",	-- Induce dusty brown-out
    "sim/operation/failures/rel_esys",	-- Electrical System (Bus 1)
    "sim/operation/failures/rel_esys2",	-- Electrical System (Bus 2)
    "sim/operation/failures/rel_esys3",	-- Electrical System (Bus 3)
    "sim/operation/failures/rel_esys4",	-- Electrical System (Bus 4)
    "sim/operation/failures/rel_esys5",	-- Electrical System (Bus 5)
    "sim/operation/failures/rel_esys6",	-- Electrical System (Bus 6)
    "sim/operation/failures/rel_invert0",	-- Inverter 1
    "sim/operation/failures/rel_invert1",	-- Inverter 2 (also in 740)
    "sim/operation/failures/rel_gen0_lo",	-- Generator 0 voltage low
    "sim/operation/failures/rel_gen0_hi",	-- Generator 0 voltage hi
    "sim/operation/failures/rel_gen1_lo",	-- Generator 1 voltage low
    "sim/operation/failures/rel_gen1_hi",	-- Generator 1 voltage hi
    "sim/operation/failures/rel_bat0_lo",	-- Battery 0 voltage low
    "sim/operation/failures/rel_bat0_hi",	-- Battery 0 voltage hi
    "sim/operation/failures/rel_bat1_lo",	-- Battery 1 voltage low
    "sim/operation/failures/rel_bat1_hi",	-- Battery 1 voltage hi
    "sim/operation/failures/rel_lites_nav",	-- Nav lights
    "sim/operation/failures/rel_lites_strobe",	-- Strobe lights
    "sim/operation/failures/rel_lites_beac",	-- Beacon lights
    "sim/operation/failures/rel_lites_taxi",	-- Taxi lights
    "sim/operation/failures/rel_lites_land",	-- Landing Lights
    "sim/operation/failures/rel_lites_ins",	-- Instrument Lighting
    "sim/operation/failures/rel_clights",	-- Cockpit Lights
    "sim/operation/failures/rel_lites_hud",	-- HUD lights
    "sim/operation/failures/rel_stbaug",	-- Stability Augmentation
    "sim/operation/failures/rel_servo_rudd",	-- autopilot servos failed - rudder/yaw damper
    "sim/operation/failures/rel_otto",	-- AutoPilot (Computer)
    "sim/operation/failures/rel_auto_runaway",	-- AutoPilot (Runaway!!!)
    "sim/operation/failures/rel_auto_servos",	-- AutoPilot (Servos)
    "sim/operation/failures/rel_servo_ailn",	-- autopilot servos failed - ailerons
    "sim/operation/failures/rel_servo_elev",	-- autopilot servos failed - elevators
    "sim/operation/failures/rel_servo_thro",	-- autopilot servos failed - throttles
    "sim/operation/failures/rel_fc_rud_L",	-- Yaw Left Control
    "sim/operation/failures/rel_fc_rud_R",	-- Yaw Right control
    "sim/operation/failures/rel_fc_ail_L",	-- Roll left control
    "sim/operation/failures/rel_fc_ail_R",	-- Roll Right Control
    "sim/operation/failures/rel_fc_elv_U",	-- Pitch Up Control
    "sim/operation/failures/rel_fc_elv_D",	-- Pitch Down Control
    "sim/operation/failures/rel_trim_rud",	-- Yaw Trim
    "sim/operation/failures/rel_trim_ail",	-- roll trim
    "sim/operation/failures/rel_trim_elv",	-- Pitch Trim
    "sim/operation/failures/rel_rud_trim_run",	-- Yaw Trim Runaway
    "sim/operation/failures/rel_ail_trim_run",	-- Pitch Trim Runaway
    "sim/operation/failures/rel_elv_trim_run",	-- Elevator Trim Runaway
    "sim/operation/failures/rel_fc_slt",	-- Slats
    "sim/operation/failures/rel_flap_act",	-- Flap Actuator
    "sim/operation/failures/rel_fc_L_flp",	-- Left flap activate
    "sim/operation/failures/rel_fc_R_flp",	-- Right Flap activate
    "sim/operation/failures/rel_L_flp_off",	-- Left flap remove
    "sim/operation/failures/rel_R_flp_off",	-- Right flap remove
    "sim/operation/failures/rel_gear_act",	-- Landing Gear actuator
    "sim/operation/failures/rel_gear_ind",	-- Landing Gear indicator
    "sim/operation/failures/rel_lbrakes",	-- Left Brakes
    "sim/operation/failures/rel_rbrakes",	-- Right Brakes
    "sim/operation/failures/rel_lagear1",	-- Landing Gear 1 retract
    "sim/operation/failures/rel_lagear2",	-- Landing Gear 2 retract
    "sim/operation/failures/rel_lagear3",	-- Landing Gear 3 retract
    "sim/operation/failures/rel_lagear4",	-- Landing Gear 4 retract
    "sim/operation/failures/rel_lagear5",	-- Landing Gear 5 retract
    "sim/operation/failures/rel_collapse1",	-- Landing gear 1 gear collapse
    "sim/operation/failures/rel_collapse2",	-- Landing gear 2 gear collapse
    "sim/operation/failures/rel_collapse3",	-- Landing gear 3 gear collapse
    "sim/operation/failures/rel_collapse4",	-- Landing gear 4 gear collapse
    "sim/operation/failures/rel_collapse5",	-- Landing gear 5 gear collapse
    "sim/operation/failures/rel_collapse6",	-- Landing gear 6 gear collapse
    "sim/operation/failures/rel_collapse7",	-- Landing gear 7 gear collapse
    "sim/operation/failures/rel_collapse8",	-- Landing gear 8 gear collapse
    "sim/operation/failures/rel_collapse9",	-- Landing gear 9 gear collapse
    "sim/operation/failures/rel_collapse10",	-- Landing gear 10 gear collapse
    "sim/operation/failures/rel_tire1",	-- Landing gear 1 tire blowout
    "sim/operation/failures/rel_tire2",	-- Landing gear 2 tire blowout
    "sim/operation/failures/rel_tire3",	-- Landing gear 3 tire blowout
    "sim/operation/failures/rel_tire4",	-- Landing gear 4 tire blowout
    "sim/operation/failures/rel_tire5",	-- Landing gear 5 tire blowout
    "sim/operation/failures/rel_HVAC",	-- air conditioning failed
    "sim/operation/failures/rel_bleed_air_lft",	-- The left engine is not providing enough pressure
    "sim/operation/failures/rel_bleed_air_rgt",	-- The right engine is not providing enough pressure
    "sim/operation/failures/rel_APU_press",	-- APU is not providing bleed air for engine start or pressurization
    "sim/operation/failures/rel_depres_slow",	-- Slow cabin leak - descend or black out
    "sim/operation/failures/rel_depres_fast",	-- catastrophic decompression - yer dead
    "sim/operation/failures/rel_hydpmp_ele",	-- Hydraulic pump (electric)
    "sim/operation/failures/rel_hydpmp",	-- Hydraulic System 1 (pump fail)
    "sim/operation/failures/rel_hydpmp2",	-- Hydraulic System 2 (pump fail)
    "sim/operation/failures/rel_hydpmp3",	-- Hydraulic System 3 (pump fail)
    "sim/operation/failures/rel_hydpmp4",	-- Hydraulic System 4 (pump fail)
    "sim/operation/failures/rel_hydpmp5",	-- Hydraulic System 5 (pump fail)
    "sim/operation/failures/rel_hydpmp6",	-- Hydraulic System 6 (pump fail)
    "sim/operation/failures/rel_hydpmp7",	-- Hydraulic System 7 (pump fail)
    "sim/operation/failures/rel_hydpmp8",	-- Hydraulic System 8 (pump fail)
    "sim/operation/failures/rel_hydleak",	-- Hydraulic System 1 (leak)
    "sim/operation/failures/rel_hydleak2",	-- Hydraulic System 2 (leak)
    "sim/operation/failures/rel_hydoverp",	-- Hydraulic System 1 (over pressure)
    "sim/operation/failures/rel_hydoverp2",	-- Hydraulic System 2 (over pressure)
    "sim/operation/failures/rel_throt_lo",	-- Throttle inop giving min thrust
    "sim/operation/failures/rel_throt_hi",	-- Throttle inop giving max thrust
    "sim/operation/failures/rel_fc_thr",	-- Throttle failure at current position
    "sim/operation/failures/rel_prop_sync",	-- Prop sync
    "sim/operation/failures/rel_feather",	-- Autofeather system inop
    "sim/operation/failures/rel_trotor",	-- Tail rotor transmission
    "sim/operation/failures/rel_antice",	-- Anti-ice
    "sim/operation/failures/rel_ice_detect",	-- Ice detector
    "sim/operation/failures/rel_ice_pitot_heat1",	-- Pitot heat 1
    "sim/operation/failures/rel_ice_pitot_heat2",	-- Pitot heat 2
    "sim/operation/failures/rel_ice_static_heat",	-- Static heat 1
    "sim/operation/failures/rel_ice_static_heat2",	-- Static heat 2
    "sim/operation/failures/rel_ice_AOA_heat",	-- AOA indicator heat
    "sim/operation/failures/rel_ice_AOA_heat2",	-- AOA indicator heat
    "sim/operation/failures/rel_ice_window_heat",	-- Window Heat
    "sim/operation/failures/rel_ice_surf_boot",	-- Surface Boot - Deprecated - Do Not Use
    "sim/operation/failures/rel_ice_surf_heat",	-- Surface Heat
    "sim/operation/failures/rel_ice_surf_heat2",	-- Surface Heat
    "sim/operation/failures/rel_ice_brake_heat",	-- Brakes anti-ice
    "sim/operation/failures/rel_ice_alt_air1",	-- Alternate Air
    "sim/operation/failures/rel_ice_alt_air2",	-- Alternate Air
    "sim/operation/failures/rel_vacuum",	-- Vacuum System 1 - Pump Failure
    "sim/operation/failures/rel_vacuum2",	-- Vacuum System 2 - Pump Failure
    "sim/operation/failures/rel_elec_gyr",	-- Electric gyro system 1 - gyro motor Failure
    "sim/operation/failures/rel_elec_gyr2",	-- Electric gyro system 2 - gyro motor Failure
    "sim/operation/failures/rel_pitot",	-- Pitot 1 - Blockage
    "sim/operation/failures/rel_pitot2",	-- Pitot 2 - Blockage
    "sim/operation/failures/rel_static",	-- Static 1 - Blockage
    "sim/operation/failures/rel_static2",	-- Static 2 - Blockage
    "sim/operation/failures/rel_static1_err",	-- Static system 1 - Error
    "sim/operation/failures/rel_static2_err",	-- Static system 2 - Error
    "sim/operation/failures/rel_g_oat",	-- OAT
    "sim/operation/failures/rel_g_fuel",	-- fuel quantity
    "sim/operation/failures/rel_ss_asi",	-- Airspeed Indicator (Pilot)
    "sim/operation/failures/rel_ss_ahz",	-- Artificial Horizon (Pilot)
    "sim/operation/failures/rel_ss_alt",	-- Altimeter (Pilot)
    "sim/operation/failures/rel_ss_tsi",	-- Turn indicator (Pilot)
    "sim/operation/failures/rel_ss_dgy",	-- Directional Gyro (Pilot)
    "sim/operation/failures/rel_ss_vvi",	-- Vertical Velocity Indicator (Pilot)
    "sim/operation/failures/rel_cop_asi",	-- Airspeed Indicator (Copilot)
    "sim/operation/failures/rel_cop_ahz",	-- Artificial Horizon (Copilot)
    "sim/operation/failures/rel_cop_alt",	-- Altimeter (Copilot)
    "sim/operation/failures/rel_cop_tsi",	-- Turn indicator (Copilot)
    "sim/operation/failures/rel_cop_dgy",	-- Directional Gyro (Copilot)
    "sim/operation/failures/rel_cop_vvi",	-- Vertical Velocity Indicator (Copilot)
    "sim/operation/failures/rel_efis_1",	-- Primary EFIS
    "sim/operation/failures/rel_efis_2",	-- Secondary EFIS
    "sim/operation/failures/rel_AOA",	-- AOA
    "sim/operation/failures/rel_stall_warn",	-- Stall warning has failed
    "sim/operation/failures/rel_gear_warning",	-- gear warning audio is broken
    "sim/operation/failures/rel_navcom1",	-- Nav and com 1 radio
    "sim/operation/failures/rel_navcom2",	-- Nav and com 2 radio
    "sim/operation/failures/rel_nav1",	-- Nav-1 radio
    "sim/operation/failures/rel_nav2",	-- Nav-2 radio
    "sim/operation/failures/rel_com1",	-- Com-1 radio
    "sim/operation/failures/rel_com2",	-- Com-2 radio
    "sim/operation/failures/rel_adf1",	-- ADF 1 (only one ADF failure in 830!)
    "sim/operation/failures/rel_adf2",	-- ADF 2
    "sim/operation/failures/rel_gps",	-- GPS
    "sim/operation/failures/rel_gps2",	-- GPS
    "sim/operation/failures/rel_dme",	-- DME
    "sim/operation/failures/rel_loc",	-- Localizer
    "sim/operation/failures/rel_gls",	-- Glide Slope
    "sim/operation/failures/rel_gp",	-- WAAS GPS receiver
    "sim/operation/failures/rel_xpndr",	-- Transponder failure
    "sim/operation/failures/rel_marker",	-- Marker Beacons
    "sim/operation/failures/rel_RPM_ind_0",	-- Panel Indicator Inop - rpm engine 1
    "sim/operation/failures/rel_RPM_ind_1",	-- Panel Indicator Inop - rpm engine 2
    "sim/operation/failures/rel_N1_ind0",	-- Panel Indicator Inop - n1 engine 1
    "sim/operation/failures/rel_N1_ind1",	-- Panel Indicator Inop - n1 engine 2
    "sim/operation/failures/rel_N2_ind0",	-- Panel Indicator Inop - n2 engine 1
    "sim/operation/failures/rel_N2_ind1",	-- Panel Indicator Inop - n2 engine 2
    "sim/operation/failures/rel_MP_ind_0",	-- Panel Indicator Inop - mp engine 1
    "sim/operation/failures/rel_MP_ind_1",	-- Panel Indicator Inop - mp engine 2
    "sim/operation/failures/rel_TRQind0",	-- Panel Indicator Inop - trq engine 1
    "sim/operation/failures/rel_TRQind1",	-- Panel Indicator Inop - trq engine 2
    "sim/operation/failures/rel_EPRind0",	-- Panel Indicator Inop - epr engine 1
    "sim/operation/failures/rel_EPRind1",	-- Panel Indicator Inop - epr engine 2
    "sim/operation/failures/rel_CHT_ind_0",	-- Panel Indicator Inop - cht engine 1
    "sim/operation/failures/rel_CHT_ind_1",	-- Panel Indicator Inop - cht engine 2
    "sim/operation/failures/rel_ITTind0",	-- Panel Indicator Inop - itt engine 1
    "sim/operation/failures/rel_ITTind1",	-- Panel Indicator Inop - itt engine 2
    "sim/operation/failures/rel_EGT_ind_0",	-- Panel Indicator Inop - egt engine 1
    "sim/operation/failures/rel_EGT_ind_1",	-- Panel Indicator Inop - egt engine 2
    "sim/operation/failures/rel_FF_ind0",	-- Panel Indicator Inop - ff engine 1
    "sim/operation/failures/rel_FF_ind1",	-- Panel Indicator Inop - ff engine 2
    "sim/operation/failures/rel_fp_ind_0",	-- Panel Indicator Inop - Fuel Pressure 1
    "sim/operation/failures/rel_fp_ind_1",	-- Panel Indicator Inop - Fuel Pressure 2
    "sim/operation/failures/rel_oilp_ind_0",	-- Panel Indicator Inop - Oil Pressure 1
    "sim/operation/failures/rel_oilp_ind_1",	-- Panel Indicator Inop - Oil Pressure 2
    "sim/operation/failures/rel_oilt_ind_0",	-- Panel Indicator Inop - Oil Temperature 1
    "sim/operation/failures/rel_oilt_ind_1",	-- Panel Indicator Inop - Oil Temperature 2
    "sim/operation/failures/rel_g430_gps1",	-- G430 GPS 1 Inop
    "sim/operation/failures/rel_g430_gps2",	-- G430 GPS 2 Inop
    "sim/operation/failures/rel_g430_rad1_tune",	-- G430 Nav/Com Tuner 1 Inop
    "sim/operation/failures/rel_g430_rad2_tune",	-- G430 Nav/Com Tuner 2 Inop
    "sim/operation/failures/rel_g_gia1",	-- GIA 1
    "sim/operation/failures/rel_g_gia2",	-- GIA 2
    "sim/operation/failures/rel_g_gea",	-- gea
    "sim/operation/failures/rel_adc_comp",	-- air data computer
    "sim/operation/failures/rel_g_arthorz",	-- AHRS
    "sim/operation/failures/rel_g_asi",	-- airspeed
    "sim/operation/failures/rel_g_alt",	-- altimeter
    "sim/operation/failures/rel_g_magmtr",	-- magnetometer
    "sim/operation/failures/rel_g_vvi",	-- vvi
--    "sim/operation/failures/rel_g_navrad1",	-- nav radio 1 - removed from 10.00 - 10.36, compatibility only in 10.40 - DO NOT USE - use rel_nav1
--    "sim/operation/failures/rel_g_navrad2",	-- nav radio 2 - removed from 10.00 - 10.36, compatibility only in 10.40 - DO NOT USE - use rel_nav2
--    "sim/operation/failures/rel_g_comrad1",	-- com radio 1 - removed from 10.00 - 10.36, compatibility only in 10.40 - DO NOT USE - use rel_com1
--    "sim/operation/failures/rel_g_comrad2",	-- com radio 2 - removed from 10.00 - 10.36, compatibility only in 10.40 - DO NOT USE - use rel_com2
--    "sim/operation/failures/rel_g_xpndr",	-- transponder removed from 10.00 - 10.36, compatibility only in 10.40+ - DO NOT USE - use rel_xpndr
    "sim/operation/failures/rel_g_gen1",	-- generator amperage 1
    "sim/operation/failures/rel_g_gen2",	-- generator amperage 2
    "sim/operation/failures/rel_g_bat1",	-- battery voltage 1
    "sim/operation/failures/rel_g_bat2",	-- battery voltage 2
    "sim/operation/failures/rel_g_bus1",	-- bus voltage 1
    "sim/operation/failures/rel_g_bus2",	-- bus voltage 2
    "sim/operation/failures/rel_g_mfd",	-- MFD screen failure
    "sim/operation/failures/rel_g_pfd",	-- PFD screen failure
    "sim/operation/failures/rel_g_pfd2",	-- PFD2 screen failure
    "sim/operation/failures/rel_magLFT0",	-- Left Magneto Fail - engine 1
    "sim/operation/failures/rel_magLFT1",	-- Left Magneto Fail - engine 2
    "sim/operation/failures/rel_magLFT2",	-- Left Magneto Fail - engine 3
    "sim/operation/failures/rel_magLFT3",	-- Left Magneto Fail - engine 4
    "sim/operation/failures/rel_magLFT4",	-- Left Magneto Fail - engine 5
    "sim/operation/failures/rel_magLFT5",	-- Left Magneto Fail - engine 6
    "sim/operation/failures/rel_magLFT6",	-- Left Magneto Fail - engine 7
    "sim/operation/failures/rel_magLFT7",	-- Left Magneto Fail - engine 8
    "sim/operation/failures/rel_magRGT0",	-- Right Magneto Fail - engine 1
    "sim/operation/failures/rel_magRGT1",	-- Right Magneto Fail - engine 2
    "sim/operation/failures/rel_magRGT2",	-- Right Magneto Fail - engine 3
    "sim/operation/failures/rel_magRGT3",	-- Right Magneto Fail - engine 4
    "sim/operation/failures/rel_magRGT4",	-- Right Magneto Fail - engine 5
    "sim/operation/failures/rel_magRGT5",	-- Right Magneto Fail - engine 6
    "sim/operation/failures/rel_magRGT6",	-- Right Magneto Fail - engine 7
    "sim/operation/failures/rel_magRGT7",	-- Right Magneto Fail - engine 8
    "sim/operation/failures/rel_engfir0",	-- Engine Failure - engine 1 Fire
    "sim/operation/failures/rel_engfir1",	-- Engine Failure - engine 2 Fire
    "sim/operation/failures/rel_engfir2",	-- Engine Failure - engine 3 Fire
    "sim/operation/failures/rel_engfir3",	-- Engine Failure - engine 4 Fire
    "sim/operation/failures/rel_engfir4",	-- Engine Failure - engine 5 Fire
    "sim/operation/failures/rel_engfir5",	-- Engine Failure - engine 6 Fire
    "sim/operation/failures/rel_engfir6",	-- Engine Failure - engine 7 Fire
    "sim/operation/failures/rel_engfir7",	-- Engine Failure - engine 8 Fire
    "sim/operation/failures/rel_engfla0",	-- Engine Failure - engine 1 Flameout
    "sim/operation/failures/rel_engfla1",	-- Engine Failure - engine 2 Flameout
    "sim/operation/failures/rel_engfla2",	-- Engine Failure - engine 3 Flameout
    "sim/operation/failures/rel_engfla3",	-- Engine Failure - engine 4 Flameout
    "sim/operation/failures/rel_engfla4",	-- Engine Failure - engine 5 Flameout
    "sim/operation/failures/rel_engfla5",	-- Engine Failure - engine 6 Flameout
    "sim/operation/failures/rel_engfla6",	-- Engine Failure - engine 7 Flameout
    "sim/operation/failures/rel_engfla7",	-- Engine Failure - engine 8 Flameout
    "sim/operation/failures/rel_engfai0",	-- Engine Failure - engine 1 loss of power without smoke
    "sim/operation/failures/rel_engfai1",	-- Engine Failure - engine 2
    "sim/operation/failures/rel_engfai2",	-- Engine Failure - engine 3
    "sim/operation/failures/rel_engfai3",	-- Engine Failure - engine 4
    "sim/operation/failures/rel_engfai4",	-- Engine Failure - engine 5
    "sim/operation/failures/rel_engfai5",	-- Engine Failure - engine 6
    "sim/operation/failures/rel_engfai6",	-- Engine Failure - engine 7
    "sim/operation/failures/rel_engfai7",	-- Engine Failure - engine 8
    "sim/operation/failures/rel_engsep0",	-- Engine Separation - engine 1
    "sim/operation/failures/rel_engsep1",	-- Engine Separation - engine 2
    "sim/operation/failures/rel_engsep2",	-- Engine Separation - engine 3
    "sim/operation/failures/rel_engsep3",	-- Engine Separation - engine 4
    "sim/operation/failures/rel_engsep4",	-- Engine Separation - engine 5
    "sim/operation/failures/rel_engsep5",	-- Engine Separation - engine 6
    "sim/operation/failures/rel_engsep6",	-- Engine Separation - engine 7
    "sim/operation/failures/rel_engsep7",	-- Engine Separation - engine 8
    "sim/operation/failures/rel_fuepmp0",	-- Fuel Pump Inop - engine 1 (engine driven)
    "sim/operation/failures/rel_fuepmp1",	-- Fuel Pump Inop - engine 2 (engine driven)
    "sim/operation/failures/rel_fuepmp2",	-- Fuel Pump Inop - engine 3 (engine driven)
    "sim/operation/failures/rel_fuepmp3",	-- Fuel Pump Inop - engine 4 (engine driven)
    "sim/operation/failures/rel_fuepmp4",	-- Fuel Pump Inop - engine 5 (engine driven)
    "sim/operation/failures/rel_fuepmp5",	-- Fuel Pump Inop - engine 6 (engine driven)
    "sim/operation/failures/rel_fuepmp6",	-- Fuel Pump Inop - engine 7 (engine driven)
    "sim/operation/failures/rel_fuepmp7",	-- Fuel Pump Inop - engine 8 (engine driven)
    "sim/operation/failures/rel_ele_fuepmp0",	-- Fuel Pump - engine 1 (electric driven)
    "sim/operation/failures/rel_ele_fuepmp1",	-- Fuel Pump - engine 2 (electric driven)
    "sim/operation/failures/rel_ele_fuepmp2",	-- Fuel Pump - engine 3 (electric driven)
    "sim/operation/failures/rel_ele_fuepmp3",	-- Fuel Pump - engine 4 (electric driven)
    "sim/operation/failures/rel_ele_fuepmp4",	-- Fuel Pump - engine 5 (electric driven)
    "sim/operation/failures/rel_ele_fuepmp5",	-- Fuel Pump - engine 6 (electric driven)
    "sim/operation/failures/rel_ele_fuepmp6",	-- Fuel Pump - engine 7 (electric driven)
    "sim/operation/failures/rel_ele_fuepmp7",	-- Fuel Pump - engine 8 (electric driven)
    "sim/operation/failures/rel_eng_lo0",	-- Fuel Pump Low Pressure - engine 1 (engine driven)
    "sim/operation/failures/rel_eng_lo1",	-- Fuel Pump Low Pressure - engine 2 (engine driven)
    "sim/operation/failures/rel_eng_lo2",	-- Fuel Pump Low Pressure - engine 3 (engine driven)
    "sim/operation/failures/rel_eng_lo3",	-- Fuel Pump Low Pressure - engine 4 (engine driven)
    "sim/operation/failures/rel_eng_lo4",	-- Fuel Pump Low Pressure - engine 5 (engine driven)
    "sim/operation/failures/rel_eng_lo5",	-- Fuel Pump Low Pressure - engine 6 (engine driven)
    "sim/operation/failures/rel_eng_lo6",	-- Fuel Pump Low Pressure - engine 7 (engine driven)
    "sim/operation/failures/rel_eng_lo7",	-- Fuel Pump Low Pressure - engine 8 (engine driven)
    "sim/operation/failures/rel_airres0",	-- Airflow restricted - Engine 1
    "sim/operation/failures/rel_airres1",	-- Airflow restricted - Engine 2
    "sim/operation/failures/rel_airres2",	-- Airflow restricted - Engine 3
    "sim/operation/failures/rel_airres3",	-- Airflow restricted - Engine 4
    "sim/operation/failures/rel_airres4",	-- Airflow restricted - Engine 5
    "sim/operation/failures/rel_airres5",	-- Airflow restricted - Engine 6
    "sim/operation/failures/rel_airres6",	-- Airflow restricted - Engine 7
    "sim/operation/failures/rel_airres7",	-- Airflow restricted - Engine 8
    "sim/operation/failures/rel_fuelfl0",	-- Fuel Flow Fluctuation - engine 1
    "sim/operation/failures/rel_fuelfl1",	-- Fuel Flow Fluctuation - engine 2
    "sim/operation/failures/rel_fuelfl2",	-- Fuel Flow Fluctuation - engine 3
    "sim/operation/failures/rel_fuelfl3",	-- Fuel Flow Fluctuation - engine 4
    "sim/operation/failures/rel_fuelfl4",	-- Fuel Flow Fluctuation - engine 5
    "sim/operation/failures/rel_fuelfl5",	-- Fuel Flow Fluctuation - engine 6
    "sim/operation/failures/rel_fuelfl6",	-- Fuel Flow Fluctuation - engine 7
    "sim/operation/failures/rel_fuelfl7",	-- Fuel Flow Fluctuation - engine 8
    "sim/operation/failures/rel_comsta0",	-- Engine Compressor Stall - engine 1
    "sim/operation/failures/rel_comsta1",	-- Engine Compressor Stall - engine 2
    "sim/operation/failures/rel_comsta2",	-- Engine Compressor Stall - engine 3
    "sim/operation/failures/rel_comsta3",	-- Engine Compressor Stall - engine 4
    "sim/operation/failures/rel_comsta4",	-- Engine Compressor Stall - engine 5
    "sim/operation/failures/rel_comsta5",	-- Engine Compressor Stall - engine 6
    "sim/operation/failures/rel_comsta6",	-- Engine Compressor Stall - engine 7
    "sim/operation/failures/rel_comsta7",	-- Engine Compressor Stall - engine 8
    "sim/operation/failures/rel_startr0",	-- Starter - engine 1
    "sim/operation/failures/rel_startr1",	-- Starter - engine 2
    "sim/operation/failures/rel_startr2",	-- Starter - engine 3
    "sim/operation/failures/rel_startr3",	-- Starter - engine 4
    "sim/operation/failures/rel_startr4",	-- Starter - engine 5
    "sim/operation/failures/rel_startr5",	-- Starter - engine 6
    "sim/operation/failures/rel_startr6",	-- Starter - engine 7
    "sim/operation/failures/rel_startr7",	-- Starter - engine 8
    "sim/operation/failures/rel_ignitr0",	-- Ignitor - engine 1
    "sim/operation/failures/rel_ignitr1",	-- Ignitor - engine 2
    "sim/operation/failures/rel_ignitr2",	-- Ignitor - engine 3
    "sim/operation/failures/rel_ignitr3",	-- Ignitor - engine 4
    "sim/operation/failures/rel_ignitr4",	-- Ignitor - engine 5
    "sim/operation/failures/rel_ignitr5",	-- Ignitor - engine 6
    "sim/operation/failures/rel_ignitr6",	-- Ignitor - engine 7
    "sim/operation/failures/rel_ignitr7",	-- Ignitor - engine 8
    "sim/operation/failures/rel_hunsta0",	-- Hung Start - engine 0
    "sim/operation/failures/rel_hunsta1",	-- Hung Start - engine 1
    "sim/operation/failures/rel_hunsta2",	-- Hung Start - engine 2
    "sim/operation/failures/rel_hunsta3",	-- Hung Start - engine 3
    "sim/operation/failures/rel_hunsta4",	-- Hung Start - engine 4
    "sim/operation/failures/rel_hunsta5",	-- Hung Start - engine 5
    "sim/operation/failures/rel_hunsta6",	-- Hung Start - engine 6
    "sim/operation/failures/rel_hunsta7",	-- Hung Start - engine 7
    "sim/operation/failures/rel_clonoz0",	-- Hung start (clogged nozzles) - Engine 1
    "sim/operation/failures/rel_clonoz1",	-- Hung start (clogged nozzles) - Engine 2
    "sim/operation/failures/rel_clonoz2",	-- Hung start (clogged nozzles) - Engine 3
    "sim/operation/failures/rel_clonoz3",	-- Hung start (clogged nozzles) - Engine 4
    "sim/operation/failures/rel_clonoz4",	-- Hung start (clogged nozzles) - Engine 5
    "sim/operation/failures/rel_clonoz5",	-- Hung start (clogged nozzles) - Engine 6
    "sim/operation/failures/rel_clonoz6",	-- Hung start (clogged nozzles) - Engine 7
    "sim/operation/failures/rel_clonoz7",	-- Hung start (clogged nozzles) - Engine 8
    "sim/operation/failures/rel_hotsta0",	-- Hot Start - engine 0
    "sim/operation/failures/rel_hotsta1",	-- Hot Start - engine 1
    "sim/operation/failures/rel_hotsta2",	-- Hot Start - engine 2
    "sim/operation/failures/rel_hotsta3",	-- Hot Start - engine 3
    "sim/operation/failures/rel_hotsta4",	-- Hot Start - engine 4
    "sim/operation/failures/rel_hotsta5",	-- Hot Start - engine 5
    "sim/operation/failures/rel_hotsta6",	-- Hot Start - engine 6
    "sim/operation/failures/rel_hotsta7",	-- Hot Start - engine 7
    "sim/operation/failures/rel_runITT0",	-- Runway Hot ITT - engine 1
    "sim/operation/failures/rel_runITT1",	-- Runway Hot ITT - engine 2
    "sim/operation/failures/rel_runITT2",	-- Runway Hot ITT - engine 3
    "sim/operation/failures/rel_runITT3",	-- Runway Hot ITT - engine 4
    "sim/operation/failures/rel_runITT4",	-- Runway Hot ITT - engine 5
    "sim/operation/failures/rel_runITT5",	-- Runway Hot ITT - engine 6
    "sim/operation/failures/rel_runITT6",	-- Runway Hot ITT - engine 7
    "sim/operation/failures/rel_runITT7",	-- Runway Hot ITT - engine 8
    "sim/operation/failures/rel_genera0",	-- Generator - engine 1
    "sim/operation/failures/rel_genera1",	-- Generator - engine 2
    "sim/operation/failures/rel_genera2",	-- Generator - engine 3
    "sim/operation/failures/rel_genera3",	-- Generator - engine 4
    "sim/operation/failures/rel_genera4",	-- Generator - engine 5
    "sim/operation/failures/rel_genera5",	-- Generator - engine 6
    "sim/operation/failures/rel_genera6",	-- Generator - engine 7
    "sim/operation/failures/rel_genera7",	-- Generator - engine 8
    "sim/operation/failures/rel_batter0",	-- Battery 1
    "sim/operation/failures/rel_batter1",	-- Battery 2
    "sim/operation/failures/rel_batter2",	-- Battery 3
    "sim/operation/failures/rel_batter3",	-- Battery 4
    "sim/operation/failures/rel_batter4",	-- Battery 5
    "sim/operation/failures/rel_batter5",	-- Battery 6
    "sim/operation/failures/rel_batter6",	-- Battery 7
    "sim/operation/failures/rel_batter7",	-- Battery 8
    "sim/operation/failures/rel_govnr_0",	-- Governor throttle fail - engine 1
    "sim/operation/failures/rel_govnr_1",	-- Governor throttle fail - engine 2
    "sim/operation/failures/rel_govnr_2",	-- Governor throttle fail - engine 3
    "sim/operation/failures/rel_govnr_3",	-- Governor throttle fail - engine 4
    "sim/operation/failures/rel_govnr_4",	-- Governor throttle fail - engine 5
    "sim/operation/failures/rel_govnr_5",	-- Governor throttle fail - engine 6
    "sim/operation/failures/rel_govnr_6",	-- Governor throttle fail - engine 7
    "sim/operation/failures/rel_govnr_7",	-- Governor throttle fail - engine 8
    "sim/operation/failures/rel_fadec_0",	-- Fadec - engine 1
    "sim/operation/failures/rel_fadec_1",	-- Fadec - engine 2
    "sim/operation/failures/rel_fadec_2",	-- Fadec - engine 3
    "sim/operation/failures/rel_fadec_3",	-- Fadec - engine 4
    "sim/operation/failures/rel_fadec_4",	-- Fadec - engine 5
    "sim/operation/failures/rel_fadec_5",	-- Fadec - engine 6
    "sim/operation/failures/rel_fadec_6",	-- Fadec - engine 7
    "sim/operation/failures/rel_fadec_7",	-- Fadec - engine 8
    "sim/operation/failures/rel_oilpmp0",	-- Oil Pump - engine 1
    "sim/operation/failures/rel_oilpmp1",	-- Oil Pump - engine 2
    "sim/operation/failures/rel_oilpmp2",	-- Oil Pump - engine 3
    "sim/operation/failures/rel_oilpmp3",	-- Oil Pump - engine 4
    "sim/operation/failures/rel_oilpmp4",	-- Oil Pump - engine 5
    "sim/operation/failures/rel_oilpmp5",	-- Oil Pump - engine 6
    "sim/operation/failures/rel_oilpmp6",	-- Oil Pump - engine 7
    "sim/operation/failures/rel_oilpmp7",	-- Oil Pump - engine 8
    "sim/operation/failures/rel_chipde0",	-- Chip Detected - engine 1
    "sim/operation/failures/rel_chipde1",	-- Chip Detected - engine 2
    "sim/operation/failures/rel_chipde2",	-- Chip Detected - engine 3
    "sim/operation/failures/rel_chipde3",	-- Chip Detected - engine 4
    "sim/operation/failures/rel_chipde4",	-- Chip Detected - engine 5
    "sim/operation/failures/rel_chipde5",	-- Chip Detected - engine 6
    "sim/operation/failures/rel_chipde6",	-- Chip Detected - engine 7
    "sim/operation/failures/rel_chipde7",	-- Chip Detected - engine 8
    "sim/operation/failures/rel_prpfin0",	-- Prop governor fail to fine - engine 1
    "sim/operation/failures/rel_prpfin1",	-- Prop governor fail to fine - engine 2
    "sim/operation/failures/rel_prpfin2",	-- Prop governor fail to fine - engine 3
    "sim/operation/failures/rel_prpfin3",	-- Prop governor fail to fine - engine 4
    "sim/operation/failures/rel_prpfin4",	-- Prop governor fail to fine - engine 5
    "sim/operation/failures/rel_prpfin5",	-- Prop governor fail to fine - engine 6
    "sim/operation/failures/rel_prpfin6",	-- Prop governor fail to fine - engine 7
    "sim/operation/failures/rel_prpfin7",	-- Prop governor fail to fine - engine 8
    "sim/operation/failures/rel_prpcrs0",	-- Prop governor fail to coarse - engine 1
    "sim/operation/failures/rel_prpcrs1",	-- Prop governor fail to coarse - engine 2
    "sim/operation/failures/rel_prpcrs2",	-- Prop governor fail to coarse - engine 3
    "sim/operation/failures/rel_prpcrs3",	-- Prop governor fail to coarse - engine 4
    "sim/operation/failures/rel_prpcrs4",	-- Prop governor fail to coarse - engine 5
    "sim/operation/failures/rel_prpcrs5",	-- Prop governor fail to coarse - engine 6
    "sim/operation/failures/rel_prpcrs6",	-- Prop governor fail to coarse - engine 7
    "sim/operation/failures/rel_prpcrs7",	-- Prop governor fail to coarse - engine 8
    "sim/operation/failures/rel_pshaft0",	-- Drive Shaft - engine 1
    "sim/operation/failures/rel_pshaft1",	-- Drive Shaft - engine 2
    "sim/operation/failures/rel_pshaft2",	-- Drive Shaft - engine 3
    "sim/operation/failures/rel_pshaft3",	-- Drive Shaft - engine 4
    "sim/operation/failures/rel_pshaft4",	-- Drive Shaft - engine 5
    "sim/operation/failures/rel_pshaft5",	-- Drive Shaft - engine 6
    "sim/operation/failures/rel_pshaft6",	-- Drive Shaft - engine 7
    "sim/operation/failures/rel_pshaft7",	-- Drive Shaft - engine 8
    "sim/operation/failures/rel_seize_0",	-- Engine Seize - engine 1
    "sim/operation/failures/rel_seize_1",	-- Engine Seize - engine 2
    "sim/operation/failures/rel_seize_2",	-- Engine Seize - engine 3
    "sim/operation/failures/rel_seize_3",	-- Engine Seize - engine 4
    "sim/operation/failures/rel_seize_4",	-- Engine Seize - engine 5
    "sim/operation/failures/rel_seize_5",	-- Engine Seize - engine 6
    "sim/operation/failures/rel_seize_6",	-- Engine Seize - engine 7
    "sim/operation/failures/rel_seize_7",	-- Engine Seize - engine 8
    "sim/operation/failures/rel_revers0",	-- Thrust Reversers Inop - engine 1
    "sim/operation/failures/rel_revers1",	-- Thrust Reversers Inop - engine 2
    "sim/operation/failures/rel_revers2",	-- Thrust Reversers Inop - engine 3
    "sim/operation/failures/rel_revers3",	-- Thrust Reversers Inop - engine 4
    "sim/operation/failures/rel_revers4",	-- Thrust Reversers Inop - engine 5
    "sim/operation/failures/rel_revers5",	-- Thrust Reversers Inop - engine 6
    "sim/operation/failures/rel_revers6",	-- Thrust Reversers Inop - engine 7
    "sim/operation/failures/rel_revers7",	-- Thrust Reversers Inop - engine 8
    "sim/operation/failures/rel_revdep0",	-- Thrust Reversers Deploy - engine 1
    "sim/operation/failures/rel_revdep1",	-- Thrust Reversers Deploy - engine 2
    "sim/operation/failures/rel_revdep2",	-- Thrust Reversers Deploy - engine 3
    "sim/operation/failures/rel_revdep3",	-- Thrust Reversers Deploy - engine 4
    "sim/operation/failures/rel_revdep4",	-- Thrust Reversers Deploy - engine 5
    "sim/operation/failures/rel_revdep5",	-- Thrust Reversers Deploy - engine 6
    "sim/operation/failures/rel_revdep6",	-- Thrust Reversers Deploy - engine 7
    "sim/operation/failures/rel_revdep7",	-- Thrust Reversers Deploy - engine 8
    "sim/operation/failures/rel_revloc0",	-- Thrust Reversers Locked - engine 1
    "sim/operation/failures/rel_revloc1",	-- Thrust Reversers Locked - engine 2
    "sim/operation/failures/rel_revloc2",	-- Thrust Reversers Locked - engine 3
    "sim/operation/failures/rel_revloc3",	-- Thrust Reversers Locked - engine 4
    "sim/operation/failures/rel_revloc4",	-- Thrust Reversers Locked - engine 5
    "sim/operation/failures/rel_revloc5",	-- Thrust Reversers Locked - engine 6
    "sim/operation/failures/rel_revloc6",	-- Thrust Reversers Locked - engine 7
    "sim/operation/failures/rel_revloc7",	-- Thrust Reversers Locked - engine 8
    "sim/operation/failures/rel_aftbur0",	-- Afterburners - engine 1
    "sim/operation/failures/rel_aftbur1",	-- Afterburners - engine 2
    "sim/operation/failures/rel_aftbur2",	-- Afterburners - engine 3
    "sim/operation/failures/rel_aftbur3",	-- Afterburners - engine 4
    "sim/operation/failures/rel_aftbur4",	-- Afterburners - engine 5
    "sim/operation/failures/rel_aftbur5",	-- Afterburners - engine 6
    "sim/operation/failures/rel_aftbur6",	-- Afterburners - engine 7
    "sim/operation/failures/rel_aftbur7",	-- Afterburners - engine 8
    "sim/operation/failures/rel_ice_inlet_heat",	-- Inlet heat, engine 1
    "sim/operation/failures/rel_ice_inlet_heat2",	-- Inlet heat, engine 2
    "sim/operation/failures/rel_ice_inlet_heat3",	-- Inlet heat, engine 3
    "sim/operation/failures/rel_ice_inlet_heat4",	-- Inlet heat, engine 4
    "sim/operation/failures/rel_ice_inlet_heat5",	-- Inlet heat, engine 5
    "sim/operation/failures/rel_ice_inlet_heat6",	-- Inlet heat, engine 6
    "sim/operation/failures/rel_ice_inlet_heat7",	-- Inlet heat, engine 7
    "sim/operation/failures/rel_ice_inlet_heat8",	-- Inlet heat, engine 8
    "sim/operation/failures/rel_ice_prop_heat",	-- Prop Heat, engine 1
    "sim/operation/failures/rel_ice_prop_heat2",	-- Prop Heat, engine 2
    "sim/operation/failures/rel_ice_prop_heat3",	-- Prop Heat, engine 3
    "sim/operation/failures/rel_ice_prop_heat4",	-- Prop Heat, engine 4
    "sim/operation/failures/rel_ice_prop_heat5",	-- Prop Heat, engine 5
    "sim/operation/failures/rel_ice_prop_heat6",	-- Prop Heat, engine 6
    "sim/operation/failures/rel_ice_prop_heat7",	-- Prop Heat, engine 7
    "sim/operation/failures/rel_ice_prop_heat8",	-- Prop Heat, engine 8
    "sim/operation/failures/rel_wing1L",	-- Wing separations - left wing 1
    "sim/operation/failures/rel_wing1R",	-- Wing separations - right wing 1
    "sim/operation/failures/rel_wing2L",	-- Wing separations - left wing 2
    "sim/operation/failures/rel_wing2R",	-- Wing separations - right wing 2
    "sim/operation/failures/rel_wing3L",	-- Wing separations - left wing 3
    "sim/operation/failures/rel_wing3R",	-- Wing separations - right wing 3
    "sim/operation/failures/rel_wing4L",	-- Wing separations - left wing 4
    "sim/operation/failures/rel_wing4R",	-- Wing separations - right wing 4
    "sim/operation/failures/rel_hstbL",	-- Left horizontal stabilizer separate
    "sim/operation/failures/rel_hstbR",	-- Right horizontal stabilizer separate
    "sim/operation/failures/rel_vstb1",	-- Vertical stabilizer 1 separate
    "sim/operation/failures/rel_vstb2",	-- Vertical stabilizer 2 separate
    "sim/operation/failures/rel_mwing1",	-- Misc wing 1 separate
    "sim/operation/failures/rel_mwing2",	-- Misc wing 2 separate
    "sim/operation/failures/rel_mwing3",	-- Misc wing 3 separate
    "sim/operation/failures/rel_mwing4",	-- Misc wing 4 separate
    "sim/operation/failures/rel_mwing5",	-- Misc wing 5 separate
    "sim/operation/failures/rel_mwing6",	-- Misc wing 6 separate
    "sim/operation/failures/rel_mwing7",	-- Misc wing 7 separate
    "sim/operation/failures/rel_mwing8",	-- Misc wing 8 separate
    "sim/operation/failures/rel_pyl1a",	-- Engine Pylon 1a Separate
    "sim/operation/failures/rel_pyl2a",	-- Engine Pylon 2a Separate
    "sim/operation/failures/rel_pyl3a",	-- Engine Pylon 3a Separate
    "sim/operation/failures/rel_pyl4a",	-- Engine Pylon 4a Separate
    "sim/operation/failures/rel_pyl5a",	-- Engine Pylon 5a Separate
    "sim/operation/failures/rel_pyl6a",	-- Engine Pylon 6a Separate
    "sim/operation/failures/rel_pyl7a",	-- Engine Pylon 7a Separate
    "sim/operation/failures/rel_pyl8a",	-- Engine Pylon 8a Separate
    "sim/operation/failures/rel_pyl1b",	-- Engine Pylon 1b Separate
    "sim/operation/failures/rel_pyl2b",	-- Engine Pylon 2b Separate
    "sim/operation/failures/rel_pyl3b",	-- Engine Pylon 3b Separate
    "sim/operation/failures/rel_pyl4b",	-- Engine Pylon 4b Separate
    "sim/operation/failures/rel_pyl5b",	-- Engine Pylon 5b Separate
    "sim/operation/failures/rel_pyl6b",	-- Engine Pylon 6b Separate
    "sim/operation/failures/rel_pyl7b",	-- Engine Pylon 7b Separate
    "sim/operation/failures/rel_pyl8b",	-- Engine Pylon 8b Separate
    "sim/operation/failures/rel_gen_esys",	-- General electrical failure
    "sim/operation/failures/rel_gen_avio",	-- General avionics bus failure
    "sim/operation/failures/rel_apu",	-- APU failure to start or run
    "sim/operation/failures/rel_apu_fire",	-- APU catastrophic failure with fire
}
--[[ Fixed datarefs that need constant monitoring ]]
OnGround = find_dataref("sim/flightmodel/failures/onground_any") -- Repair function
GroundSpeed = find_dataref("sim/flightmodel2/position/groundspeed") -- Repair function
--IsBurningFuel = find_dataref("sim/flightmodel2/engines/engine_is_burning_fuel") -- Inherited from xlua_ncheadset.lua
--NumEngines = find_dataref("sim/aircraft/engine/acf_num_engines") -- Inherited from xlua_ncheadset.lua
Baro_Pilot = find_dataref("sim/cockpit2/gauges/actuators/barometer_setting_in_hg_pilot") -- Barometer synchronization
Baro_CoPilot = find_dataref("sim/cockpit2/gauges/actuators/barometer_setting_in_hg_copilot") -- Barometer synchronization
Baro_Stby = find_dataref("sim/cockpit2/gauges/actuators/barometer_setting_in_hg_stby") -- Barometer synchronization
--[[ Local variables ]]
local Baro_Pilot_Old = Baro_Pilot
local Baro_CoPilot_Old = Baro_CoPilot
local Baro_Stby_Old = Baro_Stby
--[[ Container Table for the Datarefs to be monitored. Datarefs are stored in subtables {dataref,type,{dataref value(s) storage 1 as specified by dataref length}, {dataref value(s) storage 2 as specified by dataref length}, dataref handler} ]]
local MiscUtils_Datarefs = {
"DATAREF",
}
--[[ Menu item table. The first item ALWAYS contains the menu's title! All other items list the menu item's name. ]]
local MiscUtils_Menu_Items = {
"Miscellaneous",  -- Menu title, index 1
" ",        -- Item index: 2
"Synchronize Baros",
-- "Decrement Noise Level (- "..(Preferences_ValGet(MiscUtils_Config_Vars,"NoiseCancelLevelDelta") * 100).." %)",   -- Item index: 7
}
--[[ Menu variables for FFI ]]
local MiscUtils_Menu_ID = nil
local MiscUtils_Menu_Pointer = ffi.new("const char")
--[[

FUNCTIONS

]]
--[[ Determine number of engines running ]]
function AllEnginesRunning()
    local j=0
    for i=0,(NumEngines-1) do if IsBurningFuel[i] == 1 then j = j + 1 end end
    if j == NumEngines then return 1 end
    if j < NumEngines then return 0 end
end
--[[ Synchronize baros ]]
function Sync_Baros()
    if Baro_Pilot ~= Baro_Pilot_Old then
        Baro_CoPilot = Baro_Pilot
        Baro_CoPilot_Old = Baro_CoPilot
        Baro_Stby = Baro_Pilot
        Baro_Stby_Old = Baro_Stby
        Baro_Pilot_Old = Baro_Pilot
    end
    if Baro_CoPilot ~= Baro_CoPilot_Old then
        Baro_Pilot = Baro_CoPilot
        Baro_Pilot_Old = Baro_Pilot
        Baro_Stby = Baro_CoPilot
        Baro_Stby_Old = Baro_Stby
        Baro_CoPilot_Old = Baro_CoPilot
    end
    if Baro_Stby ~= Baro_Stby_Old then
        Baro_Pilot = Baro_Stby
        Baro_Pilot_Old = Baro_Pilot
        Baro_CoPilot = Baro_Stby
        Baro_CoPilot_Old = Baro_CoPilot
        Baro_Stby_Old = Baro_Stby
    end
end
--[[ Main timer ]]
function MiscUtils_MainTimer()
    MiscUtils_Menu_Watchdog(MiscUtils_Menu_Items,2)
    if Preferences_ValGet(MiscUtils_Config_Vars,"SyncBaros") == 1 then Sync_Baros() end
end
--[[

MENU

]]
--[[ Menu callbacks. The functions to run or actions to do when picking any non-title and nonseparator item from the table above ]]
function MiscUtils_Menu_Callbacks(itemref)
    for i=2,#MiscUtils_Menu_Items do
        if itemref == MiscUtils_Menu_Items[i] then
            if i == 2 then
                if OnGround == 1 and GroundSpeed < 0.1 and AllEnginesRunning() == 0 then Dataref_Write(MiscUtils_Datarefs,3,"All") DisplayNotification("All aircraft damage repaired!","Success",5) end
            end
            if i == 3 then
                if Preferences_ValGet(MiscUtils_Config_Vars,"SyncBaros") == 0 then
                    Preferences_ValSet(MiscUtils_Config_Vars,"SyncBaros",1) Sync_Baros() DebugLogOutput("Barometer synchronization: On") DisplayNotification("Barometer synchronization enabled.","Nominal",5)
                else
                    Preferences_ValSet(MiscUtils_Config_Vars,"SyncBaros",0) DebugLogOutput("Barometer synchronization: Off") DisplayNotification("Barometer synchronization disabled.","Nominal",5)
                end
                Preferences_Write(MiscUtils_Config_Vars,Xlua_Utils_PrefsFile)
            end
            MiscUtils_Menu_Watchdog(MiscUtils_Menu_Items,i)
        end
    end
end
--[[ This is the menu watchdog that is used to check an item or change its prefix ]]
function MiscUtils_Menu_Watchdog(intable,index)
    if index == 2 then
        if OnGround == 1 and GroundSpeed < 0.1 and AllEnginesRunning() == 0 then Menu_ChangeItemPrefix(MiscUtils_Menu_ID,index,"Repair All Damage",intable)
        else Menu_ChangeItemPrefix(MiscUtils_Menu_ID,index,"[Can Not Repair]",intable) end
    end
    if index == 3 then
        if Preferences_ValGet(MiscUtils_Config_Vars,"SyncBaros") == 1 then Menu_ChangeItemPrefix(MiscUtils_Menu_ID,index,"[On]",intable)
        else Menu_ChangeItemPrefix(MiscUtils_Menu_ID,index,"[Off]",intable) end
    end
end
--[[ Initialization routine for the menu. WARNING: Takes the menu ID of the main XLua Utils Menu! ]]
function MiscUtils_Menu_Build(ParentMenuID)
    local Menu_Indices = {}
    for i=2,#MiscUtils_Menu_Items do Menu_Indices[i] = 0 end
    if XPLM ~= nil then
        local Menu_Index = nil
        Menu_Index = XPLM.XPLMAppendMenuItem(ParentMenuID,MiscUtils_Menu_Items[1],ffi.cast("void *","None"),1)
        MiscUtils_Menu_ID = XPLM.XPLMCreateMenu(MiscUtils_Menu_Items[1],ParentMenuID,Menu_Index,function(inMenuRef,inItemRef) MiscUtils_Menu_Callbacks(inItemRef) end,ffi.cast("void *",MiscUtils_Menu_Pointer))
        for i=2,#MiscUtils_Menu_Items do
            if MiscUtils_Menu_Items[i] ~= "[Separator]" then
                MiscUtils_Menu_Pointer = MiscUtils_Menu_Items[i]
                Menu_Indices[i] = XPLM.XPLMAppendMenuItem(MiscUtils_Menu_ID,MiscUtils_Menu_Items[i],ffi.cast("void *",MiscUtils_Menu_Pointer),1)
            else
                XPLM.XPLMAppendMenuSeparator(MiscUtils_Menu_ID)
            end
        end
        for i=2,#MiscUtils_Menu_Items do
            if MiscUtils_Menu_Items[i] ~= "[Separator]" then
                MiscUtils_Menu_Watchdog(MiscUtils_Menu_Items,i)
            end
        end
        LogOutput(MiscUtils_Config_Vars[1][1].." Menu initialized!")
    end
end
--[[

INITIALIZATION

]]
--[[ First start of the misc utils module ]]
function MiscUtils_FirstRun()
    Preferences_Write(MiscUtils_Config_Vars,Xlua_Utils_PrefsFile)
    Preferences_Read(Xlua_Utils_PrefsFile,MiscUtils_Config_Vars)
    DrefTable_Read(Dref_List,MiscUtils_Datarefs)
    MiscUtils_Menu_Init(XluaUtils_Menu_ID)
    LogOutput(MiscUtils_Config_Vars[1][1]..": First Run!")
end
--[[ Initializes the misc utils module at every startup ]]
function MiscUtils_Init()
    Preferences_Read(Xlua_Utils_PrefsFile,MiscUtils_Config_Vars)
    DrefTable_Read(Dref_List,MiscUtils_Datarefs)
    --Dataref_Read(MiscUtils_Datarefs,4,"All") -- Populate dataref container with current values as defaults
    Dataref_Read(MiscUtils_Datarefs,3,"All") -- Populate dataref container with current values
    for i=2,#MiscUtils_Datarefs do MiscUtils_Datarefs[i][3][1] = 0 end -- Zero all datarefs
    run_at_interval(MiscUtils_MainTimer,Preferences_ValGet(MiscUtils_Config_Vars,"MainTimerInterval")) -- Timer to monitor airplane status
    LogOutput(MiscUtils_Config_Vars[1][1]..": Initialized!")
end
