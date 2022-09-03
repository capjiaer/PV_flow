#0>> Import packages for the furture usage
lappend auto_path "/home/apchen1/project/module_setup/calibre/module"
package require file_edit_func
package require gen_deck_header
package require data_func

#1>> Setup the params for calibre pv run
# The target action here is CbFPDummyFEOL CbFPDummyBEOL CbFinalDummyFEOL CbFinalDummyBEOL  
set target_action $::env(TARGET_NAME)
set flowtype "DUMMY"
# Check layout system, get datatype(dfmdbtype) as gds/oas || datatype(layouttype) as GDSII/OASIS
array set datatype [data_func::get_datatype]
# Get $db_dir(inputdb) | $db_dir(outputdb) | $db_dir(prefix) | $db_dir(temp_output) | $db_dir(stage)
array set db_dir [data_func::get_dbdir $target_action $datatype(dfmdbtype)] 
# Setup dir for further usage
file mkdir $::env(BASE_DIR)/data/$db_dir(prefix)
set workdir [file join $::env(BASE_DIR) data $db_dir(prefix)]

# Backup old *.csh/*.tcl/*.log files if exist, regexp may help for this
set stage [string toupper $db_dir(stage)]
old_files::backup 1 old_files *${stage}.*log *${stage}.*csh
# Setup env data for further usage
set required_params [file join $::env(BASE_DIR) data $db_dir(prefix) ${db_dir(prefix)}_${db_dir(stage)}_parameter.tcl]
file_edit_func::get_para_data $required_params $::env(BASE_DIR)/tile.params 3

#1.1 Import user params
source /home/apchen1/project/module_setup/calibre/decksetup/TSMC/default_setup.tcl
source $required_params

##########################################################
#2>> Deal with rule deck
#2.1 Prepare header

set rule_header [file join $::env(BASE_DIR) data $db_dir(prefix) $target_action.svrf]
set rulefileheader [open $rule_header "w"]
# Basic setup done, work for ruleheader generation
# Write input data path 
gen_deck_header::write_input_data_to_file $rulefileheader $db_dir(inputdb) $::env(TOP_MODULE) $datatype(layouttype) 
# Write check window situation 
gen_deck_header::write_check_window_to_file $rulefileheader $flowtype 
# Write report names to file 
gen_deck_header::write_report_names_to_file $rulefileheader $workdir DRC $flowtype 
# Write exclude cell to file
gen_deck_header::write_exclude_cell_to_file $rulefileheader $flowtype 
# Write rule_switches to file 
gen_deck_header::write_rule_switches_to_file $rulefileheader $flowtype 0 $db_dir(stage)
# Write rule_select to file 
gen_deck_header::write_rule_select_to_file $rulefileheader $flowtype
# Write virtual_connects to file
gen_deck_header::write_virtual_connects_to_file $rulefileheader $flowtype
# DFM DB part
gen_deck_header::write_dfm_output_to_file $rulefileheader $flowtype
# This line is always required for the rule deck, we need to override layout data in include files
puts $rulefileheader "DRC ICSTATION YES"
# Write user include file 
set default_rule_deck /home/apchen1/project/module_setup/rule_deck/mfill/modified/Dummy_${db_dir(stage)}_CalibreYE_5nm_014.12a
gen_deck_header::write_user_include_to_file $rulefileheader $flowtype $db_dir(stage) $default_rule_deck
# Done for all rule setup
close $rulefileheader
###########################################################
#3>> Write final run file
set timestamp			[clock format [clock seconds] -format %Y_%m_%d_%H_%M_%S]
set cshfile				[file join $::env(BASE_DIR) data $db_dir(prefix) $target_action.$timestamp.csh]
# Logfile setup
set log_file calibre_${timestamp}_$::env(TARGET_NAME).log 

# Options: set execopt(exec_opt_str) "-$flowtype -heir -turbo $cpuusage" | set execopt(lsf_remote_str) "$lsf_remote_str"
array set execopt [data_func::get_execopt $flowtype]
#4>> Write final run file
set mapdict [dict create	layout_type $datatype(layouttype) design $db_dir(inputdb)		\
							work_dir $workdir topcell $::env(TOP_MODULE) logfile $log_file	\

							timestamp $timestamp execoptstr $execopt(exec_opt_str)			\
							lsfremotestr $execopt(lsf_remote_str) ruleheader $rule_header	\
			] 
# Create mapdict for rule_temp::write_file to genarate final run cshfile
set mfill_temp	[file normalize [file join ./PV_flow/template/mfill dummy.csh.temp]]
rule_temp::write_file $mfill_temp $cshfile $mapdict -permissions rwxr-xr-x
#5>> Run target then generate dummy db 
exec $cshfile












