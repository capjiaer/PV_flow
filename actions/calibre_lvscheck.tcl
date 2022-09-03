#0>> Import packages for the furture usage
lappend auto_path "PV_flow/module_setup/calibre/module"
package require file_edit_func 
package require gen_deck_header
package require data_func

#1>> Setup the params for calibre pv run
# The target action here is CbFPPGLVS CbFinalLVS
set target_action $::env(TARGET_NAME)
set flowtype "LVS"
# Check layout system, get datatype(dfmdbtype) as gds/oas || datatype(layouttype) as GDSII/OASIS base on pv_calibre(layout_system)
array set datatype [data_func::get_datatype]
# Setup dir for further usage
file mkdir $::env(BASE_DIR)/data/$target_action
set workdir [file join $::env(BASE_DIR) data $target_action]

# Backup old csh/tcl/log file if exist
old_files::backup 1 old_files *.log *.csh
# Setup env data for further usage
set required_params [file join $::env(BASE_DIR) data $target_action ${target_action}_parameter.tcl]
file_edit_func::get_para_data $required_params $::env(BASE_DIR)/tile.params 3

#1.1 Import user params
source /home/apchen1/project/module_setup/calibre/decksetup/TSMC/default_setup.tcl
source $required_params

# Update 0815 setup db_dir
# Get $db_dir(inputdb) | $db_dir(outputdb) | $db_dir(prefix) | $db_dir(temp_output) | $db_dir(stage) | $db_dir(inputverilog)
array set db_dir [data_func::get_dbdir $target_action $datatype(dfmdbtype)] 
#1.2 Setup for pure extraction and skip v2lvs, and skip comparison if Target is CbFPPGShort 
if {$::env(TARGET_NAME) eq "CbFPPGShort"} {
	# Reset pv_calibre(lvs,skip_v2lvs) here
	set pv_calibre(lvs,skip_v2lvs) ""
	#1.2.1 Skip v2lvs, extraction required only
	# For CbFPPGShort, the input layout is pv_calibre(lvs,fppgshort,inputdb) or CbFPIPMerge.merged_mfill.oas
	# Update 0815, v2lvs is also required for topo check, source base for the spice netlist
	# pv_calibre(lvs,skip_v2lvs) shall not be default as 1
	if {[info exist pv_calibre(fppgshort,skip_v2lvs)] && $pv_calibre(fppgshort,skip_v2lvs) == 1} {
		set pv_calibre(lvs,skip_v2lvs) "1"
		puts "v2lvs skipped in CbFPPGShort target, spice extraction required"
	} 

	set pv_calibre(lvs,skip_comparison) 1

	# ERC CHECK is no more required, 20220810 updated
	set pv_calibre(lvs,execute_erc) 0
}

##########################################################
# Step1 > v2lvs get spice files

# Check db statues, if db is verilog, then do v2lvs, else, skip v2lvs
# db_dir is $pv_calibre(lvs.input_verilog), if not exist, set it as ReRoute.v.gz
# Just CbFinalLVS need this function for v2lvs
if {$target_action eq "CbFinalLVS"} {
	if {[file exist $db_dir(inputverilog)]} {
		set verilog_netlist [file normalize $db_dir(inputverilog)]
		if {![regexp -nocase {^.*\.v(\.gz)?$}  $verilog_netlist]} {
			puts "The netlist is not a verilog netlist, set it as spice netlist"
			puts "Skip v2lvs"
			set pv_calibre(lvs,skip_v2lvs) "1"
			set pv_calibre(lvs,spice_netlist) $db_dir(inputverilog)
		} 
	} else {
		puts "Error: Verilog file do not exist, please check with your database or pv_calibre(lvs,inputverilog) for more infomation"
		error "Check Verilog files then do debug"
	}
} 

