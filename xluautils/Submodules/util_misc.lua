--[[

XLuaUtils Module, required by xluautils.lua
Licensed under the EUPL v1.2: https://eupl.eu/

]]
--[[ Table that contains the configuration Variables for the misc utils module ]]
local MiscUtils_Config_Vars = {
{"MISC_UTILS"},
{"MainTimerInterval",1},
{"SyncBaros",0},
{"PowerMonitor",0},
{"PowerMonitorDisplayTime",5},
{"PowerMonitorScalar",1.0},
{"PowerMonitorInputChange",0.005},
{"PowerMonitorFuelUnit","kg"}, -- kg or lbs or gal_avgas or gal_jet or l_avgas or l_jet-a
}
--[[ List of Datarefs used by this module ]]
local Dref_List = {
{"Dref[n]","sim/operation/failures/rel_conlock"},	-- Controls locked
{"Dref[n]","sim/operation/failures/rel_door_open"},	-- Door Open
{"Dref[n]","sim/operation/failures/rel_ex_power_on"},	-- External power is on
{"Dref[n]","sim/operation/failures/rel_pass_o2_on"},	-- Passenger oxygen on
{"Dref[n]","sim/operation/failures/rel_fuelcap"},	-- Fuel Cap left off
{"Dref[n]","sim/operation/failures/rel_fuel_water"},	-- Water in fuel
{"Dref[n]","sim/operation/failures/rel_fuel_type"},	-- Wrong fuel type - JetA for props or Avgas for jets!
{"Dref[n]","sim/operation/failures/rel_fuel_block0"},	-- Fuel tank filter is blocked - tank 1
{"Dref[n]","sim/operation/failures/rel_fuel_block1"},	-- Fuel tank filter is blocked - tank 2
{"Dref[n]","sim/operation/failures/rel_fuel_block2"},	-- Fuel tank filter is blocked - tank 3
{"Dref[n]","sim/operation/failures/rel_fuel_block3"},	-- Fuel tank filter is blocked - tank 4
{"Dref[n]","sim/operation/failures/rel_fuel_block4"},	-- Fuel tank filter is blocked - tank 5
{"Dref[n]","sim/operation/failures/rel_fuel_block5"},	-- Fuel tank filter is blocked - tank 6
{"Dref[n]","sim/operation/failures/rel_fuel_block6"},	-- Fuel tank filter is blocked - tank 7
{"Dref[n]","sim/operation/failures/rel_fuel_block7"},	-- Fuel tank filter is blocked - tank 8
{"Dref[n]","sim/operation/failures/rel_fuel_block8"},	-- Fuel tank filter is blocked - tank 9
{"Dref[n]","sim/operation/failures/rel_vasi"},	-- VASIs Inoperative
{"Dref[n]","sim/operation/failures/rel_rwy_lites"},	-- Runway lites Inoperative
{"Dref[n]","sim/operation/failures/rel_bird_strike"},	-- Bird has hit the plane
{"Dref[n]","sim/operation/failures/rel_wind_shear"},	-- Wind shear/microburst
{"Dref[n]","sim/operation/failures/rel_smoke_cpit"},	-- Smoke in cockpit
{"Dref[n]","sim/operation/failures/rel_brown_out"},	-- Induce dusty brown-out
{"Dref[n]","sim/operation/failures/rel_esys"},	-- Electrical System (Bus 1)
{"Dref[n]","sim/operation/failures/rel_esys2"},	-- Electrical System (Bus 2)
{"Dref[n]","sim/operation/failures/rel_esys3"},	-- Electrical System (Bus 3)
{"Dref[n]","sim/operation/failures/rel_esys4"},	-- Electrical System (Bus 4)
{"Dref[n]","sim/operation/failures/rel_esys5"},	-- Electrical System (Bus 5)
{"Dref[n]","sim/operation/failures/rel_esys6"},	-- Electrical System (Bus 6)
{"Dref[n]","sim/operation/failures/rel_invert0"},	-- Inverter 1
{"Dref[n]","sim/operation/failures/rel_invert1"},	-- Inverter 2 (also in 740)
{"Dref[n]","sim/operation/failures/rel_gen0_lo"},	-- Generator 0 voltage low
{"Dref[n]","sim/operation/failures/rel_gen0_hi"},	-- Generator 0 voltage hi
{"Dref[n]","sim/operation/failures/rel_gen1_lo"},	-- Generator 1 voltage low
{"Dref[n]","sim/operation/failures/rel_gen1_hi"},	-- Generator 1 voltage hi
{"Dref[n]","sim/operation/failures/rel_bat0_lo"},	-- Battery 0 voltage low
{"Dref[n]","sim/operation/failures/rel_bat0_hi"},	-- Battery 0 voltage hi
{"Dref[n]","sim/operation/failures/rel_bat1_lo"},	-- Battery 1 voltage low
{"Dref[n]","sim/operation/failures/rel_bat1_hi"},	-- Battery 1 voltage hi
{"Dref[n]","sim/operation/failures/rel_lites_nav"},	-- Nav lights
{"Dref[n]","sim/operation/failures/rel_lites_strobe"},	-- Strobe lights
{"Dref[n]","sim/operation/failures/rel_lites_beac"},	-- Beacon lights
{"Dref[n]","sim/operation/failures/rel_lites_taxi"},	-- Taxi lights
{"Dref[n]","sim/operation/failures/rel_lites_land"},	-- Landing Lights
{"Dref[n]","sim/operation/failures/rel_lites_ins"},	-- Instrument Lighting
{"Dref[n]","sim/operation/failures/rel_clights"},	-- Cockpit Lights
{"Dref[n]","sim/operation/failures/rel_lites_hud"},	-- HUD lights
{"Dref[n]","sim/operation/failures/rel_stbaug"},	-- Stability Augmentation
{"Dref[n]","sim/operation/failures/rel_servo_rudd"},	-- autopilot servos failed - rudder/yaw damper
{"Dref[n]","sim/operation/failures/rel_otto"},	-- AutoPilot (Computer)
{"Dref[n]","sim/operation/failures/rel_auto_runaway"},	-- AutoPilot (Runaway!!!)
{"Dref[n]","sim/operation/failures/rel_auto_servos"},	-- AutoPilot (Servos)
{"Dref[n]","sim/operation/failures/rel_servo_ailn"},	-- autopilot servos failed - ailerons
{"Dref[n]","sim/operation/failures/rel_servo_elev"},	-- autopilot servos failed - elevators
{"Dref[n]","sim/operation/failures/rel_servo_thro"},	-- autopilot servos failed - throttles
{"Dref[n]","sim/operation/failures/rel_fc_rud_L"},	-- Yaw Left Control
{"Dref[n]","sim/operation/failures/rel_fc_rud_R"},	-- Yaw Right control
{"Dref[n]","sim/operation/failures/rel_fc_ail_L"},	-- Roll left control
{"Dref[n]","sim/operation/failures/rel_fc_ail_R"},	-- Roll Right Control
{"Dref[n]","sim/operation/failures/rel_fc_elv_U"},	-- Pitch Up Control
{"Dref[n]","sim/operation/failures/rel_fc_elv_D"},	-- Pitch Down Control
{"Dref[n]","sim/operation/failures/rel_trim_rud"},	-- Yaw Trim
{"Dref[n]","sim/operation/failures/rel_trim_ail"},	-- roll trim
{"Dref[n]","sim/operation/failures/rel_trim_elv"},	-- Pitch Trim
{"Dref[n]","sim/operation/failures/rel_rud_trim_run"},	-- Yaw Trim Runaway
{"Dref[n]","sim/operation/failures/rel_ail_trim_run"},	-- Pitch Trim Runaway
{"Dref[n]","sim/operation/failures/rel_elv_trim_run"},	-- Elevator Trim Runaway
{"Dref[n]","sim/operation/failures/rel_fc_slt"},	-- Slats
{"Dref[n]","sim/operation/failures/rel_flap_act"},	-- Flap Actuator
{"Dref[n]","sim/operation/failures/rel_fc_L_flp"},	-- Left flap activate
{"Dref[n]","sim/operation/failures/rel_fc_R_flp"},	-- Right Flap activate
{"Dref[n]","sim/operation/failures/rel_L_flp_off"},	-- Left flap remove
{"Dref[n]","sim/operation/failures/rel_R_flp_off"},	-- Right flap remove
{"Dref[n]","sim/operation/failures/rel_gear_act"},	-- Landing Gear actuator
{"Dref[n]","sim/operation/failures/rel_gear_ind"},	-- Landing Gear indicator
{"Dref[n]","sim/operation/failures/rel_lbrakes"},	-- Left Brakes
{"Dref[n]","sim/operation/failures/rel_rbrakes"},	-- Right Brakes
{"Dref[n]","sim/operation/failures/rel_lagear1"},	-- Landing Gear 1 retract
{"Dref[n]","sim/operation/failures/rel_lagear2"},	-- Landing Gear 2 retract
{"Dref[n]","sim/operation/failures/rel_lagear3"},	-- Landing Gear 3 retract
{"Dref[n]","sim/operation/failures/rel_lagear4"},	-- Landing Gear 4 retract
{"Dref[n]","sim/operation/failures/rel_lagear5"},	-- Landing Gear 5 retract
{"Dref[n]","sim/operation/failures/rel_lagear6"},	-- Landing Gear 6 retract
{"Dref[n]","sim/operation/failures/rel_lagear7"},	-- Landing Gear 7 retract
{"Dref[n]","sim/operation/failures/rel_lagear8"},	-- Landing Gear 8 retract
{"Dref[n]","sim/operation/failures/rel_lagear9"},	-- Landing Gear 9 retract
{"Dref[n]","sim/operation/failures/rel_lagear10"},	-- Landing Gear 10 retract
{"Dref[n]","sim/operation/failures/rel_collapse1"},	-- Landing gear 1 gear collapse
{"Dref[n]","sim/operation/failures/rel_collapse2"},	-- Landing gear 2 gear collapse
{"Dref[n]","sim/operation/failures/rel_collapse3"},	-- Landing gear 3 gear collapse
{"Dref[n]","sim/operation/failures/rel_collapse4"},	-- Landing gear 4 gear collapse
{"Dref[n]","sim/operation/failures/rel_collapse5"},	-- Landing gear 5 gear collapse
{"Dref[n]","sim/operation/failures/rel_collapse6"},	-- Landing gear 6 gear collapse
{"Dref[n]","sim/operation/failures/rel_collapse7"},	-- Landing gear 7 gear collapse
{"Dref[n]","sim/operation/failures/rel_collapse8"},	-- Landing gear 8 gear collapse
{"Dref[n]","sim/operation/failures/rel_collapse9"},	-- Landing gear 9 gear collapse
{"Dref[n]","sim/operation/failures/rel_collapse10"},	-- Landing gear 10 gear collapse
{"Dref[n]","sim/operation/failures/rel_tire1"},	-- Landing gear 1 tire blowout
{"Dref[n]","sim/operation/failures/rel_tire2"},	-- Landing gear 2 tire blowout
{"Dref[n]","sim/operation/failures/rel_tire3"},	-- Landing gear 3 tire blowout
{"Dref[n]","sim/operation/failures/rel_tire4"},	-- Landing gear 4 tire blowout
{"Dref[n]","sim/operation/failures/rel_tire5"},	-- Landing gear 5 tire blowout
{"Dref[n]","sim/operation/failures/rel_HVAC"},	-- air conditioning failed
{"Dref[n]","sim/operation/failures/rel_bleed_air_lft"},	-- The left engine is not providing enough pressure
{"Dref[n]","sim/operation/failures/rel_bleed_air_rgt"},	-- The right engine is not providing enough pressure
{"Dref[n]","sim/operation/failures/rel_APU_press"},	-- APU is not providing bleed air for engine start or pressurization
{"Dref[n]","sim/operation/failures/rel_depres_slow"},	-- Slow cabin leak - descend or black out
{"Dref[n]","sim/operation/failures/rel_depres_fast"},	-- catastrophic decompression - yer dead
{"Dref[n]","sim/operation/failures/rel_hydpmp_ele"},	-- Hydraulic pump (electric)
{"Dref[n]","sim/operation/failures/rel_hydpmp"},	-- Hydraulic System 1 (pump fail)
{"Dref[n]","sim/operation/failures/rel_hydpmp2"},	-- Hydraulic System 2 (pump fail)
{"Dref[n]","sim/operation/failures/rel_hydpmp3"},	-- Hydraulic System 3 (pump fail)
{"Dref[n]","sim/operation/failures/rel_hydpmp4"},	-- Hydraulic System 4 (pump fail)
{"Dref[n]","sim/operation/failures/rel_hydpmp5"},	-- Hydraulic System 5 (pump fail)
{"Dref[n]","sim/operation/failures/rel_hydpmp6"},	-- Hydraulic System 6 (pump fail)
{"Dref[n]","sim/operation/failures/rel_hydpmp7"},	-- Hydraulic System 7 (pump fail)
{"Dref[n]","sim/operation/failures/rel_hydpmp8"},	-- Hydraulic System 8 (pump fail)
{"Dref[n]","sim/operation/failures/rel_hydleak"},	-- Hydraulic System 1 (leak)
{"Dref[n]","sim/operation/failures/rel_hydleak2"},	-- Hydraulic System 2 (leak)
{"Dref[n]","sim/operation/failures/rel_hydoverp"},	-- Hydraulic System 1 (over pressure)
{"Dref[n]","sim/operation/failures/rel_hydoverp2"},	-- Hydraulic System 2 (over pressure)
{"Dref[n]","sim/operation/failures/rel_throt_lo"},	-- Throttle inop giving min thrust
{"Dref[n]","sim/operation/failures/rel_throt_hi"},	-- Throttle inop giving max thrust
{"Dref[n]","sim/operation/failures/rel_fc_thr"},	-- Throttle failure at current position
{"Dref[n]","sim/operation/failures/rel_prop_sync"},	-- Prop sync
{"Dref[n]","sim/operation/failures/rel_feather"},	-- Autofeather system inop
{"Dref[n]","sim/operation/failures/rel_trotor"},	-- Tail rotor transmission
{"Dref[n]","sim/operation/failures/rel_antice"},	-- Anti-ice
{"Dref[n]","sim/operation/failures/rel_ice_detect"},	-- Ice detector
{"Dref[n]","sim/operation/failures/rel_ice_pitot_heat1"},	-- Pitot heat 1
{"Dref[n]","sim/operation/failures/rel_ice_pitot_heat2"},	-- Pitot heat 2
{"Dref[n]","sim/operation/failures/rel_ice_static_heat"},	-- Static heat 1
{"Dref[n]","sim/operation/failures/rel_ice_static_heat2"},	-- Static heat 2
{"Dref[n]","sim/operation/failures/rel_ice_AOA_heat"},	-- AOA indicator heat
{"Dref[n]","sim/operation/failures/rel_ice_AOA_heat2"},	-- AOA indicator heat
{"Dref[n]","sim/operation/failures/rel_ice_window_heat"},	-- Window Heat
{"Dref[n]","sim/operation/failures/rel_ice_surf_boot"},	-- Surface Boot - Deprecated - Do Not Use
{"Dref[n]","sim/operation/failures/rel_ice_surf_heat"},	-- Surface Heat
{"Dref[n]","sim/operation/failures/rel_ice_surf_heat2"},	-- Surface Heat
{"Dref[n]","sim/operation/failures/rel_ice_brake_heat"},	-- Brakes anti-ice
{"Dref[n]","sim/operation/failures/rel_ice_alt_air1"},	-- Alternate Air
{"Dref[n]","sim/operation/failures/rel_ice_alt_air2"},	-- Alternate Air
{"Dref[n]","sim/operation/failures/rel_vacuum"},	-- Vacuum System 1 - Pump Failure
{"Dref[n]","sim/operation/failures/rel_vacuum2"},	-- Vacuum System 2 - Pump Failure
{"Dref[n]","sim/operation/failures/rel_elec_gyr"},	-- Electric gyro system 1 - gyro motor Failure
{"Dref[n]","sim/operation/failures/rel_elec_gyr2"},	-- Electric gyro system 2 - gyro motor Failure
{"Dref[n]","sim/operation/failures/rel_pitot"},	-- Pitot 1 - Blockage
{"Dref[n]","sim/operation/failures/rel_pitot2"},	-- Pitot 2 - Blockage
{"Dref[n]","sim/operation/failures/rel_static"},	-- Static 1 - Blockage
{"Dref[n]","sim/operation/failures/rel_static2"},	-- Static 2 - Blockage
{"Dref[n]","sim/operation/failures/rel_static1_err"},	-- Static system 1 - Error
{"Dref[n]","sim/operation/failures/rel_static2_err"},	-- Static system 2 - Error
{"Dref[n]","sim/operation/failures/rel_g_oat"},	-- OAT
{"Dref[n]","sim/operation/failures/rel_g_fuel"},	-- fuel quantity
{"Dref[n]","sim/operation/failures/rel_ss_asi"},	-- Airspeed Indicator (Pilot)
{"Dref[n]","sim/operation/failures/rel_ss_ahz"},	-- Artificial Horizon (Pilot)
{"Dref[n]","sim/operation/failures/rel_ss_alt"},	-- Altimeter (Pilot)
{"Dref[n]","sim/operation/failures/rel_ss_tsi"},	-- Turn indicator (Pilot)
{"Dref[n]","sim/operation/failures/rel_ss_dgy"},	-- Directional Gyro (Pilot)
{"Dref[n]","sim/operation/failures/rel_ss_vvi"},	-- Vertical Velocity Indicator (Pilot)
{"Dref[n]","sim/operation/failures/rel_cop_asi"},	-- Airspeed Indicator (Copilot)
{"Dref[n]","sim/operation/failures/rel_cop_ahz"},	-- Artificial Horizon (Copilot)
{"Dref[n]","sim/operation/failures/rel_cop_alt"},	-- Altimeter (Copilot)
{"Dref[n]","sim/operation/failures/rel_cop_tsi"},	-- Turn indicator (Copilot)
{"Dref[n]","sim/operation/failures/rel_cop_dgy"},	-- Directional Gyro (Copilot)
{"Dref[n]","sim/operation/failures/rel_cop_vvi"},	-- Vertical Velocity Indicator (Copilot)
{"Dref[n]","sim/operation/failures/rel_efis_1"},	-- Primary EFIS
{"Dref[n]","sim/operation/failures/rel_efis_2"},	-- Secondary EFIS
{"Dref[n]","sim/operation/failures/rel_AOA"},	-- AOA
{"Dref[n]","sim/operation/failures/rel_stall_warn"},	-- Stall warning has failed
{"Dref[n]","sim/operation/failures/rel_gear_warning"},	-- gear warning audio is broken
{"Dref[n]","sim/operation/failures/rel_navcom1"},	-- Nav and com 1 radio
{"Dref[n]","sim/operation/failures/rel_navcom2"},	-- Nav and com 2 radio
{"Dref[n]","sim/operation/failures/rel_nav1"},	-- Nav-1 radio
{"Dref[n]","sim/operation/failures/rel_nav2"},	-- Nav-2 radio
{"Dref[n]","sim/operation/failures/rel_com1"},	-- Com-1 radio
{"Dref[n]","sim/operation/failures/rel_com2"},	-- Com-2 radio
{"Dref[n]","sim/operation/failures/rel_adf1"},	-- ADF 1 (only one ADF failure in 830!)
{"Dref[n]","sim/operation/failures/rel_adf2"},	-- ADF 2
{"Dref[n]","sim/operation/failures/rel_gps"},	-- GPS
{"Dref[n]","sim/operation/failures/rel_gps2"},	-- GPS
{"Dref[n]","sim/operation/failures/rel_dme"},	-- DME
{"Dref[n]","sim/operation/failures/rel_loc"},	-- Localizer
{"Dref[n]","sim/operation/failures/rel_gls"},	-- Glide Slope
{"Dref[n]","sim/operation/failures/rel_gp"},	-- WAAS GPS receiver
{"Dref[n]","sim/operation/failures/rel_xpndr"},	-- Transponder failure
{"Dref[n]","sim/operation/failures/rel_marker"},	-- Marker Beacons
{"Dref[n]","sim/operation/failures/rel_RPM_ind_0"},	-- Panel Indicator Inop - rpm engine 1
{"Dref[n]","sim/operation/failures/rel_RPM_ind_1"},	-- Panel Indicator Inop - rpm engine 2
{"Dref[n]","sim/operation/failures/rel_N1_ind0"},	-- Panel Indicator Inop - n1 engine 1
{"Dref[n]","sim/operation/failures/rel_N1_ind1"},	-- Panel Indicator Inop - n1 engine 2
{"Dref[n]","sim/operation/failures/rel_N2_ind0"},	-- Panel Indicator Inop - n2 engine 1
{"Dref[n]","sim/operation/failures/rel_N2_ind1"},	-- Panel Indicator Inop - n2 engine 2
{"Dref[n]","sim/operation/failures/rel_MP_ind_0"},	-- Panel Indicator Inop - mp engine 1
{"Dref[n]","sim/operation/failures/rel_MP_ind_1"},	-- Panel Indicator Inop - mp engine 2
{"Dref[n]","sim/operation/failures/rel_TRQind0"},	-- Panel Indicator Inop - trq engine 1
{"Dref[n]","sim/operation/failures/rel_TRQind1"},	-- Panel Indicator Inop - trq engine 2
{"Dref[n]","sim/operation/failures/rel_EPRind0"},	-- Panel Indicator Inop - epr engine 1
{"Dref[n]","sim/operation/failures/rel_EPRind1"},	-- Panel Indicator Inop - epr engine 2
{"Dref[n]","sim/operation/failures/rel_CHT_ind_0"},	-- Panel Indicator Inop - cht engine 1
{"Dref[n]","sim/operation/failures/rel_CHT_ind_1"},	-- Panel Indicator Inop - cht engine 2
{"Dref[n]","sim/operation/failures/rel_ITTind0"},	-- Panel Indicator Inop - itt engine 1
{"Dref[n]","sim/operation/failures/rel_ITTind1"},	-- Panel Indicator Inop - itt engine 2
{"Dref[n]","sim/operation/failures/rel_EGT_ind_0"},	-- Panel Indicator Inop - egt engine 1
{"Dref[n]","sim/operation/failures/rel_EGT_ind_1"},	-- Panel Indicator Inop - egt engine 2
{"Dref[n]","sim/operation/failures/rel_FF_ind0"},	-- Panel Indicator Inop - ff engine 1
{"Dref[n]","sim/operation/failures/rel_FF_ind1"},	-- Panel Indicator Inop - ff engine 2
{"Dref[n]","sim/operation/failures/rel_fp_ind_0"},	-- Panel Indicator Inop - Fuel Pressure 1
{"Dref[n]","sim/operation/failures/rel_fp_ind_1"},	-- Panel Indicator Inop - Fuel Pressure 2
{"Dref[n]","sim/operation/failures/rel_oilp_ind_0"},	-- Panel Indicator Inop - Oil Pressure 1
{"Dref[n]","sim/operation/failures/rel_oilp_ind_1"},	-- Panel Indicator Inop - Oil Pressure 2
{"Dref[n]","sim/operation/failures/rel_oilt_ind_0"},	-- Panel Indicator Inop - Oil Temperature 1
{"Dref[n]","sim/operation/failures/rel_oilt_ind_1"},	-- Panel Indicator Inop - Oil Temperature 2
{"Dref[n]","sim/operation/failures/rel_g430_gps1"},	-- G430 GPS 1 Inop
{"Dref[n]","sim/operation/failures/rel_g430_gps2"},	-- G430 GPS 2 Inop
{"Dref[n]","sim/operation/failures/rel_g430_rad1_tune"},	-- G430 Nav/Com Tuner 1 Inop
{"Dref[n]","sim/operation/failures/rel_g430_rad2_tune"},	-- G430 Nav/Com Tuner 2 Inop
{"Dref[n]","sim/operation/failures/rel_g_gia1"},	-- GIA 1
{"Dref[n]","sim/operation/failures/rel_g_gia2"},	-- GIA 2
{"Dref[n]","sim/operation/failures/rel_g_gea"},	-- gea
{"Dref[n]","sim/operation/failures/rel_adc_comp"},	-- air data computer
{"Dref[n]","sim/operation/failures/rel_g_arthorz"},	-- AHRS
{"Dref[n]","sim/operation/failures/rel_g_asi"},	-- airspeed
{"Dref[n]","sim/operation/failures/rel_g_alt"},	-- altimeter
{"Dref[n]","sim/operation/failures/rel_g_magmtr"},	-- magnetometer
{"Dref[n]","sim/operation/failures/rel_g_vvi"},	-- vvi
--{"Dref[n]","sim/operation/failures/rel_g_navrad1"},	-- nav radio 1 - removed from 10.00 - 10.36, compatibility only in 10.40 - DO NOT USE - use rel_nav1
--{"Dref[n]","sim/operation/failures/rel_g_navrad2"},	-- nav radio 2 - removed from 10.00 - 10.36, compatibility only in 10.40 - DO NOT USE - use rel_nav2
--{"Dref[n]","sim/operation/failures/rel_g_comrad1"},	-- com radio 1 - removed from 10.00 - 10.36, compatibility only in 10.40 - DO NOT USE - use rel_com1
--{"Dref[n]","sim/operation/failures/rel_g_comrad2"},	-- com radio 2 - removed from 10.00 - 10.36, compatibility only in 10.40 - DO NOT USE - use rel_com2
--{"Dref[n]","sim/operation/failures/rel_g_xpndr"},	-- transponder removed from 10.00 - 10.36, compatibility only in 10.40+ - DO NOT USE - use rel_xpndr
{"Dref[n]","sim/operation/failures/rel_g_gen1"},	-- generator amperage 1
{"Dref[n]","sim/operation/failures/rel_g_gen2"},	-- generator amperage 2
{"Dref[n]","sim/operation/failures/rel_g_bat1"},	-- battery voltage 1
{"Dref[n]","sim/operation/failures/rel_g_bat2"},	-- battery voltage 2
{"Dref[n]","sim/operation/failures/rel_g_bus1"},	-- bus voltage 1
{"Dref[n]","sim/operation/failures/rel_g_bus2"},	-- bus voltage 2
{"Dref[n]","sim/operation/failures/rel_g_mfd"},	-- MFD screen failure
{"Dref[n]","sim/operation/failures/rel_g_pfd"},	-- PFD screen failure
{"Dref[n]","sim/operation/failures/rel_g_pfd2"},	-- PFD2 screen failure
{"Dref[n]","sim/operation/failures/rel_magLFT0"},	-- Left Magneto Fail - engine 1
{"Dref[n]","sim/operation/failures/rel_magLFT1"},	-- Left Magneto Fail - engine 2
{"Dref[n]","sim/operation/failures/rel_magLFT2"},	-- Left Magneto Fail - engine 3
{"Dref[n]","sim/operation/failures/rel_magLFT3"},	-- Left Magneto Fail - engine 4
{"Dref[n]","sim/operation/failures/rel_magLFT4"},	-- Left Magneto Fail - engine 5
{"Dref[n]","sim/operation/failures/rel_magLFT5"},	-- Left Magneto Fail - engine 6
{"Dref[n]","sim/operation/failures/rel_magLFT6"},	-- Left Magneto Fail - engine 7
{"Dref[n]","sim/operation/failures/rel_magLFT7"},	-- Left Magneto Fail - engine 8
{"Dref[n]","sim/operation/failures/rel_magRGT0"},	-- Right Magneto Fail - engine 1
{"Dref[n]","sim/operation/failures/rel_magRGT1"},	-- Right Magneto Fail - engine 2
{"Dref[n]","sim/operation/failures/rel_magRGT2"},	-- Right Magneto Fail - engine 3
{"Dref[n]","sim/operation/failures/rel_magRGT3"},	-- Right Magneto Fail - engine 4
{"Dref[n]","sim/operation/failures/rel_magRGT4"},	-- Right Magneto Fail - engine 5
{"Dref[n]","sim/operation/failures/rel_magRGT5"},	-- Right Magneto Fail - engine 6
{"Dref[n]","sim/operation/failures/rel_magRGT6"},	-- Right Magneto Fail - engine 7
{"Dref[n]","sim/operation/failures/rel_magRGT7"},	-- Right Magneto Fail - engine 8
{"Dref[n]","sim/operation/failures/rel_engfir0"},	-- Engine Failure - engine 1 Fire
{"Dref[n]","sim/operation/failures/rel_engfir1"},	-- Engine Failure - engine 2 Fire
{"Dref[n]","sim/operation/failures/rel_engfir2"},	-- Engine Failure - engine 3 Fire
{"Dref[n]","sim/operation/failures/rel_engfir3"},	-- Engine Failure - engine 4 Fire
{"Dref[n]","sim/operation/failures/rel_engfir4"},	-- Engine Failure - engine 5 Fire
{"Dref[n]","sim/operation/failures/rel_engfir5"},	-- Engine Failure - engine 6 Fire
{"Dref[n]","sim/operation/failures/rel_engfir6"},	-- Engine Failure - engine 7 Fire
{"Dref[n]","sim/operation/failures/rel_engfir7"},	-- Engine Failure - engine 8 Fire
{"Dref[n]","sim/operation/failures/rel_engfla0"},	-- Engine Failure - engine 1 Flameout
{"Dref[n]","sim/operation/failures/rel_engfla1"},	-- Engine Failure - engine 2 Flameout
{"Dref[n]","sim/operation/failures/rel_engfla2"},	-- Engine Failure - engine 3 Flameout
{"Dref[n]","sim/operation/failures/rel_engfla3"},	-- Engine Failure - engine 4 Flameout
{"Dref[n]","sim/operation/failures/rel_engfla4"},	-- Engine Failure - engine 5 Flameout
{"Dref[n]","sim/operation/failures/rel_engfla5"},	-- Engine Failure - engine 6 Flameout
{"Dref[n]","sim/operation/failures/rel_engfla6"},	-- Engine Failure - engine 7 Flameout
{"Dref[n]","sim/operation/failures/rel_engfla7"},	-- Engine Failure - engine 8 Flameout
{"Dref[n]","sim/operation/failures/rel_engfai0"},	-- Engine Failure - engine 1 loss of power without smoke
{"Dref[n]","sim/operation/failures/rel_engfai1"},	-- Engine Failure - engine 2
{"Dref[n]","sim/operation/failures/rel_engfai2"},	-- Engine Failure - engine 3
{"Dref[n]","sim/operation/failures/rel_engfai3"},	-- Engine Failure - engine 4
{"Dref[n]","sim/operation/failures/rel_engfai4"},	-- Engine Failure - engine 5
{"Dref[n]","sim/operation/failures/rel_engfai5"},	-- Engine Failure - engine 6
{"Dref[n]","sim/operation/failures/rel_engfai6"},	-- Engine Failure - engine 7
{"Dref[n]","sim/operation/failures/rel_engfai7"},	-- Engine Failure - engine 8
{"Dref[n]","sim/operation/failures/rel_engsep0"},	-- Engine Separation - engine 1
{"Dref[n]","sim/operation/failures/rel_engsep1"},	-- Engine Separation - engine 2
{"Dref[n]","sim/operation/failures/rel_engsep2"},	-- Engine Separation - engine 3
{"Dref[n]","sim/operation/failures/rel_engsep3"},	-- Engine Separation - engine 4
{"Dref[n]","sim/operation/failures/rel_engsep4"},	-- Engine Separation - engine 5
{"Dref[n]","sim/operation/failures/rel_engsep5"},	-- Engine Separation - engine 6
{"Dref[n]","sim/operation/failures/rel_engsep6"},	-- Engine Separation - engine 7
{"Dref[n]","sim/operation/failures/rel_engsep7"},	-- Engine Separation - engine 8
{"Dref[n]","sim/operation/failures/rel_fuepmp0"},	-- Fuel Pump Inop - engine 1 (engine driven)
{"Dref[n]","sim/operation/failures/rel_fuepmp1"},	-- Fuel Pump Inop - engine 2 (engine driven)
{"Dref[n]","sim/operation/failures/rel_fuepmp2"},	-- Fuel Pump Inop - engine 3 (engine driven)
{"Dref[n]","sim/operation/failures/rel_fuepmp3"},	-- Fuel Pump Inop - engine 4 (engine driven)
{"Dref[n]","sim/operation/failures/rel_fuepmp4"},	-- Fuel Pump Inop - engine 5 (engine driven)
{"Dref[n]","sim/operation/failures/rel_fuepmp5"},	-- Fuel Pump Inop - engine 6 (engine driven)
{"Dref[n]","sim/operation/failures/rel_fuepmp6"},	-- Fuel Pump Inop - engine 7 (engine driven)
{"Dref[n]","sim/operation/failures/rel_fuepmp7"},	-- Fuel Pump Inop - engine 8 (engine driven)
{"Dref[n]","sim/operation/failures/rel_ele_fuepmp0"},	-- Fuel Pump - engine 1 (electric driven)
{"Dref[n]","sim/operation/failures/rel_ele_fuepmp1"},	-- Fuel Pump - engine 2 (electric driven)
{"Dref[n]","sim/operation/failures/rel_ele_fuepmp2"},	-- Fuel Pump - engine 3 (electric driven)
{"Dref[n]","sim/operation/failures/rel_ele_fuepmp3"},	-- Fuel Pump - engine 4 (electric driven)
{"Dref[n]","sim/operation/failures/rel_ele_fuepmp4"},	-- Fuel Pump - engine 5 (electric driven)
{"Dref[n]","sim/operation/failures/rel_ele_fuepmp5"},	-- Fuel Pump - engine 6 (electric driven)
{"Dref[n]","sim/operation/failures/rel_ele_fuepmp6"},	-- Fuel Pump - engine 7 (electric driven)
{"Dref[n]","sim/operation/failures/rel_ele_fuepmp7"},	-- Fuel Pump - engine 8 (electric driven)
{"Dref[n]","sim/operation/failures/rel_eng_lo0"},	-- Fuel Pump Low Pressure - engine 1 (engine driven)
{"Dref[n]","sim/operation/failures/rel_eng_lo1"},	-- Fuel Pump Low Pressure - engine 2 (engine driven)
{"Dref[n]","sim/operation/failures/rel_eng_lo2"},	-- Fuel Pump Low Pressure - engine 3 (engine driven)
{"Dref[n]","sim/operation/failures/rel_eng_lo3"},	-- Fuel Pump Low Pressure - engine 4 (engine driven)
{"Dref[n]","sim/operation/failures/rel_eng_lo4"},	-- Fuel Pump Low Pressure - engine 5 (engine driven)
{"Dref[n]","sim/operation/failures/rel_eng_lo5"},	-- Fuel Pump Low Pressure - engine 6 (engine driven)
{"Dref[n]","sim/operation/failures/rel_eng_lo6"},	-- Fuel Pump Low Pressure - engine 7 (engine driven)
{"Dref[n]","sim/operation/failures/rel_eng_lo7"},	-- Fuel Pump Low Pressure - engine 8 (engine driven)
{"Dref[n]","sim/operation/failures/rel_airres0"},	-- Airflow restricted - Engine 1
{"Dref[n]","sim/operation/failures/rel_airres1"},	-- Airflow restricted - Engine 2
{"Dref[n]","sim/operation/failures/rel_airres2"},	-- Airflow restricted - Engine 3
{"Dref[n]","sim/operation/failures/rel_airres3"},	-- Airflow restricted - Engine 4
{"Dref[n]","sim/operation/failures/rel_airres4"},	-- Airflow restricted - Engine 5
{"Dref[n]","sim/operation/failures/rel_airres5"},	-- Airflow restricted - Engine 6
{"Dref[n]","sim/operation/failures/rel_airres6"},	-- Airflow restricted - Engine 7
{"Dref[n]","sim/operation/failures/rel_airres7"},	-- Airflow restricted - Engine 8
{"Dref[n]","sim/operation/failures/rel_fuelfl0"},	-- Fuel Flow Fluctuation - engine 1
{"Dref[n]","sim/operation/failures/rel_fuelfl1"},	-- Fuel Flow Fluctuation - engine 2
{"Dref[n]","sim/operation/failures/rel_fuelfl2"},	-- Fuel Flow Fluctuation - engine 3
{"Dref[n]","sim/operation/failures/rel_fuelfl3"},	-- Fuel Flow Fluctuation - engine 4
{"Dref[n]","sim/operation/failures/rel_fuelfl4"},	-- Fuel Flow Fluctuation - engine 5
{"Dref[n]","sim/operation/failures/rel_fuelfl5"},	-- Fuel Flow Fluctuation - engine 6
{"Dref[n]","sim/operation/failures/rel_fuelfl6"},	-- Fuel Flow Fluctuation - engine 7
{"Dref[n]","sim/operation/failures/rel_fuelfl7"},	-- Fuel Flow Fluctuation - engine 8
{"Dref[n]","sim/operation/failures/rel_comsta0"},	-- Engine Compressor Stall - engine 1
{"Dref[n]","sim/operation/failures/rel_comsta1"},	-- Engine Compressor Stall - engine 2
{"Dref[n]","sim/operation/failures/rel_comsta2"},	-- Engine Compressor Stall - engine 3
{"Dref[n]","sim/operation/failures/rel_comsta3"},	-- Engine Compressor Stall - engine 4
{"Dref[n]","sim/operation/failures/rel_comsta4"},	-- Engine Compressor Stall - engine 5
{"Dref[n]","sim/operation/failures/rel_comsta5"},	-- Engine Compressor Stall - engine 6
{"Dref[n]","sim/operation/failures/rel_comsta6"},	-- Engine Compressor Stall - engine 7
{"Dref[n]","sim/operation/failures/rel_comsta7"},	-- Engine Compressor Stall - engine 8
{"Dref[n]","sim/operation/failures/rel_startr0"},	-- Starter - engine 1
{"Dref[n]","sim/operation/failures/rel_startr1"},	-- Starter - engine 2
{"Dref[n]","sim/operation/failures/rel_startr2"},	-- Starter - engine 3
{"Dref[n]","sim/operation/failures/rel_startr3"},	-- Starter - engine 4
{"Dref[n]","sim/operation/failures/rel_startr4"},	-- Starter - engine 5
{"Dref[n]","sim/operation/failures/rel_startr5"},	-- Starter - engine 6
{"Dref[n]","sim/operation/failures/rel_startr6"},	-- Starter - engine 7
{"Dref[n]","sim/operation/failures/rel_startr7"},	-- Starter - engine 8
{"Dref[n]","sim/operation/failures/rel_ignitr0"},	-- Ignitor - engine 1
{"Dref[n]","sim/operation/failures/rel_ignitr1"},	-- Ignitor - engine 2
{"Dref[n]","sim/operation/failures/rel_ignitr2"},	-- Ignitor - engine 3
{"Dref[n]","sim/operation/failures/rel_ignitr3"},	-- Ignitor - engine 4
{"Dref[n]","sim/operation/failures/rel_ignitr4"},	-- Ignitor - engine 5
{"Dref[n]","sim/operation/failures/rel_ignitr5"},	-- Ignitor - engine 6
{"Dref[n]","sim/operation/failures/rel_ignitr6"},	-- Ignitor - engine 7
{"Dref[n]","sim/operation/failures/rel_ignitr7"},	-- Ignitor - engine 8
{"Dref[n]","sim/operation/failures/rel_hunsta0"},	-- Hung Start - engine 0
{"Dref[n]","sim/operation/failures/rel_hunsta1"},	-- Hung Start - engine 1
{"Dref[n]","sim/operation/failures/rel_hunsta2"},	-- Hung Start - engine 2
{"Dref[n]","sim/operation/failures/rel_hunsta3"},	-- Hung Start - engine 3
{"Dref[n]","sim/operation/failures/rel_hunsta4"},	-- Hung Start - engine 4
{"Dref[n]","sim/operation/failures/rel_hunsta5"},	-- Hung Start - engine 5
{"Dref[n]","sim/operation/failures/rel_hunsta6"},	-- Hung Start - engine 6
{"Dref[n]","sim/operation/failures/rel_hunsta7"},	-- Hung Start - engine 7
{"Dref[n]","sim/operation/failures/rel_clonoz0"},	-- Hung start (clogged nozzles) - Engine 1
{"Dref[n]","sim/operation/failures/rel_clonoz1"},	-- Hung start (clogged nozzles) - Engine 2
{"Dref[n]","sim/operation/failures/rel_clonoz2"},	-- Hung start (clogged nozzles) - Engine 3
{"Dref[n]","sim/operation/failures/rel_clonoz3"},	-- Hung start (clogged nozzles) - Engine 4
{"Dref[n]","sim/operation/failures/rel_clonoz4"},	-- Hung start (clogged nozzles) - Engine 5
{"Dref[n]","sim/operation/failures/rel_clonoz5"},	-- Hung start (clogged nozzles) - Engine 6
{"Dref[n]","sim/operation/failures/rel_clonoz6"},	-- Hung start (clogged nozzles) - Engine 7
{"Dref[n]","sim/operation/failures/rel_clonoz7"},	-- Hung start (clogged nozzles) - Engine 8
{"Dref[n]","sim/operation/failures/rel_hotsta0"},	-- Hot Start - engine 0
{"Dref[n]","sim/operation/failures/rel_hotsta1"},	-- Hot Start - engine 1
{"Dref[n]","sim/operation/failures/rel_hotsta2"},	-- Hot Start - engine 2
{"Dref[n]","sim/operation/failures/rel_hotsta3"},	-- Hot Start - engine 3
{"Dref[n]","sim/operation/failures/rel_hotsta4"},	-- Hot Start - engine 4
{"Dref[n]","sim/operation/failures/rel_hotsta5"},	-- Hot Start - engine 5
{"Dref[n]","sim/operation/failures/rel_hotsta6"},	-- Hot Start - engine 6
{"Dref[n]","sim/operation/failures/rel_hotsta7"},	-- Hot Start - engine 7
{"Dref[n]","sim/operation/failures/rel_runITT0"},	-- Runway Hot ITT - engine 1
{"Dref[n]","sim/operation/failures/rel_runITT1"},	-- Runway Hot ITT - engine 2
{"Dref[n]","sim/operation/failures/rel_runITT2"},	-- Runway Hot ITT - engine 3
{"Dref[n]","sim/operation/failures/rel_runITT3"},	-- Runway Hot ITT - engine 4
{"Dref[n]","sim/operation/failures/rel_runITT4"},	-- Runway Hot ITT - engine 5
{"Dref[n]","sim/operation/failures/rel_runITT5"},	-- Runway Hot ITT - engine 6
{"Dref[n]","sim/operation/failures/rel_runITT6"},	-- Runway Hot ITT - engine 7
{"Dref[n]","sim/operation/failures/rel_runITT7"},	-- Runway Hot ITT - engine 8
{"Dref[n]","sim/operation/failures/rel_genera0"},	-- Generator - engine 1
{"Dref[n]","sim/operation/failures/rel_genera1"},	-- Generator - engine 2
{"Dref[n]","sim/operation/failures/rel_genera2"},	-- Generator - engine 3
{"Dref[n]","sim/operation/failures/rel_genera3"},	-- Generator - engine 4
{"Dref[n]","sim/operation/failures/rel_genera4"},	-- Generator - engine 5
{"Dref[n]","sim/operation/failures/rel_genera5"},	-- Generator - engine 6
{"Dref[n]","sim/operation/failures/rel_genera6"},	-- Generator - engine 7
{"Dref[n]","sim/operation/failures/rel_genera7"},	-- Generator - engine 8
{"Dref[n]","sim/operation/failures/rel_batter0"},	-- Battery 1
{"Dref[n]","sim/operation/failures/rel_batter1"},	-- Battery 2
{"Dref[n]","sim/operation/failures/rel_batter2"},	-- Battery 3
{"Dref[n]","sim/operation/failures/rel_batter3"},	-- Battery 4
{"Dref[n]","sim/operation/failures/rel_batter4"},	-- Battery 5
{"Dref[n]","sim/operation/failures/rel_batter5"},	-- Battery 6
{"Dref[n]","sim/operation/failures/rel_batter6"},	-- Battery 7
{"Dref[n]","sim/operation/failures/rel_batter7"},	-- Battery 8
{"Dref[n]","sim/operation/failures/rel_govnr_0"},	-- Governor throttle fail - engine 1
{"Dref[n]","sim/operation/failures/rel_govnr_1"},	-- Governor throttle fail - engine 2
{"Dref[n]","sim/operation/failures/rel_govnr_2"},	-- Governor throttle fail - engine 3
{"Dref[n]","sim/operation/failures/rel_govnr_3"},	-- Governor throttle fail - engine 4
{"Dref[n]","sim/operation/failures/rel_govnr_4"},	-- Governor throttle fail - engine 5
{"Dref[n]","sim/operation/failures/rel_govnr_5"},	-- Governor throttle fail - engine 6
{"Dref[n]","sim/operation/failures/rel_govnr_6"},	-- Governor throttle fail - engine 7
{"Dref[n]","sim/operation/failures/rel_govnr_7"},	-- Governor throttle fail - engine 8
{"Dref[n]","sim/operation/failures/rel_fadec_0"},	-- Fadec - engine 1
{"Dref[n]","sim/operation/failures/rel_fadec_1"},	-- Fadec - engine 2
{"Dref[n]","sim/operation/failures/rel_fadec_2"},	-- Fadec - engine 3
{"Dref[n]","sim/operation/failures/rel_fadec_3"},	-- Fadec - engine 4
{"Dref[n]","sim/operation/failures/rel_fadec_4"},	-- Fadec - engine 5
{"Dref[n]","sim/operation/failures/rel_fadec_5"},	-- Fadec - engine 6
{"Dref[n]","sim/operation/failures/rel_fadec_6"},	-- Fadec - engine 7
{"Dref[n]","sim/operation/failures/rel_fadec_7"},	-- Fadec - engine 8
{"Dref[n]","sim/operation/failures/rel_oilpmp0"},	-- Oil Pump - engine 1
{"Dref[n]","sim/operation/failures/rel_oilpmp1"},	-- Oil Pump - engine 2
{"Dref[n]","sim/operation/failures/rel_oilpmp2"},	-- Oil Pump - engine 3
{"Dref[n]","sim/operation/failures/rel_oilpmp3"},	-- Oil Pump - engine 4
{"Dref[n]","sim/operation/failures/rel_oilpmp4"},	-- Oil Pump - engine 5
{"Dref[n]","sim/operation/failures/rel_oilpmp5"},	-- Oil Pump - engine 6
{"Dref[n]","sim/operation/failures/rel_oilpmp6"},	-- Oil Pump - engine 7
{"Dref[n]","sim/operation/failures/rel_oilpmp7"},	-- Oil Pump - engine 8
{"Dref[n]","sim/operation/failures/rel_chipde0"},	-- Chip Detected - engine 1
{"Dref[n]","sim/operation/failures/rel_chipde1"},	-- Chip Detected - engine 2
{"Dref[n]","sim/operation/failures/rel_chipde2"},	-- Chip Detected - engine 3
{"Dref[n]","sim/operation/failures/rel_chipde3"},	-- Chip Detected - engine 4
{"Dref[n]","sim/operation/failures/rel_chipde4"},	-- Chip Detected - engine 5
{"Dref[n]","sim/operation/failures/rel_chipde5"},	-- Chip Detected - engine 6
{"Dref[n]","sim/operation/failures/rel_chipde6"},	-- Chip Detected - engine 7
{"Dref[n]","sim/operation/failures/rel_chipde7"},	-- Chip Detected - engine 8
{"Dref[n]","sim/operation/failures/rel_prpfin0"},	-- Prop governor fail to fine - engine 1
{"Dref[n]","sim/operation/failures/rel_prpfin1"},	-- Prop governor fail to fine - engine 2
{"Dref[n]","sim/operation/failures/rel_prpfin2"},	-- Prop governor fail to fine - engine 3
{"Dref[n]","sim/operation/failures/rel_prpfin3"},	-- Prop governor fail to fine - engine 4
{"Dref[n]","sim/operation/failures/rel_prpfin4"},	-- Prop governor fail to fine - engine 5
{"Dref[n]","sim/operation/failures/rel_prpfin5"},	-- Prop governor fail to fine - engine 6
{"Dref[n]","sim/operation/failures/rel_prpfin6"},	-- Prop governor fail to fine - engine 7
{"Dref[n]","sim/operation/failures/rel_prpfin7"},	-- Prop governor fail to fine - engine 8
{"Dref[n]","sim/operation/failures/rel_prpcrs0"},	-- Prop governor fail to coarse - engine 1
{"Dref[n]","sim/operation/failures/rel_prpcrs1"},	-- Prop governor fail to coarse - engine 2
{"Dref[n]","sim/operation/failures/rel_prpcrs2"},	-- Prop governor fail to coarse - engine 3
{"Dref[n]","sim/operation/failures/rel_prpcrs3"},	-- Prop governor fail to coarse - engine 4
{"Dref[n]","sim/operation/failures/rel_prpcrs4"},	-- Prop governor fail to coarse - engine 5
{"Dref[n]","sim/operation/failures/rel_prpcrs5"},	-- Prop governor fail to coarse - engine 6
{"Dref[n]","sim/operation/failures/rel_prpcrs6"},	-- Prop governor fail to coarse - engine 7
{"Dref[n]","sim/operation/failures/rel_prpcrs7"},	-- Prop governor fail to coarse - engine 8
{"Dref[n]","sim/operation/failures/rel_pshaft0"},	-- Drive Shaft - engine 1
{"Dref[n]","sim/operation/failures/rel_pshaft1"},	-- Drive Shaft - engine 2
{"Dref[n]","sim/operation/failures/rel_pshaft2"},	-- Drive Shaft - engine 3
{"Dref[n]","sim/operation/failures/rel_pshaft3"},	-- Drive Shaft - engine 4
{"Dref[n]","sim/operation/failures/rel_pshaft4"},	-- Drive Shaft - engine 5
{"Dref[n]","sim/operation/failures/rel_pshaft5"},	-- Drive Shaft - engine 6
{"Dref[n]","sim/operation/failures/rel_pshaft6"},	-- Drive Shaft - engine 7
{"Dref[n]","sim/operation/failures/rel_pshaft7"},	-- Drive Shaft - engine 8
{"Dref[n]","sim/operation/failures/rel_seize_0"},	-- Engine Seize - engine 1
{"Dref[n]","sim/operation/failures/rel_seize_1"},	-- Engine Seize - engine 2
{"Dref[n]","sim/operation/failures/rel_seize_2"},	-- Engine Seize - engine 3
{"Dref[n]","sim/operation/failures/rel_seize_3"},	-- Engine Seize - engine 4
{"Dref[n]","sim/operation/failures/rel_seize_4"},	-- Engine Seize - engine 5
{"Dref[n]","sim/operation/failures/rel_seize_5"},	-- Engine Seize - engine 6
{"Dref[n]","sim/operation/failures/rel_seize_6"},	-- Engine Seize - engine 7
{"Dref[n]","sim/operation/failures/rel_seize_7"},	-- Engine Seize - engine 8
{"Dref[n]","sim/operation/failures/rel_revers0"},	-- Thrust Reversers Inop - engine 1
{"Dref[n]","sim/operation/failures/rel_revers1"},	-- Thrust Reversers Inop - engine 2
{"Dref[n]","sim/operation/failures/rel_revers2"},	-- Thrust Reversers Inop - engine 3
{"Dref[n]","sim/operation/failures/rel_revers3"},	-- Thrust Reversers Inop - engine 4
{"Dref[n]","sim/operation/failures/rel_revers4"},	-- Thrust Reversers Inop - engine 5
{"Dref[n]","sim/operation/failures/rel_revers5"},	-- Thrust Reversers Inop - engine 6
{"Dref[n]","sim/operation/failures/rel_revers6"},	-- Thrust Reversers Inop - engine 7
{"Dref[n]","sim/operation/failures/rel_revers7"},	-- Thrust Reversers Inop - engine 8
{"Dref[n]","sim/operation/failures/rel_revdep0"},	-- Thrust Reversers Deploy - engine 1
{"Dref[n]","sim/operation/failures/rel_revdep1"},	-- Thrust Reversers Deploy - engine 2
{"Dref[n]","sim/operation/failures/rel_revdep2"},	-- Thrust Reversers Deploy - engine 3
{"Dref[n]","sim/operation/failures/rel_revdep3"},	-- Thrust Reversers Deploy - engine 4
{"Dref[n]","sim/operation/failures/rel_revdep4"},	-- Thrust Reversers Deploy - engine 5
{"Dref[n]","sim/operation/failures/rel_revdep5"},	-- Thrust Reversers Deploy - engine 6
{"Dref[n]","sim/operation/failures/rel_revdep6"},	-- Thrust Reversers Deploy - engine 7
{"Dref[n]","sim/operation/failures/rel_revdep7"},	-- Thrust Reversers Deploy - engine 8
{"Dref[n]","sim/operation/failures/rel_revloc0"},	-- Thrust Reversers Locked - engine 1
{"Dref[n]","sim/operation/failures/rel_revloc1"},	-- Thrust Reversers Locked - engine 2
{"Dref[n]","sim/operation/failures/rel_revloc2"},	-- Thrust Reversers Locked - engine 3
{"Dref[n]","sim/operation/failures/rel_revloc3"},	-- Thrust Reversers Locked - engine 4
{"Dref[n]","sim/operation/failures/rel_revloc4"},	-- Thrust Reversers Locked - engine 5
{"Dref[n]","sim/operation/failures/rel_revloc5"},	-- Thrust Reversers Locked - engine 6
{"Dref[n]","sim/operation/failures/rel_revloc6"},	-- Thrust Reversers Locked - engine 7
{"Dref[n]","sim/operation/failures/rel_revloc7"},	-- Thrust Reversers Locked - engine 8
{"Dref[n]","sim/operation/failures/rel_aftbur0"},	-- Afterburners - engine 1
{"Dref[n]","sim/operation/failures/rel_aftbur1"},	-- Afterburners - engine 2
{"Dref[n]","sim/operation/failures/rel_aftbur2"},	-- Afterburners - engine 3
{"Dref[n]","sim/operation/failures/rel_aftbur3"},	-- Afterburners - engine 4
{"Dref[n]","sim/operation/failures/rel_aftbur4"},	-- Afterburners - engine 5
{"Dref[n]","sim/operation/failures/rel_aftbur5"},	-- Afterburners - engine 6
{"Dref[n]","sim/operation/failures/rel_aftbur6"},	-- Afterburners - engine 7
{"Dref[n]","sim/operation/failures/rel_aftbur7"},	-- Afterburners - engine 8
{"Dref[n]","sim/operation/failures/rel_ice_inlet_heat"},	-- Inlet heat, engine 1
{"Dref[n]","sim/operation/failures/rel_ice_inlet_heat2"},	-- Inlet heat, engine 2
{"Dref[n]","sim/operation/failures/rel_ice_inlet_heat3"},	-- Inlet heat, engine 3
{"Dref[n]","sim/operation/failures/rel_ice_inlet_heat4"},	-- Inlet heat, engine 4
{"Dref[n]","sim/operation/failures/rel_ice_inlet_heat5"},	-- Inlet heat, engine 5
{"Dref[n]","sim/operation/failures/rel_ice_inlet_heat6"},	-- Inlet heat, engine 6
{"Dref[n]","sim/operation/failures/rel_ice_inlet_heat7"},	-- Inlet heat, engine 7
{"Dref[n]","sim/operation/failures/rel_ice_inlet_heat8"},	-- Inlet heat, engine 8
{"Dref[n]","sim/operation/failures/rel_ice_prop_heat"},	-- Prop Heat, engine 1
{"Dref[n]","sim/operation/failures/rel_ice_prop_heat2"},	-- Prop Heat, engine 2
{"Dref[n]","sim/operation/failures/rel_ice_prop_heat3"},	-- Prop Heat, engine 3
{"Dref[n]","sim/operation/failures/rel_ice_prop_heat4"},	-- Prop Heat, engine 4
{"Dref[n]","sim/operation/failures/rel_ice_prop_heat5"},	-- Prop Heat, engine 5
{"Dref[n]","sim/operation/failures/rel_ice_prop_heat6"},	-- Prop Heat, engine 6
{"Dref[n]","sim/operation/failures/rel_ice_prop_heat7"},	-- Prop Heat, engine 7
{"Dref[n]","sim/operation/failures/rel_ice_prop_heat8"},	-- Prop Heat, engine 8
{"Dref[n]","sim/operation/failures/rel_wing1L"},	-- Wing separations - left wing 1
{"Dref[n]","sim/operation/failures/rel_wing1R"},	-- Wing separations - right wing 1
{"Dref[n]","sim/operation/failures/rel_wing2L"},	-- Wing separations - left wing 2
{"Dref[n]","sim/operation/failures/rel_wing2R"},	-- Wing separations - right wing 2
{"Dref[n]","sim/operation/failures/rel_wing3L"},	-- Wing separations - left wing 3
{"Dref[n]","sim/operation/failures/rel_wing3R"},	-- Wing separations - right wing 3
{"Dref[n]","sim/operation/failures/rel_wing4L"},	-- Wing separations - left wing 4
{"Dref[n]","sim/operation/failures/rel_wing4R"},	-- Wing separations - right wing 4
{"Dref[n]","sim/operation/failures/rel_hstbL"},	-- Left horizontal stabilizer separate
{"Dref[n]","sim/operation/failures/rel_hstbR"},	-- Right horizontal stabilizer separate
{"Dref[n]","sim/operation/failures/rel_vstb1"},	-- Vertical stabilizer 1 separate
{"Dref[n]","sim/operation/failures/rel_vstb2"},	-- Vertical stabilizer 2 separate
{"Dref[n]","sim/operation/failures/rel_mwing1"},	-- Misc wing 1 separate
{"Dref[n]","sim/operation/failures/rel_mwing2"},	-- Misc wing 2 separate
{"Dref[n]","sim/operation/failures/rel_mwing3"},	-- Misc wing 3 separate
{"Dref[n]","sim/operation/failures/rel_mwing4"},	-- Misc wing 4 separate
{"Dref[n]","sim/operation/failures/rel_mwing5"},	-- Misc wing 5 separate
{"Dref[n]","sim/operation/failures/rel_mwing6"},	-- Misc wing 6 separate
{"Dref[n]","sim/operation/failures/rel_mwing7"},	-- Misc wing 7 separate
{"Dref[n]","sim/operation/failures/rel_mwing8"},	-- Misc wing 8 separate
{"Dref[n]","sim/operation/failures/rel_pyl1a"},	-- Engine Pylon 1a Separate
{"Dref[n]","sim/operation/failures/rel_pyl2a"},	-- Engine Pylon 2a Separate
{"Dref[n]","sim/operation/failures/rel_pyl3a"},	-- Engine Pylon 3a Separate
{"Dref[n]","sim/operation/failures/rel_pyl4a"},	-- Engine Pylon 4a Separate
{"Dref[n]","sim/operation/failures/rel_pyl5a"},	-- Engine Pylon 5a Separate
{"Dref[n]","sim/operation/failures/rel_pyl6a"},	-- Engine Pylon 6a Separate
{"Dref[n]","sim/operation/failures/rel_pyl7a"},	-- Engine Pylon 7a Separate
{"Dref[n]","sim/operation/failures/rel_pyl8a"},	-- Engine Pylon 8a Separate
{"Dref[n]","sim/operation/failures/rel_pyl1b"},	-- Engine Pylon 1b Separate
{"Dref[n]","sim/operation/failures/rel_pyl2b"},	-- Engine Pylon 2b Separate
{"Dref[n]","sim/operation/failures/rel_pyl3b"},	-- Engine Pylon 3b Separate
{"Dref[n]","sim/operation/failures/rel_pyl4b"},	-- Engine Pylon 4b Separate
{"Dref[n]","sim/operation/failures/rel_pyl5b"},	-- Engine Pylon 5b Separate
{"Dref[n]","sim/operation/failures/rel_pyl6b"},	-- Engine Pylon 6b Separate
{"Dref[n]","sim/operation/failures/rel_pyl7b"},	-- Engine Pylon 7b Separate
{"Dref[n]","sim/operation/failures/rel_pyl8b"},	-- Engine Pylon 8b Separate
{"Dref[n]","sim/operation/failures/rel_gen_esys"},	-- General electrical failure
{"Dref[n]","sim/operation/failures/rel_gen_avio"},	-- General avionics bus failure
{"Dref[n]","sim/operation/failures/rel_apu"},	-- APU failure to start or run
{"Dref[n]","sim/operation/failures/rel_apu_fire"},	-- APU catastrophic failure with fire
}
--[[ Container Table for the Datarefs to be monitored. Datarefs are stored in subtables {dataref,type,{dataref value(s) storage 1 as specified by dataref length}, {dataref value(s) storage 2 as specified by dataref length}, dataref handler} ]]
local MiscUtils_Datarefs = {
"DATAREF",
}
--[[ Menu item table. The first item ALWAYS contains the menu's title! All other items list the menu item's name. ]]
local MiscUtils_Menu_Items = {
"Miscellaneous",  -- Menu title, index 1
" ",        -- Index: 2
"Synchronize Baros", -- Index: 3
"[Separator]",       -- Index: 4
"Next Livery",       -- Index: 5
"Previous Livery",   -- Index: 6
"[Separator]",       -- Index: 7
"Synchronize Date",  -- Index: 8
"Synchronize Time",  -- Index: 9
"[Separator]",       -- Index: 10
"Power Monitor",     -- Index: 11
}

