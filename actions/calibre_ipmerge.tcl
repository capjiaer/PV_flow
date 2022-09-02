#0>> Import packages for the furture usage
lappend auto_path "/home/apchen1/project/module_setup/calibre/module"
package require file_edit_func
package require data_func

#1>> Setup the params for calibre pv run
set target_action $::env(TARGET_NAME)
file mkdir $::env(BASE_DIR)/data/$target_action
set workdir [file join $::env(BASE_DIR) data $target_action]
# Backup old csh/tcl/log file if exist *.tcl/*.log/*.csh files
old_files::backup 1 old_files *.csh *.tcl *.log

# Setup env data for further usage
set required_params [file join $::env(BASE_DIR) data $target_action ${target_action}_parameter.tcl]
file_edit_func::get_para_data $required_params $::env(BASE_DIR)/tile.params 3
# Check layout system, get datatype(dfmdbtype) as gds/oas || datatype(layouttype) as GDSII/OASIS base on pv_calibre(layout_system)
array set datatype [data_func::get_datatype]

#1.1 Import params
source /home/apchen1/project/module_setup/calibre/decksetup/TSMC/default_setup.tcl
source $required_params

# Create IPmerge_list.text for ipmerge run
set IPmerge_list [file join $workdir IPmerge_list.text]

####################################################################################
# Setup std libs, check if users provided, if not, take default list as lib list
if {[info exist pv_calibre(ipmerge,addlibs)] && $pv_calibre(ipmerge,addlibs) ne ""} {
	#if syslist exist, merge it with stdlibs then generate it in IPmerge_list.text
	if {[info exist pv_calibre(ipmerge,syslist)] && $pv_calibre(ipmerge,syslist) ne ""} {
  		file_edit_func::connect_elements $IPmerge_list $pv_calibre(ipmerge,syslist) $pv_calibre(ipmerge,addlibs)  
	} else {
		file_edit_func::connect_elements $IPmerge_list $pv_calibre(ipmerge,addlibs)  
	} 
} else {
	if {[info exist pv_calibre(ipmerge,syslist)] && $pv_calibre(ipmerge,syslist) ne ""} {
		file_edit_func::connect_elements $IPmerge_list $pv_calibre(ipmerge,syslist)
	} else {
  		# set pv_calibre(ipmerge,syslist) as default liblist, which must be exist
		puts "pv_calibre(ipmerge,syslist) must exist, please set PV_CALIBRE_IPMERGE_syslist = \"your_list\" in your param"
		error "pv_calibre(ipmerge,syslist) must exist, please set PV_CALIBRE_IPMERGE_syslist = \"your_list\" in your param"
	} 
}
####################################################################################
#2>> Generate final csh file for calibre run
#2.1 Setup required path for the temp_file
# #Get $db_dir(inputdb) and $db_dir(outputdb)
array set db_dir [data_func::get_dbdir $target_action $datatype(dfmdbtype)] 
# User may declare the merge mode they want if needed, default "-mode overwrite"
if {[info exist pv_calibre(ipmerge,mode)] && $pv_calibre(ipmerge,mode) eq "rename"} {
	set merge_mode "\"rename -smartdiff\""
} elseif {[info exist pv_calibre(ipmerge,mode)] && $pv_calibre(ipmerge,mode) eq "overwrite"} {
	set merge_mode "overwrite"
} else {
	error "Only \"overwrite\" or \"rename\" mode is allowed for ipmerge target, default is \"overwrite\""
}
set timestamp	[clock format [clock seconds] -format %Y_%m_%d_%H_%M_%S]
set cshfile		[file join $::env(BASE_DIR) data $target_action $target_action.$timestamp.csh]
#set merged_file [file join $::env(BASE_DIR) data $::env(TOP_MODULE).$target_action.merged.$datatype(dfmdbtype)]
#2.2 Create mapdict for rule_temp::write_file to genarate final run cshfile
set mapdict [dict create input_design $db_dir(inputdb) IPmerge_list $IPmerge_list merged_file $db_dir(outputdb) merge_mode $merge_mode timestamp $timestamp work_dir $workdir topcell $::env(TOP_MODULE)] 
set merge_temp	[file join /home/apchen1/project/module_setup/calibre/template merge_libs.csh.temp]
#3>> Write final run file
rule_temp::write_file $merge_temp $cshfile $mapdict -permissions rwxr-xr-x
#3.1 Run target 
exec $cshfile