#2>> Start v2lvs if required
set v2lvsworkdir [file join $workdir v2lvs]
if {[info exists pv_calibre(lvs,skip_v2lvs)] == 0 || $pv_calibre(lvs,skip_v2lvs) ne 1} {
	# Setup v2lvs workdir for further usage
	file mkdir $::env(BASE_DIR)/data/$target_action/v2lvs

	# Setup empty_subcket_file if info exist
	# The verilog netlist usually doesn't contain below infomation, so they must be separately added

	
	# >1 user-defined subcircuit definitions
	if {[info exist pv_calibre(lvs,empty_subcket_file)] && $pv_calibre(lvs,empty_subcket_file) ne ""} {
		lappend spice_files $pv_calibre(lvs,empty_subcket_file)  
	}
	# >2 lib reference 
	if {[info exist pv_calibre(lvs,addlibs)] && $pv_calibre(lvs,addlibs) ne ""} {
		lappend spice_files $pv_calibre(lvs,addlibs)  
	}
	# >3 user reference 
	if {[info exist pv_calibre(lvs,spice_files)] && $pv_calibre(lvs,spice_files) ne ""} {
		lappend spice_files $pv_calibre(lvs,addlibs)  
	}
	# Create add all list info into a spice netlist
	foreach spice_list $spice_files {
		lappend netlist_merged [file_edit_func::connect_elements 0 $spice_list] 
	}

	# Includespice create as .INCLUDE spice_files
	set include_spice [file join $v2lvsworkdir std_spice.list]
	set include_spicefh [open $include_spice w]
	foreach spice_ele [join $netlist_merged] {
		if {[regexp {^\.INCLUDE} [string toupper $spice_ele]]} {
			puts $include_spicefh "$spice_ele"
		} else {
			puts $include_spicefh ".INCLUDE $spice_ele"
		}
	}
	close $include_spicefh

	# Run with any Verilog/Spice lib files for parsing if specified
	set verilog_libstr ""
	if {[info exist pv_calibre(lvs,v2lvs,verilog_lib_file)] && $pv_calibre(lvs,v2lvs,verilog_lib_file) ne ""} {
		set verilog_libstr "-l $pv_calibre(lvs,v2lvs,verilog_lib_file)"
	} 
	set spice_libpinstr ""
	if {[info exist pv_calibre(lvs,v2lvs,spice_lib_file_pinmode)] && $pv_calibre(lvs,v2lvs,spice_lib_file_pinmode) ne ""} {
		set spice_libpinstr "-lsp $pv_calibre(lvs,v2lvs,spice_lib_file_pinmode)"
	} 
	set spice_librangestr ""
	if {[info exist pv_calibre(lvs,v2lvs,spice_lib_file_rangemode)] && $pv_calibre(lvs,v2lvs,spice_lib_file_rangemode) ne ""} {
		set spice_librangestr "-lsr $pv_calibre(lvs,v2lvs,spice_lib_file_rangemode)"
	} 

	###########################################################
	# Backup old csh/tcl/log file if exist
	old_files::backup $v2lvsworkdir old_files *.log *.csh
	#3>> Write final run file for v2lvs
	set timestamp			[clock format [clock seconds] -format %Y_%m_%d_%H_%M_%S]
	set cshfile				[file join $v2lvsworkdir v2lvs.$timestamp.csh]
	set outcdl				[file join $v2lvsworkdir $target_action.cdl]
	set mapdict [dict create	work_dir $v2lvsworkdir					\
								timestamp $timestamp					\
								lvs_verilog $db_dir(inputverilog)		\
								include_spice $include_spice			\
								verilog_libstr $verilog_libstr			\
								spice_libpinstr $spice_libpinstr		\
								spice_librangestr $spice_librangestr	\
								outcdl $outcdl							\
				]
	# Create mapdict for rule_temp::write_file to genarate final run cshfile
	set v2lvs_temp	[file normalize [file join ./PV_flow/template/lvs v2lvs.csh.temp]]
	rule_temp::write_file $v2lvs_temp $cshfile $mapdict -permissions rwxr-xr-x
	# Take $outcdl as lvs_netlist
	set lvs_netlist $outcdl
	#4>> Run target then generate v2lvs result
	exec $cshfile
  #5>> 0815, if just V2LVS required, then exit here
	if {[info exist pv_calibre(lvs,v2lvs_only)] && $pv_calibre(lvs,v2lvs_only) == 1} {
		puts "pv_calibre(lvs,v2lvs_only) option setup as 1, flow exit after v2lvs, skiped extraction and comparison"
		exit
	}
} else {
	# Skip v2lvs step, check lvs spice_netlist for lvs run 
	if {[info exist pv_calibre(lvs,spice_netlist)] && $pv_calibre(lvs,spice_netlist) ne ""} {
		set lvs_netlist $pv_calibre(lvs,spice_netlist)
		puts "Skip v2lvs"
		puts "Extraction skipped, take $pv_calibre(lvs,spice_netlist) as source netlist"
		puts "this run just for comparison"
	} else {
  	# pv_calibre(lvs,spice_netlist)] doesn't exist
		if {[info exist pv_calibre(lvs,skip_comparison)] && $pv_calibre(lvs,skip_comparison) eq "1"} {
			# For FPPGShort, here is no source netlist required, set it as empty
			puts "Skip v2lvs"
			puts "Skip comparison, this run just for extraction"
			set lvs_netlist ""
		} else {
    	# If skip v2lvs && NOT skip_comparison && spice_netlist doesn't exist 
			# Take v2lvs cdl as input source netlist
			puts "Skip v2lvs, but still take [file join $v2lvsworkdir $target_action.cdl] as source netlist"
			puts "Extraction required"
			set lvs_netlist [file join $v2lvsworkdir $target_action.cdl]
		}
	}  

}
##########################################################
##########################################################
# Step2 > lvs run start
# Now the input netlist for lvs shall be $lvs_netlist