--[[

DATAREFS

]]
simDR_Baro_CoPilot = find_dataref("sim/cockpit2/gauges/actuators/barometer_setting_in_hg_copilot") -- Barometer synchronization
simDR_Baro_Pilot = find_dataref("sim/cockpit2/gauges/actuators/barometer_setting_in_hg_pilot") -- Barometer synchronization
simDR_Baro_Stby = find_dataref("sim/cockpit2/gauges/actuators/barometer_setting_in_hg_stby") -- Barometer synchronization
simDR_Date = find_dataref("sim/time/local_date_days")   -- Date synchronization
simDR_EngineCHT = find_dataref("sim/cockpit2/engine/indicators/CHT_CYL_deg_C") -- Power monitor
simDR_EngineFF = find_dataref("sim/cockpit2/engine/indicators/fuel_flow_kg_sec") -- Power monitor
simDR_EngineRPM = find_dataref("sim/cockpit2/engine/indicators/engine_speed_rpm") -- Power monitor
simDR_EngineRunning = find_dataref("sim/flightmodel/engine/ENGN_running") -- Power monitor
simDR_EngineType = find_dataref("sim/aircraft/prop/acf_en_type") -- Power monitor
simDR_GroundSpeed = find_dataref("sim/flightmodel2/position/groundspeed") -- For repair function
simDR_Input_Mixture = find_dataref("sim/cockpit2/engine/actuators/mixture_ratio_all") -- Power monitor
simDR_Input_Prop = find_dataref("sim/cockpit2/engine/actuators/prop_rotation_speed_rad_sec_all") -- Power monitor
simDR_Input_Throttle = find_dataref("sim/cockpit2/engine/actuators/throttle_ratio_all") -- Power monitor
simDR_Livery_Path = find_dataref("sim/aircraft/view/acf_livery_path") -- Livery switcher
simDR_ManifoldPress = find_dataref("sim/cockpit2/engine/indicators/MPR_in_hg") -- Power monitor
simDR_Num_Engines = find_dataref("sim/aircraft/engine/acf_num_engines") -- Power monitor
simDR_OnGround = find_dataref("sim/flightmodel/failures/onground_any") -- For repair function
simDR_Power_Current = find_dataref("sim/cockpit2/engine/indicators/power_watts") -- Power monitor
simDR_Power_Max = find_dataref("sim/aircraft2/engine/max_power_limited_watts") -- Power monitor
simDR_Time_Local = find_dataref("sim/time/zulu_time_sec") -- Time synchronization
simDR_Time_Running = find_dataref("sim/time/total_running_time_sec") -- Power monitor
--[[

COMMANDS

]]
simCMD_Livery_Next = find_command("sim/operation/next_livery")
simCMD_Livery_Prev = find_command("sim/operation/prev_livery")
simCMD_Reload_Scenery = find_command("sim/operation/reload_scenery")
--[[

VARIABLES

]]
--[[ Local variables ]]
local Baro_Pilot_Old = simDR_Baro_Pilot
local Baro_CoPilot_Old = simDR_Baro_CoPilot
local Baro_Stby_Old = simDR_Baro_Stby
local Livery = {Current="",Old=""}
local Power_Monitor_Vars = {Thr_Old=0,Mix_Old=0,Prp_Old=0,Num_Pwr=0,Notify_ID=-111111,Notify_String="",Notify_Time=0,S_Pwr="",S_BHP="",S_RPM="",S_MPR="",S_CHT="",S_FF=""}
--[[ Menu variables for FFI ]]
local MiscUtils_Menu_ID = nil
local MiscUtils_Menu_Pointer = ffi.new("const char")
--[[

FUNCTIONS

]]
--[[ Determine number of engines running ]]
function AllEnginesRunning()
    local j=0
    for i=0,(NumEngines-1) do if simDR_EngineRunning[i] == 1 then j = j + 1 end end
    if j == NumEngines then return 1 end
    if j < NumEngines then return 0 end
