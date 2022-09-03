#0>> Import packages for the furture usage
lappend auto_path "/home/apchen1/project/module_setup/calibre/module"
package require file_edit_func 
package require gen_deck_header
package require data_func

#1>> Setup the params for calibre pv run
# The target action here is CbFinalCNOD, but it will be included in the CbFinalPERC run, if $::env(TARGET_NAME) eq CbFinalPERC, this script works  
set target_action $::env(TARGET_NAME)
set flowtype "CNOD"
set sub_stage [string tolower $flowtype]

# Check layout system, get datatype(dfmdbtype) as gds/oas || datatype(layouttype) as GDSII/OASIS base on pv_calibre(layout_system)
array set datatype [data_func::get_datatype]
# Get $db_dir(inputgds) | $db_dir(intputspi) | $db_dir(outputdb) | $db_dir(prefix) | $db_dir(temp_output)
array set db_dir [data_func::get_dbdir $target_action $datatype(dfmdbtype)] 
# Setup dir for further usage
file mkdir $::env(BASE_DIR)/data/$target_action/cnod

set workdir [file join $::env(BASE_DIR) data $target_action]
# Setup env data for further usage
set required_params [file join $workdir CbFinalCNOD_parameter.tcl]
file_edit_func::get_para_data $required_params $::env(BASE_DIR)/tile.params 3
#1.1 Import user params

source /home/apchen1/project/module_setup/calibre/decksetup/TSMC/default_setup.tcl
source $required_params

if {[info exist pv_calibre(perc,skip_cnod)] && $pv_calibre(perc,skip_cnod) == "1"} {
	puts "pv_calibre(perc,skip_cnod) default is 0, and cnod perc will be executed by default"
	puts "Cause pv_calibre(perc,skip_cnod) set as 1 by user, skip cnod perc check,"
	exit
}