#5>> Check base info must exist
#5.1 Check hcell file must exist
if {[info exist pv_calibre(lvs,hcell_list)] && $pv_calibre(lvs,hcell_list) ne "" && [file exists $pv_calibre(lvs,hcell_list)]} {
	set hcell_file [file normalize $pv_calibre(lvs,hcell_list)]
} else {
	puts "Error, pv_calibre(lvs,hcell_list) must exist, please check with your params list"
	error "Error out, please check pv_calibre(lvs,hcell_list)"
}
###########################################################
#6>> Start LVS rule file setup
#6.1 Prepare header
set rule_header [file join $::env(BASE_DIR) data $target_action $target_action.svrf]
set rulefileheader [open $rule_header "w"]
# Basic setup done, work for ruleheader generation
# Write input datapath 
gen_deck_header::write_input_data_to_file $rulefileheader $db_dir(inputdb) $::env(TOP_MODULE) $datatype(layouttype) $lvs_netlist $::env(TOP_MODULE) $pv_calibre(precision)
# Write check window situation 
gen_deck_header::write_check_window_to_file $rulefileheader $flowtype 
# Write report names to file, lvs get a var $exec_optstr here
gen_deck_header::write_report_names_to_file $rulefileheader $workdir $flowtype 
# Write exclude cell to file
gen_deck_header::write_exclude_cell_to_file $rulefileheader $flowtype 
# Write rule_switches to file 
gen_deck_header::write_rule_switches_to_file $rulefileheader $flowtype 0
# Write virtual_connects to file
gen_deck_header::write_virtual_connects_to_file $rulefileheader $flowtype
# Write rule select to file
gen_deck_header::write_rule_select_to_file $rulefileheader $flowtype
# DFM DB part
gen_deck_header::write_dfm_output_to_file $rulefileheader $flowtype
# This line is always required for the rule deck, we need to override layout data in include files
puts $rulefileheader "DRC ICSTATION YES"
# Write user include file 
set default_rule_deck path/to/lvs/deck
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
# Waive flow update 20220809
set execopt(exec_opt_str) [append execopt(exec_opt_str) " " [gen_deck_header::get_waive_str $workdir $flowtype "erc"]]
#4>> Write final run file
set mapdict [dict create	layout_type $datatype(layouttype) design $db_dir(inputdb)		\
							work_dir $workdir topcell $::env(TOP_MODULE) logfile $log_file	\
							timestamp $timestamp execoptstr $lvs_exec_optstr				\
							lsfremotestr $execopt(lsf_remote_str) ruleheader $rule_header	\
			] 
# Create mapdict for rule_temp::write_file to genarate final run cshfile
set lvs_temp	[file normalize [file join ./PV_flow/template/lvs lvs.csh.temp]]
rule_temp::write_file $lvs_temp $cshfile $mapdict -permissions rwxr-xr-x
#5>> Run target then generate drc results 
set flowtype [string tolower $flowtype]
if {$pv_calibre($flowtype,gen_header_only) ne 1} {
	exec $cshfile
} else {
	puts "Genarate header file only"
}