end
--[[ Synchronize baros ]]
function Sync_Baros()
    if simDR_Baro_Pilot ~= Baro_Pilot_Old then
        simDR_Baro_CoPilot = simDR_Baro_Pilot
        Baro_CoPilot_Old = simDR_Baro_CoPilot
        simDR_Baro_Stby = simDR_Baro_Pilot
        Baro_Stby_Old = simDR_Baro_Stby
        Baro_Pilot_Old = simDR_Baro_Pilot
    end
    if simDR_Baro_CoPilot ~= Baro_CoPilot_Old then
        simDR_Baro_Pilot = simDR_Baro_CoPilot
        Baro_Pilot_Old = simDR_Baro_Pilot
        simDR_Baro_Stby = simDR_Baro_CoPilot
        Baro_Stby_Old = simDR_Baro_Stby
        Baro_CoPilot_Old = simDR_Baro_CoPilot
    end
    if simDR_Baro_Stby ~= Baro_Stby_Old then
        simDR_Baro_Pilot = simDR_Baro_Stby
        Baro_Pilot_Old = simDR_Baro_Pilot
        simDR_Baro_CoPilot = simDR_Baro_Stby
        Baro_CoPilot_Old = simDR_Baro_CoPilot
        Baro_Stby_Old = simDR_Baro_Stby
    end