##########################################################
#2>> Deal with rule deck
if {[info exist pv_calibre(perc,cnod,black_box_enable)] && $pv_calibre(perc,cnod,black_box_enable) == 1} {
	# black_box_enable set as 1, now the perc run turns out to be a drc run
	set sub_stage "black_box_check"
	#2.1 Prepare header
	set box_workdir [file join $workdir $sub_stage]
	# Backup old csh/tcl/log file if exist
	old_files::backup $box_workdir old_files *.log *.csh
	set rule_header [file join $box_workdir CbFinalCNOD_black_box.svrf]
	set rulefileheader [open $rule_header "w"]
	# Basic setup done, work for ruleheader generation
  gen_deck_header::write_input_data_to_file $rulefileheader $db_dir(inputgds) $::env(TOP_MODULE) $datatype(layouttype) 
	# Write check window situation 
	gen_deck_header::write_check_window_to_file $rulefileheader $flowtype 
	# Write report names to file 
	gen_deck_header::write_report_names_to_file $rulefileheader $box_workdir DRC PERC
	# Write exclude cell to file
  gen_deck_header::write_exclude_cell_to_file $rulefileheader $flowtype 
	# Write rule_switches to file here is defined by pv_calibre(perc,cnod,black_box_check,default,*)
	gen_deck_header::write_rule_switches_to_file $rulefileheader PERC 0 "cnod,black_box_check"
	# Cause black_box_check enabled, below variable setup reuqired
	if {[info exist pv_calibre(perc,cnod,black_box_cell)] && $pv_calibre(perc,cnod,black_box_cell) ne ""} {
  		puts $rulefileheader "VARIABLE CNOD_BLACK_BOX_CELLS [regsub -all {\S+} $pv_calibre(perc,cnod,black_box_cell) \"&\"]"
	} else {
		puts "pv_calibre(perc,cnod,black_box_cell) is required, plesae setup this variable for perc cnod black_box_enable run" 
		error "Error out and reset variables"
	}
	# Write rule_select to file 
	gen_deck_header::write_rule_select_to_file $rulefileheader "perc,cnod,black_box_check"
	# Write virtual_connects to file
	gen_deck_header::write_virtual_connects_to_file $rulefileheader $flowtype
	# This line is always required for the rule deck, we need to override layout data in include files
	puts $rulefileheader "DRC ICSTATION YES"
	# Write user include file 
	set default_rule_deck /home/apchen1/project/module_setup/rule_deck/perc/cnod/modified/CLN5LO_CNOD_Black_Box_Checker.12a
	gen_deck_header::write_user_include_to_file $rulefileheader $flowtype $sub_stage $default_rule_deck
	# Done for all rule setup
	close $rulefileheader
	#3>> Write final run file
	set timestamp			[clock format [clock seconds] -format %Y_%m_%d_%H_%M_%S]
	set cshfile				[file join $::env(BASE_DIR) data $db_dir(prefix) $sub_stage $sub_stage.$timestamp.csh]
	# Logfile setup
	set log_file calibre_${timestamp}_$::env(TARGET_NAME)_$sub_stage.log 
	# Options: set execopt(exec_opt_str) "-$flowtype -heir -turbo $cpuusage" | set execopt(lsf_remote_str) "$lsf_remote_str"
	array set execopt [data_func::get_execopt PERC]
  	#4>> Write final run file
	set mapdict [dict create	layout_type $datatype(layouttype) design $db_dir(inputgds)			\
								work_dir $box_workdir topcell $::env(TOP_MODULE) logfile $log_file	\
								timestamp $timestamp execoptstr $execopt(exec_opt_str)				\
								lsfremotestr $execopt(lsf_remote_str) ruleheader $rule_header		\
				]	 
	# Create mapdict for rule_temp::write_file to genarate final run cshfile
	set cnod_temp	[file join /home/apchen1/project/module_setup/calibre/template/perc/ black_box_check.csh.temp]
	rule_temp::write_file $cnod_temp $cshfile $mapdict -permissions rwxr-xr-x
	#5>> Run target then generate drc results 
	set flowtype [string tolower $flowtype]
	if {$pv_calibre(perc,$flowtype,gen_header_only) ne 1} {        
		exec $cshfile
	} else {
		puts "Genarate header file only"
	}
} else {
	#2.1 Prepare header
	set cnod_workdir [file join $workdir cnod]
	# Backup old csh/tcl/log file if exist
	old_files::backup $cnod_workdir old_files *.log *.csh
	set rule_header [file join $cnod_workdir CbFinalCNOD.svrf]
	set rulefileheader [open $rule_header "w"]
	# Basic setup done, work for ruleheader generation
	gen_deck_header::write_input_data_to_file $rulefileheader $db_dir(inputgds) $::env(TOP_MODULE) $datatype(layouttype) 
	# Write check window situation 
  gen_deck_header::write_check_window_to_file $rulefileheader $flowtype 
	# Write report names to file 
	gen_deck_header::write_report_names_to_file $rulefileheader $cnod_workdir PERC $sub_stage $sub_stage
	# Write exclude cell to file
	gen_deck_header::write_exclude_cell_to_file $rulefileheader $flowtype 
	# Write rule_switches to file 
	gen_deck_header::write_rule_switches_to_file $rulefileheader PERC 0 $sub_stage
	# Setup LVS BOX here, this part didn't merge with previous lvs box settings casue they belong to different flowtype
	# When runing CNOD at sys or full chip level, it is recommended to box smaller cells that have already been checked
	if {[info exist pv_calibre(perc,cnod,lvs_box_cell)] && $pv_calibre(perc,cnod,lvs_box_cell) ne ""} {
		set boxstr [split $pv_calibre(perc,cnod,lvs_box_cell)]
		puts $rulefileheader "// LVS BOX settings"
		puts $rulefileheader "LVS BOX [regsub -all {\S+} $pv_calibre(perc,cnod,lvs_box_cell) \"&\"]"
		# Define cells as Hcells to preserve them (source cell and layout cell must match)
		foreach ele $boxstr {
			puts $rulefileheader "HCELL $ele $ele"
		}
	}
	# Write rule_select to file 
	gen_deck_header::write_rule_select_to_file $rulefileheader $flowtype
	# Write virtual_connects to file
	gen_deck_header::write_virtual_connects_to_file $rulefileheader $flowtype
	# This line is always required for the rule deck, we need to override layout data in include files
	puts $rulefileheader "DRC ICSTATION YES"
	# Write user include file 
	set default_rule_deck /home/apchen1/project/module_setup/rule_deck/perc/cnod/modified/1P15M_1X1XB1XE1YA1YB5Y2YY2Z/perc_n05_1P15M_1X1Xb1Xe1Ya1Yb5Y2Yy2Z.top
	gen_deck_header::write_user_include_to_file $rulefileheader $flowtype $sub_stage $default_rule_deck
	# Done for all rule setup
	close $rulefileheader
	###########################################################
	#3>> Write final run file
	set timestamp			[clock format [clock seconds] -format %Y_%m_%d_%H_%M_%S]
	set cshfile				[file join $::env(BASE_DIR) data $db_dir(prefix) $sub_stage $sub_stage.$timestamp.csh]
	# Logfile setup
	set log_file calibre_${timestamp}_$::env(TARGET_NAME)_$sub_stage.log 
	# Options: set execopt(exec_opt_str) "-$flowtype -heir -turbo $cpuusage" | set execopt(lsf_remote_str) "$lsf_remote_str"
	array set execopt [data_func::get_execopt PERC]
	#4>> Write final run file
	set mapdict [dict create	layout_type $datatype(layouttype) design $db_dir(inputgds)			\
								work_dir $cnod_workdir topcell $::env(TOP_MODULE) logfile $log_file	\
								timestamp $timestamp execoptstr $execopt(exec_opt_str)				\
								lsfremotestr $execopt(lsf_remote_str) ruleheader $rule_header		\
				]	 
	# Create mapdict for rule_temp::write_file to genarate final run cshfile
	set cnod_temp	[file join /home/apchen1/project/module_setup/calibre/template/perc/ cnod.csh.temp]
	rule_temp::write_file $cnod_temp $cshfile $mapdict -permissions rwxr-xr-x

	#5>> Run target then generate drc results 
	set flowtype [string tolower $flowtype]
	if {$pv_calibre(perc,$flowtype,gen_header_only) ne 1} {
		exec $cshfile
	} else {
		puts "Genarate header file only"
	}
}

















