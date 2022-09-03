#0>> Import packages for the furture usage
lappend auto_path "/home/apchen1/project/module_setup/calibre/module"
package require file_edit_func 
package require gen_deck_header
package require data_func

#1>> Setup the params for calibre pv run
# The target action here is CbFPPERC CbFinalPERC  
set target_action $::env(TARGET_NAME)
set flowtype "PERC"
# Check layout system, get datatype(dfmdbtype) as gds/oas || datatype(layouttype) as GDSII/OASIS base on pv_calibre(layout_system)
array set datatype [data_func::get_datatype]
# Setup dir for further usage
file mkdir $::env(BASE_DIR)/data/$target_action
set workdir [file join $::env(BASE_DIR) data $target_action]
# Setup env data for further usage
set required_params [file join $::env(BASE_DIR) data $target_action ${target_action}_parameter.tcl]
file_edit_func::get_para_data $required_params $::env(BASE_DIR)/tile.params 3
#1.1 Import user params
source /home/apchen1/project/module_setup/calibre/decksetup/TSMC/default_setup.tcl
source $required_params

# Get $db_dir(inputgds) | $db_dir(intputspi) | $db_dir(outputdb) | $db_dir(prefix) | $db_dir(temp_output)
# $db_dir(stage) here default is "topo p2p cd ldl" if TARGET_NAME is CbFPPERC, db_dir(stage) here is "p2p cd topo"
array set db_dir [data_func::get_dbdir $target_action $datatype(dfmdbtype)] 

# Check PERC statement, CbFPPERC default "p2p cd topo", CbFinalPERC default "p2p cd topo ldl"
# Each will be overwirte by pv_calibre(fpperc,run_types) or pv_calibre(finalperc,run_types)

if {$::env(TARGET_NAME) eq "CbFPPERC"} {
	if {[info exist pv_calibre(fpperc,run_types)] && $pv_calibre(fpperc,run_types) ne ""} {
		set db_dir(stage) $pv_calibre(fpperc,run_types)
	}
	puts "The perc run_types is $db_dir(stage)"
} elseif {$::env(TARGET_NAME) eq "CbFinalPERC"} {
	if {[info exist pv_calibre(finalperc,run_types)] && $pv_calibre(finalperc,run_types) ne ""} {
		set db_dir(stage) $pv_calibre(finalperc,run_types)
	}
	puts "The perc run_types is $db_dir(stage)"
}
##########################################################
#2>> Deal with rule deck
#2.1 Prepare header
# The sub_stage here is "topo p2p cd ldl"
foreach sub_stage $db_dir(stage) {
	set perc_workdir [file join $workdir $sub_stage]
	file mkdir $perc_workdir  
  # Backup old csh/tcl/log file if exist
	old_files::backup $perc_workdir old_files *.log *.csh *.log_detail
	set rule_header [file join $perc_workdir ${target_action}_$sub_stage.svrf]
	set rulefileheader [open $rule_header "w"]
	# Basic setup done, work for ruleheader generation
	# Write input datapath, but in topo run, maybe user want to use PERC NETLIST SOURCE configuration
	if {[info exist pv_calibre(perc,$sub_stage,source_type)] && $pv_calibre(perc,$sub_stage,source_type) eq 1 } {
		gen_deck_header::write_input_data_to_file $rulefileheader "" $::env(TOP_MODULE) $datatype(layouttype) $db_dir(inputspi) $::env(TOP_MODULE) "NA"
	} else {
		gen_deck_header::write_input_data_to_file $rulefileheader $db_dir(inputgds) $::env(TOP_MODULE) $datatype(layouttype) "" "" "NA"
	}	# Write check window situation 
	gen_deck_header::write_check_window_to_file $rulefileheader $flowtype 
	# Write report names to file 
	gen_deck_header::write_report_names_to_file $rulefileheader $perc_workdir PERC $sub_stage $sub_stage
	# Write exclude cell to file
	gen_deck_header::write_exclude_cell_to_file $rulefileheader $flowtype 
	# Write rule_switches to file 
	gen_deck_header::write_rule_switches_to_file $rulefileheader $flowtype 0 $sub_stage
	# Write rule_select to file 
	gen_deck_header::write_rule_select_to_file $rulefileheader $flowtype
	# Write virtual_connects to file
	gen_deck_header::write_virtual_connects_to_file $rulefileheader $flowtype
	# DFM DB part
	gen_deck_header::write_dfm_output_to_file $rulefileheader $flowtype
	# This line is always required for the rule deck, we need to override layout data in include files
	puts $rulefileheader "DRC ICSTATION YES"
	# Write user include file 
	set default_rule_deck /home/apchen1/project/module_setup/rule_deck/perc/main/modified/$pv_calibre(perc,version)/1P15M_1X1XB1XE1YA1YB5Y2YY2Z/perc_n05_1P15M_1X1Xb1Xe1Ya1Yb5Y2Yy2Z.top
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
	array set execopt [data_func::get_execopt $flowtype]
	# Added 20220818 for parallel run func, default by sequence.
	if {[info exist pv_calibre(perc,run_parallel)] && $pv_calibre(perc,run_parallel) == 1} {
		set parallel_opt "bsub -q syn -o ${log_file}_detail "
		if {$sub_stage eq [lindex $db_dir(stage) end]} {
			puts "PERC RUN IN PARALLEL mode, in this mode, the resource usage will be huge, plesae check resource is enough"
			set parallel_opt "bsub -Is -q syn -o ${log_file}_detail "
		}
	} else {
		set parallel_opt ""
	} 
	#4>> Write final run file
	set mapdict [dict create	layout_type $datatype(layouttype) design $db_dir(inputgds)			\
								work_dir $perc_workdir topcell $::env(TOP_MODULE) logfile $log_file	\
								timestamp $timestamp execoptstr $execopt(exec_opt_str)				\
								lsfremotestr $execopt(lsf_remote_str) ruleheader $rule_header		\
								extra_opt $parallel_opt												\
				] 	
	# Create mapdict for rule_temp::write_file to genarate final run cshfile
	set perc_temp	[file join /home/apchen1/project/module_setup/calibre/template/perc/ perc.csh.temp]
	rule_temp::write_file $perc_temp $cshfile $mapdict -permissions rwxr-xr-x
  
	#5>> Run target then generate drc results 
	set flowtype [string tolower $flowtype]
	if {$pv_calibre($flowtype,gen_header_only) ne 1} {
		exec $cshfile
	} else {
		puts "Genarate header file only"
	}
}
