end
--[[ Adds a string to a string variable ]]
function PowerMonitor_AddString(target,instring,separator)
    if separator == nil then separator = " " end
    if target == "" then target = instring
    else target = target..separator..instring end
    return target
end
--[[ Monitors throttle, prop and mixture for changes ]]
function Power_Monitor()
    Power_Monitor_Vars.Notify_String = ""
    Power_Monitor_Vars.S_Pwr = ""
    Power_Monitor_Vars.S_BHP = ""
    Power_Monitor_Vars.S_RPM = ""
    Power_Monitor_Vars.S_MPR = ""
    Power_Monitor_Vars.S_CHT = ""
    Power_Monitor_Vars.S_FF = ""
    -- Monitor the throttle, mixture and prop levers for changes
    if math.abs(simDR_Input_Throttle - Power_Monitor_Vars.Thr_Old) > Table_ValGet(MiscUtils_Config_Vars,"PowerMonitorInputChange",nil,2) or math.abs(simDR_Input_Mixture - Power_Monitor_Vars.Mix_Old) > Table_ValGet(MiscUtils_Config_Vars,"PowerMonitorInputChange",nil,2) or math.abs(simDR_Input_Prop - Power_Monitor_Vars.Prp_Old) > Table_ValGet(MiscUtils_Config_Vars,"PowerMonitorInputChange",nil,2) then
        for i=0,(simDR_Num_Engines-1) do
            if simDR_EngineRunning[i] == 1 then
                -- Check if there already is a notification
                if not CheckNotification(Power_Monitor_Vars.Notify_ID) then DisplayNotification("Power Monitor: Placeholder","Nominal",Power_Monitor_Vars.Notify_ID) end -- Create the notification if there is none
                Power_Monitor_Vars.Notify_Time = simDR_Time_Running -- Update the creation time for the notification
            end
        end
        -- Update the old variables
        Power_Monitor_Vars.Thr_Old = simDR_Input_Throttle
        Power_Monitor_Vars.Mix_Old = simDR_Input_Mixture
        Power_Monitor_Vars.Prp_Old = simDR_Input_Prop
    end
    -- Loop through all engines
    Power_Monitor_Vars.Num_Pwr = 0
    for i=0,(simDR_Num_Engines-1) do
        if simDR_EngineRunning[i] == 1 and simDR_Power_Current[i] > 0 then
            Power_Monitor_Vars.Num_Pwr = Power_Monitor_Vars.Num_Pwr + 1
            if simDR_EngineType[i] == 0 or simDR_EngineType[i] == 1 or simDR_EngineType[i] == 9 or simDR_EngineType[i] == 10 then -- Recip and turboprop engines only
                local power = (simDR_Power_Current[i] / simDR_Power_Max)*100 -- Calculate engine power
                if i > 0 then Power_Monitor_Vars.S_Pwr = PowerMonitor_AddString(Power_Monitor_Vars.S_Pwr,"",", ") end
                Power_Monitor_Vars.S_Pwr = PowerMonitor_AddString(Power_Monitor_Vars.S_Pwr,string.format("%d",power),"") -- Add power percentage
                if Table_ValGet(MiscUtils_Config_Vars,"PowerMonitorScalar",nil,2) ~= 1.0 then Power_Monitor_Vars.S_Pwr = PowerMonitor_AddString(Power_Monitor_Vars.S_Pwr," ("..string.format("%d",power * Table_ValGet(MiscUtils_Config_Vars,"PowerMonitorScalar",nil,2))..")","") end -- Add a note about a scalar
                Power_Monitor_Vars.S_BHP = PowerMonitor_AddString(Power_Monitor_Vars.S_BHP,string.format("%d",(simDR_Power_Current[i] * 0.00134102)),", ") -- Convert to horsepower
                Power_Monitor_Vars.S_RPM = PowerMonitor_AddString(Power_Monitor_Vars.S_RPM,string.format("%d",simDR_EngineRPM[i]),", ")
            end
            if simDR_EngineType[i] == 0 or simDR_EngineType[i] == 1 then
                Power_Monitor_Vars.S_MPR = PowerMonitor_AddString(Power_Monitor_Vars.S_MPR,string.format("%.2f",simDR_ManifoldPress[i]),", ")
                Power_Monitor_Vars.S_CHT = PowerMonitor_AddString(Power_Monitor_Vars.S_CHT,string.format("%d",simDR_EngineCHT[i]),", ")
            end
            if Table_ValGet(MiscUtils_Config_Vars,"PowerMonitorFuelUnit",nil,2) == "kg" then Power_Monitor_Vars.S_FF = PowerMonitor_AddString(Power_Monitor_Vars.S_FF,string.format("%.2f",simDR_EngineFF[i] * 3600),", ") end -- Convert kg/s to kg/h
            if Table_ValGet(MiscUtils_Config_Vars,"PowerMonitorFuelUnit",nil,2) == "lbs" then Power_Monitor_Vars.S_FF = PowerMonitor_AddString(Power_Monitor_Vars.S_FF,string.format("%.2f",simDR_EngineFF[i] * 3600 * 2.20462),", ") end -- Convert kg/s to kg/h to lbs/h
            if Table_ValGet(MiscUtils_Config_Vars,"PowerMonitorFuelUnit",nil,2) == "gal_avgas" then Power_Monitor_Vars.S_FF = PowerMonitor_AddString(Power_Monitor_Vars.S_FF,string.format("%.2f",simDR_EngineFF[i] * 3600 * 2.20462 / 5.87),", ") end -- Convert kg/s to kg/h to lbs/h to gal/h, conversion factor from x-plane
            if Table_ValGet(MiscUtils_Config_Vars,"PowerMonitorFuelUnit",nil,2) == "gal_jet-a" then Power_Monitor_Vars.S_FF = PowerMonitor_AddString(Power_Monitor_Vars.S_FF,string.format("%.2f",simDR_EngineFF[i] * 3600 * 2.20462 / 6.66),", ") end -- Convert kg/s to kg/h to lbs/h to gal/h
            if Table_ValGet(MiscUtils_Config_Vars,"PowerMonitorFuelUnit",nil,2) == "l_avgas" then Power_Monitor_Vars.S_FF = PowerMonitor_AddString(Power_Monitor_Vars.S_FF,string.format("%.2f",simDR_EngineFF[i] * 3600 / 0.719),", ") end -- Convert kg/s to kg/h to l/h
            if Table_ValGet(MiscUtils_Config_Vars,"PowerMonitorFuelUnit",nil,2) == "l_jet-a" then Power_Monitor_Vars.S_FF = PowerMonitor_AddString(Power_Monitor_Vars.S_FF,string.format("%.2f",simDR_EngineFF[i] * 3600 / 0.796),", ") end -- Convert kg/s to kg/h to l/h

        end
    end
    if Table_ValGet(MiscUtils_Config_Vars,"PowerMonitorFuelUnit",nil,2) == "gal_avgas" or Table_ValGet(MiscUtils_Config_Vars,"PowerMonitorFuelUnit",nil,2) == "gal_jet-a" then Power_Monitor_Vars.S_FF = PowerMonitor_AddString(Power_Monitor_Vars.S_FF,"gal/h"," ")
    elseif Table_ValGet(MiscUtils_Config_Vars,"PowerMonitorFuelUnit",nil,2) == "l_avgas" or Table_ValGet(MiscUtils_Config_Vars,"PowerMonitorFuelUnit",nil,2) == "l_jet-a" then Power_Monitor_Vars.S_FF = PowerMonitor_AddString(Power_Monitor_Vars.S_FF,"l/h"," ")
    else Power_Monitor_Vars.S_FF = PowerMonitor_AddString(Power_Monitor_Vars.S_FF,Table_ValGet(MiscUtils_Config_Vars,"PowerMonitorFuelUnit",nil,2).."\\h"," ") end

    Power_Monitor_Vars.Notify_String = " "..Power_Monitor_Vars.S_Pwr.." % | "..Power_Monitor_Vars.S_BHP.." bhp | "..Power_Monitor_Vars.S_RPM.." RPM | "..Power_Monitor_Vars.S_MPR.." inHg | "..Power_Monitor_Vars.S_CHT.." °C/°F | "..Power_Monitor_Vars.S_FF
    -- Do not display the power monitor notification when no throttle input has been detected after the time given by the configuration options
    if CheckNotification(Power_Monitor_Vars.Notify_ID) then
        UpdateNotification("Power Monitor:"..Power_Monitor_Vars.Notify_String,"Nominal",Power_Monitor_Vars.Notify_ID) -- Update the notification if it is being displayed
        if Table_ValGet(MiscUtils_Config_Vars,"PowerMonitorDisplayTime",nil,2) > 0 then
            if simDR_Time_Running > (Power_Monitor_Vars.Notify_Time + Table_ValGet(MiscUtils_Config_Vars,"PowerMonitorDisplayTime",nil,2)) or Power_Monitor_Vars.Notify_String == "" or Power_Monitor_Vars.Num_Pwr == 0 then RemoveNotification(Power_Monitor_Vars.Notify_ID) Power_Monitor_Vars.Notify_String = "" end
        else
            if Power_Monitor_Vars.Num_Pwr == 0 then RemoveNotification(Power_Monitor_Vars.Notify_ID) end
        end
    end
