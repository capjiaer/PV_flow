#0>> Import packages for the furture usage
lappend auto_path "/home/apchen1/project/module_setup/calibre/module"
package require file_edit_func
package require data_func

#1>> Setup the params for calibre pv run, here target_name is CbFinalDummyMerge or CbFPDummyMerge
set target_action $::env(TARGET_NAME)
# Get $datatype(dfmdbtype) as oas or gds | Get $datatype(layouttype) as OASIS or GDSII
array set datatype [data_func::get_datatype]
# Get $db_dir(inputdb) | $db_dir(outputdb) | $db_dir(prefix) | $db_dir(temp_output)
array set db_dir [data_func::get_dbdir $target_action $datatype(dfmdbtype)] 
#Setup workdir, target_workdir is a dir we can get feol/beol db
set workdir [file join $::env(BASE_DIR) data $::env(TARGET_NAME)]
set target_workdir	[file join $::env(BASE_DIR) data $db_dir(prefix)]
set target_workdir	[file join $::env(BASE_DIR) data $db_dir(prefix)]
file mkdir $workdir

# Backup old csh/tcl/log file if exist
old_files::backup 1 old_files *.log *.tcl *.csh
# Setup env data for further usage
set required_params [file join $::env(BASE_DIR) data $target_action ${target_action}_parameter.tcl]
file_edit_func::get_para_data $required_params $::env(BASE_DIR)/tile.params 3

#1.1 Import params
source /home/apchen1/project/module_setup/calibre/decksetup/TSMC/default_setup.tcl
source $required_params
# Create Dummymerge_list.text for calibre
set Dummymerge_list [file join $workdir Dummymerge_list.text]

# Setup input from merged db. here is 
# > Ipmerged layout: $::env(TOP_MODULE).CbFinalIPMerge.merged.oas/$::env(TOP_MODULE).CbFPIPMerge.merged.oas
# > Dummy layout: ${db_dir(prefix)}FEOL.oas/$(db_dir(prefix))BEOL.oas
set feoldb [file join $target_workdir ${db_dir(prefix)}FEOL.$datatype(dfmdbtype)]
set beoldb [file join $target_workdir ${db_dir(prefix)}BEOL.$datatype(dfmdbtype)]

if {[file exist $feoldb]} {
	lappend dummydb $feoldb
	lappend cell_ref ${db_dir(prefix)}FEOL$::env(TOP_MODULE)
}
if {[file exist $beoldb]} {
	lappend dummydb $beoldb
	lappend cell_ref ${db_dir(prefix)}BEOL$::env(TOP_MODULE)
}

##########################################################################
# Setup merge list, if $feoldb/$beoldb exist in the data dir, the db will be added in Dummymerge_list
if {[info exist pv_calibre(dummy,extral_merge)] && $pv_calibre(dummy,extral_merge) ne ""} {
	file_edit_func::connect_elements $Dummymerge_list $pv_calibre(dummy,extral_merge) $dummydb
} else {
	file_edit_func::connect_elements $Dummymerge_list $dummydb
}

#2>> Generate final csh file for calibre run
# Create refcell for the top
set timestamp	[clock format [clock seconds] -format %Y_%m_%d_%H_%M_%S]
set tclshfile	[file join $workdir refcellcreate.$timestamp.tcl]
set mapdict		[dict create input_design $db_dir(inputdb) cell_ref $cell_ref  topcell $::env(TOP_MODULE) outputlayout $db_dir(temp_output)] 

set ref_temp	[file join /home/apchen1/project/module_setup/calibre/template/mfill/dummy_createref_cell.tcl.temp]
rule_temp::write_file $ref_temp $tclshfile $mapdict -permissions rwxr-xr-x
# Run tclshfile then $db_dir(temp_output) with refcells hierachy named $cell_ref or more rely on $db_dir(input_db) generated
exec calibredrv $tclshfile
##########################################################################

#3>> Setup merge mode for the dummy merge
if {[info exist pv_calibre(dummymerge,mode)] && $pv_calibre(dummymerge,mode) eq "rename"} {
	set merge_mode "\"rename -smartdiff\""
} else {
	set merge_mode "overwrite"
}
set timestamp	[clock format [clock seconds] -format %Y_%m_%d_%H_%M_%S]
set cshfile		[file join $workdir $target_action.$timestamp.csh]
set merged_file [file join $::env(BASE_DIR) data $::env(TOP_MODULE).$target_action.merged_mfill.$datatype(dfmdbtype)]
# Create mapdict for rule_temp::write_file to genarate final run cshfile
set mapdict [dict create input_design $db_dir(temp_output) Dummymerge_list $Dummymerge_list merged_file $merged_file merge_mode $merge_mode timestamp $timestamp work_dir $workdir topcell $::env(TOP_MODULE)] 

set merge_temp	[file join /home/apchen1/project/module_setup/calibre/template/mfill/ dummy_merge.csh.temp]
#4>> Write final run file
rule_temp::write_file $merge_temp $cshfile $mapdict -permissions rwxr-xr-x
#4.1 Run target 
exec $cshfile


