#0>> Import packages for the furture usage
lappend auto_path "./PV_flow/calibre/module"
package require file_edit_func 
package require gen_deck_header
package require data_func

#1>> Setup the params for calibre pv run
# The target action here is CbFPDRC CbFinalDRC  
set target_action $::env(TARGET_NAME)
set flowtype "DRC"
# Check layout system, get datatype(dfmdbtype) as gds/oas || datatype(layouttype) as GDSII/OASIS base on pv_calibre(layout_system)
array set datatype [data_func::get_datatype]

# Get $db_dir(inputdb) | $db_dir(outputdb) | $db_dir(prefix) | $db_dir(temp_output) | $db_dir(stage)
array set db_dir [data_func::get_dbdir $target_action $datatype(dfmdbtype)] 
# Setup dir for further usage
file mkdir $::env(BASE_DIR)/data/$target_action
set workdir [file join $::env(BASE_DIR) data $target_action]
# Setup env data for further usage

# Add sanity check 20220804, re-setup flow structure
set default_rule_deck path/rule_deck/drc/modified/CLN5LO_15M_1X1Xb1Xe1Ya1Yb5Y2Yy2Z_014.12a.encrypt
set sanity_rule_deck path/rule_deck/drc/modified/CLN5LO_SRAM_SANITY_15M_1X1Xb1Xe1Ya1Yb5Y2Yy2Z_015.11a.encrypt

#3>> Write final run file
set timestamp			[clock format [clock seconds] -format %Y_%m_%d_%H_%M_%S]
if {[info exists ::env(PV_CALIBRE_DRC_sanity_check_only)] && $::env(PV_CALIBRE_DRC_sanity_check_only) == 1} {
	# If sanity_check_only set as 1, then the flow working on sanity_check type
	# Backup old csh/tcl/log file if exist
	old_files::backup 1 old_files sanity_*.log sanity_*.csh
	set drc_rule_deck		$sanity_rule_deck
	set rule_header			[file join $::env(BASE_DIR) data $target_action sanity_$target_action.svrf]
  

	set rulefileheader		[open $rule_header "w"]
	set required_params		[file join $::env(BASE_DIR) data $target_action sanity_${target_action}_parameter.tcl]
	#Cshfile setup
	set cshfile				[file join $::env(BASE_DIR) data $db_dir(prefix) sanity_$target_action.$timestamp.csh]
	# Logfile setup
	set log_file			sanity_calibre_${timestamp}_$::env(TARGET_NAME).log 
} else {
	# Default settings
	# Backup old csh/tcl/log file if exist
  	old_files::backup 1 old_files *.log *.csh
	set drc_rule_deck		$default_rule_deck
	set rule_header			[file join $::env(BASE_DIR) data $target_action $target_action.svrf]
	set rulefileheader		[open $rule_header "w"]
	set required_params		[file join $::env(BASE_DIR) data $target_action ${target_action}_parameter.tcl]
	#Cshfile setup
  	set cshfile				[file join $::env(BASE_DIR) data $db_dir(prefix) $target_action.$timestamp.csh]
	# Logfile setup
	set log_file			calibre_${timestamp}_$::env(TARGET_NAME).log 
}	
# FLow structure update done

file_edit_func::get_para_data $required_params $::env(BASE_DIR)/tile.params 3
#1.1 Import user params
source ./PV_flow/TSMC/default_setup.tcl
source $required_params

##########################################################
#2>> Deal with rule deck
# Basic setup done, work for ruleheader generation
# Write input datapath 
gen_deck_header::write_input_data_to_file $rulefileheader $db_dir(inputdb) $::env(TOP_MODULE) $datatype(layouttype) 
# Write check window situation 
gen_deck_header::write_check_window_to_file $rulefileheader $flowtype 
# Write report names to file 
gen_deck_header::write_report_names_to_file $rulefileheader $workdir DRC 
# Write exclude cell to file
gen_deck_header::write_exclude_cell_to_file $rulefileheader $flowtype 
# Write rule_switches to file 
if {[info exists ::env(PV_CALIBRE_DRC_sanity_check_only)] && $::env(PV_CALIBRE_DRC_sanity_check_only) == 1} {
	gen_deck_header::write_rule_switches_to_file $rulefileheader $flowtype 1 sanity_check 
} else {
	gen_deck_header::write_rule_switches_to_file $rulefileheader $flowtype 0 
}
# Write rule_select to file 
gen_deck_header::write_rule_select_to_file $rulefileheader $flowtype
# Write virtual_connects to file
gen_deck_header::write_virtual_connects_to_file $rulefileheader $flowtype
# DFM DB part
gen_deck_header::write_dfm_output_to_file $rulefileheader $flowtype
# This line is always required for the rule deck, we need to override layout data in include files
puts $rulefileheader "DRC ICSTATION YES"
# Write user include file 
gen_deck_header::write_user_include_to_file $rulefileheader $flowtype $db_dir(stage) $drc_rule_deck
# Done for all rule setup
close $rulefileheader
###########################################################
# Options: set execopt(exec_opt_str) "-$flowtype -heir -turbo $cpuusage" | set execopt(lsf_remote_str) "$lsf_remote_str"
array set execopt [data_func::get_execopt $flowtype]

# Waive flow update 20220808
set execopt(exec_opt_str) [append execopt(exec_opt_str) " " [gen_deck_header::get_waive_str $workdir $flowtype]]

#4>> Write final run file
set mapdict [dict create	layout_type $datatype(layouttype) design $db_dir(inputdb)		\
							work_dir $workdir topcell $::env(TOP_MODULE) logfile $log_file	\
							timestamp $timestamp execoptstr $execopt(exec_opt_str)			\
							lsfremotestr $execopt(lsf_remote_str) ruleheader $rule_header	\
			] 
# Create mapdict for rule_temp::write_file to genarate final run cshfile
set drc_temp	[file join /home/apchen1/project/module_setup/calibre/template/ drc.csh.temp]

rule_temp::write_file $drc_temp $cshfile $mapdict -permissions rwxr-xr-x
#5>> Run target then generate drc results 
set flowtype [string tolower $flowtype]
if {$pv_calibre($flowtype,gen_header_only) ne 1} {
	exec $cshfile
} else {
	puts "Genarate header file only"
}



