end
--[[

MENU

]]
--[[ Menu callbacks. The functions to run or actions to do when picking any non-title and nonseparator item from the table above ]]
function MiscUtils_Menu_Callbacks(itemref)
    for i=2,#MiscUtils_Menu_Items do
        if itemref == MiscUtils_Menu_Items[i] then
            if i == 2 then
                if (simDR_OnGround == 1 and simDR_GroundSpeed < 0.1 and AllEnginesRunning() == 0) or DebugIsEnabled() == 1 then Dataref_Write(MiscUtils_Datarefs,4,"All") DisplayNotification("All aircraft damage repaired!","Success",5) end
            end
            if i == 3 then
                if Table_ValGet(MiscUtils_Config_Vars,"SyncBaros",nil,2) == 0 then
                    Table_ValSet(MiscUtils_Config_Vars,"SyncBaros",nil,2,1) Sync_Baros() DebugLogOutput("Barometer synchronization: On") DisplayNotification("Barometer synchronization enabled.","Nominal",5)
                else
                    Table_ValSet(MiscUtils_Config_Vars,"SyncBaros",nil,2,0) DebugLogOutput("Barometer synchronization: Off") DisplayNotification("Barometer synchronization disabled.","Nominal",5)
                end
                Preferences_Write(MiscUtils_Config_Vars,XLuaUtils_PrefsFile)
            end
            if i == 5 then
                simCMD_Livery_Next:once()
            end
            if i == 6 then
                simCMD_Livery_Prev:once()
            end
            if i == 8 then
                DisplayNotification("Synchronizing XP Date ("..simDR_Date..") to System Date ("..(os.date("%j") - 1)..") and Reloading Scenery...","Nominal",5)
                simDR_Date = (os.date("%j") - 1) -- X-Plane starts its year's days at zero
                simCMD_Reload_Scenery:once()
            end
            if i == 9 then
                DisplayNotification("Synchronizing XP Local Time ("..simDR_Time_Local..") to System Time ("..((os.date("%H")*3600)+(os.date("%M")*60)+os.date("%S"))..")...","Nominal",5)
                simDR_Time_Local = (os.date("%H")*3600) + (os.date("%M")*60) + os.date("%S")
            end
            if i == 11 then
                if Table_ValGet(MiscUtils_Config_Vars,"PowerMonitor",nil,2) == 0 then
                    Table_ValSet(MiscUtils_Config_Vars,"PowerMonitor",nil,2,1) DebugLogOutput("Power monitor: On") DisplayNotification("Power Monitor enabled.","Nominal",5)
                else
                    Table_ValSet(MiscUtils_Config_Vars,"PowerMonitor",nil,2,0) DebugLogOutput("Power monitor: Off") DisplayNotification("Power Monitor disabled.","Nominal",5)
                end
                Preferences_Write(MiscUtils_Config_Vars,XLuaUtils_PrefsFile)
            end
            MiscUtils_Menu_Watchdog(MiscUtils_Menu_Items,i)
        end
    end
end
--[[ This is the menu watchdog that is used to check an item or change its prefix ]]
function MiscUtils_Menu_Watchdog(intable,index)
    if index == 2 then
        if (simDR_OnGround == 1 and simDR_GroundSpeed < 0.1 and AllEnginesRunning() == 0) or DebugIsEnabled() == 1 then Menu_ChangeItemPrefix(MiscUtils_Menu_ID,index,"Repair All Damage",intable) else Menu_ChangeItemPrefix(MiscUtils_Menu_ID,index,"[Can Not Repair]",intable) end
    end
    if index == 3 then
        if Table_ValGet(MiscUtils_Config_Vars,"SyncBaros",nil,2) == 1 then Menu_CheckItem(MiscUtils_Menu_ID,index,"Activate") else Menu_CheckItem(MiscUtils_Menu_ID,index,"Deactivate") end
    end
    if index == 11 then
        if Table_ValGet(MiscUtils_Config_Vars,"PowerMonitor",nil,2) == 1 then Menu_CheckItem(MiscUtils_Menu_ID,index,"Activate") else Menu_CheckItem(MiscUtils_Menu_ID,index,"Deactivate") end
    end
end
--[[ Registration routine for the menu ]]
function MiscUtils_Menu_Register()
    if XPLM ~= nil and MiscUtils_Menu_ID == nil then
        local Menu_Index = nil
        Menu_Index = XPLM.XPLMAppendMenuItem(XLuaUtils_Menu_ID,MiscUtils_Menu_Items[1],ffi.cast("void *","None"),1)
        MiscUtils_Menu_ID = XPLM.XPLMCreateMenu(MiscUtils_Menu_Items[1],XLuaUtils_Menu_ID,Menu_Index,function(inMenuRef,inItemRef) MiscUtils_Menu_Callbacks(inItemRef) end,ffi.cast("void *",MiscUtils_Menu_Pointer))
        MiscUtils_Menu_Build()
        DebugLogOutput(MiscUtils_Config_Vars[1][1].." Menu registered!")
    end
end
--[[ Initialization routine for the menu ]]
function MiscUtils_Menu_Build()
    XPLM.XPLMClearAllMenuItems(MiscUtils_Menu_ID)
    local Menu_Indices = {}
    if XLuaUtils_HasConfig == 1 then
        for i=2,#MiscUtils_Menu_Items do Menu_Indices[i] = 0 end
        if MiscUtils_Menu_ID ~= nil then
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
            DebugLogOutput(MiscUtils_Config_Vars[1][1].." Menu built!")
        end
    end
end
--[[

RUNTIME CALLBACKS

]]
--[[ Module Main Timer ]]
function MiscUtils_MainTimer()
    MiscUtils_Menu_Watchdog(MiscUtils_Menu_Items,2)
    if Table_ValGet(MiscUtils_Config_Vars,"SyncBaros",nil,2) == 1 then Sync_Baros() end
    if Table_ValGet(MiscUtils_Config_Vars,"PowerMonitor",nil,2) == 1 then Power_Monitor() elseif CheckNotification(Power_Monitor_Vars.Notify_ID) then RemoveNotification(Power_Monitor_Vars.Notify_ID) end
    if simDR_Livery_Path:match("liveries/(.*)/") == nil then Livery.Current = "Default" else Livery.Current = simDR_Livery_Path:match("liveries/(.*)/") end
    if Livery.Old ~= Livery.Current then
        DisplayNotification("Using livery: "..Livery.Current,"Nominal",5)
        Livery.Old = Livery.Current
    end
    --print((os.date("%H")*3600)+(os.date("%M")*60)+(os.date("%S")))
end
--[[

INITIALIZATION

]]
--[[ Module is run for the very first time ]]
function MiscUtils_FirstRun()
    Preferences_Write(MiscUtils_Config_Vars,XLuaUtils_PrefsFile)
    DrefTable_Read(Dref_List,MiscUtils_Datarefs)
    LogOutput(MiscUtils_Config_Vars[1][1]..": First Run!")
end
--[[ Module initialization at every Xlua Utils start ]]
function MiscUtils_Init()
    Preferences_Read(XLuaUtils_PrefsFile,MiscUtils_Config_Vars)
    if XLuaUtils_HasConfig == 1 then
        DrefTable_Read(Dref_List,MiscUtils_Datarefs)
        Dataref_Read(MiscUtils_Datarefs,5,"All") -- Populate dataref container with current values as defaults
        Dataref_Read(MiscUtils_Datarefs,4,"All") -- Populate dataref container with current values
        for i=2,#MiscUtils_Datarefs do MiscUtils_Datarefs[i][4][1] = 0 end -- Zero all datarefs
        run_at_interval(MiscUtils_MainTimer,Table_ValGet(MiscUtils_Config_Vars,"MainTimerInterval")) -- Timer to monitor airplane status
        if is_timer_scheduled(MiscUtils_MainTimer) then DisplayNotification("Misc Utils: Initialized","Nominal",5) end
        MiscUtils_Menu_Register()
    end
    LogOutput(MiscUtils_Config_Vars[1][1]..": Initialized!")
end
--[[ Module reload ]]
function MiscUtils_Reload()
    Preferences_Read(XLuaUtils_PrefsFile,MiscUtils_Config_Vars)
    MiscUtils_Menu_Build()
    LogOutput(MiscUtils_Config_Vars[1][1]..": Reloaded!")
end
