# Register the package
package provide gen_deck_header 1.0

# This package help to gen rule header, create the header for the svrf rules

# Create namespace
namespace eval ::gen_deck_header {
	namespace export write_input_data_to_file write_check_window_to_file write_exclude_cell_to_file write_rule_switches_to_file write_user_include_to_file write_virtual_connects_to_file write_report_names_to_file write_rule_select_to_file get_waive_str
}
#############################################################################################################################
# Description: this proc help to genarate calibre deck header for rule deck info
# Arguments:	file_handler	-the input file user declare to write in
#				layoutpath		-the input layout for the calibre PV run
#				primname		-the topcell name for the input layout
#				layouttype		-specification for GDSII OR OASIS
#				precision		-default 2000, but after merge, it turns out to be 20000
#				schematic_path	-the schematic path if required
#				schematic_name	-the topcell for the input schematic
#				layoutpath2		-the 2nd layout if required, for LVL or ECO
#				primname2		-the 2nd topcell name for the input layout
#				layouttype2		-specification for GDSII OR OASIS for LAYOUT 2
# Example: gen_deck_header::write_input_data_to_file ./header.svrf ./top.gds top_cell GDSII
#############################################################################################################################
proc ::gen_deck_header::write_input_data_to_file {file_handler layoutpath primname layouttype {schematic_path ""} {schematic_name ""} {precision 2000} {layoutpath2 ""} {primname2 ""} {layouttype2 ""} } {
	global pv_calibre
	puts $file_handler "//Input data specifications"
	if {$layoutpath ne ""} {
		puts $file_handler "LAYOUT SYSTEM [string toupper $layouttype]"
		puts $file_handler "LAYOUT PATH \"$layoutpath\""
		puts $file_handler "LAYOUT PRIMARY \"$primname\" \n"
	} 
	if {$schematic_path ne ""} {
		puts $file_handler "SOURCE SYSTEM SPICE"
		puts $file_handler "SOURCE PATH \"$schematic_path\""
		puts $file_handler "SOURCE PRIMARY \"$schematic_name\" \n"
	}	
	if {$layoutpath2 ne ""} {
		puts $file_handler "LAYOUT SYSTEM2 [string toupper $layouttype2]"
		puts $file_handler "LAYOUT PATH2 \"$layoutpath2\""
		puts $file_handler "LAYOUT PRIMARY2 \"$primname2\" \n"
	}
	if {$layoutpath eq "" && $schematic_path eq ""} {
		puts "Error: A layout file required or schematic file required"
		error "A layout file required or schematic file required"
		exit
	}
	# Add precision statement 20220810
	if { $precision ne "NA" } {
		puts $file_handler "LAYOUT PRECISION $precision"
		puts $file_handler "PRECISION 20000"
		puts $file_handler "LAYOUT MAGNIFY AUTO"
	}

	# Add input error statement 20220810
	if {[info exist pv_calibre(layoutinput_errorout)] && $pv_calibre(layoutinput_errorout) == 0} {
		puts $file_handler "LAYOUT ERROR ON INPUT NO"
	}

	puts $file_handler ""
}

#############################################################################################################################
# Description: this proc help to genarate calibre deck header for check window info
# Arguments:	file_handler	-the input file user declare to write in
#				flowtype		-the flow type for different run, such as DRC/LVS/PERC/DFM/DUMMY etc.
# Example: gen_deck_header::write_check_window_to_file ./header.svrf
#############################################################################################################################
proc ::gen_deck_header::write_check_window_to_file {file_handler flowtype {check_window ""} {exclude_window ""}} {
	global pv_calibre
	set flowtype [string tolower $flowtype]
	# Get the params from $pv_calibre if exist, then replace the vars, then declare statues
	if {[info exists pv_calibre($flowtype,check_window)] && $pv_calibre($flowtype,check_window) ne ""} {
		puts $file_handler "//Check window specification"
		puts $file_handler "LAYOUT WINDOW $pv_calibre(check_window)\n"
		puts $file_handler ""
	}
	if {[info exists pv_calibre($flowtype,exclude_window)] && $pv_calibre($flowtype,exclude_window) ne "" } {
		puts $file_handler "//Exclude window specification"
		puts $file_handler "LAYOUT WINDEL $pv_calibre(exclude_window)\n"
		puts $file_handler ""
	}
}

#############################################################################################################################
# Description: this proc help to genarate calibre deck header for check window info
# Arguments:	file_handler	-the input file user declare to write in
#				flowtype		-the flow type for different run, such as DRC/LVS/PERC/DFM/DUMMY etc.
#				args			-the other file declare exclude cell if needed
# Example: gen_deck_header::write_exclude_cell_to_file ./header.svrf
#############################################################################################################################
proc ::gen_deck_header::write_exclude_cell_to_file {file_handler flowtype args} {
	global pv_calibre
	set flowtype [string tolower $flowtype]
	if {[info exists pv_calibre($flowtype,exclude_cell_file)] && $pv_calibre($flowtype,exclude_cell_file) ne ""} {
		puts $file_handler "// Exclude the following cells"
		set cell_list [file_edit_func::connect_libs 0 $pv_calibre($flowtype,exclude_cell_file) $args]
		foreach {cellname} $cell_list {
			puts $file_handler "EXCLUDE CELL \"$cellname\""
		}
		puts $file_handler ""
	}
}

#############################################################################################################################
# Description: this proc help to genarate calibre deck header for dummy db genarate info
# Arguments:	file_handler	-the input file user declare to write in
#				flowtype		-the flow type for different run, such as DRC/LVS/PERC/DFM etc.
#				args			-the other file declare exclude cell if needed
# Example: gen_deck_header::write_dfm_output_to_file ./header.svrf
#############################################################################################################################
proc ::gen_deck_header::write_dfm_output_to_file {file_handler flowtype args} {
	global pv_calibre
	if {[info exist pv_calibre($flowtype,dfmdb)] && $pv_calibre($flowtype,dfmdb) ne ""} {
		if {[lsearch [list "GDS" "GDSII"] [string toupper $pv_calibre($flowtype,dfmdb)]] != -1} {
			puts $file_handler "DFM DEFAULTS RDB GDS FILE \"$::env(TARGET_NAME).gds\" PREFIX $::env(TARGET_NAME)"
		} elseif {[lsearch [list "OAS" "OASIS"] [string toupper $pv_calibre($flowtype,dfmdb)]] != -1} {
			puts $file_handler "DFM DEFAULTS RDB OASIS FILE \"$::env(TARGET_NAME).oas\" PREFIX $::env(TARGET_NAME)"
		}
		puts $file_handler ""
	}
}

#############################################################################################################################
# Description: this proc help to genarate calibre deck header for rule switch info
# Arguments:	file_handler	-the input file user declare to write in
#				flowtype		-the flow type for different run, such as DRC/LVS/PERC/DFM/DUMMY etc.
#				skip_upper		-decide if get the info from upper hierarchy, default 0 means yes
#				typename		-feol/beol for dummy, which are individual runs and these may need individual rules or settings.
#				args			-the other file declare exclude cell if needed
# Example: gen_deck_header::write_rule_switches_to_file ./header.svrf
#
# Appendix:
# Get info from	>> pv_calibre($flowtype,default,$swtype_ele,$status) 
#				>> pv_calibre($flowtype,$typename,default,$swtype_ele,$status)
#				>> pv_calibre($flowtype,user,$swtype_ele,$status) 
#				>> pv_calibre($flowtype,$typename,user,$swtype_ele,$status)
#
#############################################################################################################################

proc ::gen_deck_header::write_rule_switches_to_file {file_handler flowtype {skip_upper 0} {typename ""} args} {
	global pv_calibre
	set flowtype [string tolower $flowtype]
	puts $file_handler "// Setup rule switches for the rule deck"
	set swtypes [list "booleanswitches" "nonbooleanswitches" "stringvariables" "nonstringvariables"]
	# Get info from full_chip_opt file option
	if {[info exists pv_calibre(full_chip)] && $pv_calibre(full_chip) == 1} {
  		set status "full_chip"
		puts $file_handler "// The option settings for FULL_CHIP, please check if you are top owner"
	} else {
		set status "block_level"
		puts $file_handler "// The option settings for BLOCK_LEVEL, please check if you are block owner, use  \"PV_CALIBRE_full_chip = 1\" to switch to top owner "
		}
	foreach {swtype_ele} $swtypes {

		# Get info from pv_calibre($flowtype,default,$swtype_ele,$status), which is a list for the further usage 
		if {$skip_upper == 0} {
			array set swdata $pv_calibre($flowtype,default,$swtype_ele,$status)
			array set swdata_default $pv_calibre($flowtype,default,$swtype_ele,$status)
		}
		# Get info from pv_calibre($flowtype,$typename,default,$swtype_ele,full_chip), which is a list for typename if required 
		if {$typename ne "" && [info exist pv_calibre($flowtype,$typename,default,$swtype_ele,$status)]} {
			array set swdata $pv_calibre($flowtype,$typename,default,$swtype_ele,$status) 
			array set swdata_default $pv_calibre($flowtype,$typename,default,$swtype_ele,$status) 
		} 
		# Get info from user part
		if {[info exist pv_calibre($flowtype,user,$swtype_ele,$status)]} {
			array set swdata $pv_calibre($flowtype,user,$swtype_ele,$status) 
		} 
		# Get info from user part if typename exist
		if {$typename ne "" && [info exist pv_calibre($flowtype,$typename,user,$swtype_ele,$status)]} {
			array set swdata $pv_calibre($flowtype,$typename,user,$swtype_ele,$status) 
		} 
		# Array setup done for each swtype_ele, setup different status for each swtype_ele
		
		switch -exact $swtype_ele { 
			booleanswitches { 
				# Write out or not all define keyword for booleanswitches
				if {[array size swdata] != 0} {
					puts $file_handler "// From booleanswitches"
				}
				foreach swdata_ele [lsort -dictionary [array names swdata]] {
					#If both exist 
					if {[lsearch [array names swdata_default] $swdata_ele] >= 0} {
						#If different, then mark it as user defined 
						if {$swdata_default($swdata_ele) ne $swdata($swdata_ele)} {
							puts $file_handler "//#DEFINE $swdata_ele  //USER DEFINED"
						} elseif {$swdata_default($swdata_ele) == 1} {
							puts $file_handler "#DEFINE $swdata_ele"
						}
						#If extral and set as 1, then mark it as user defined 
					} elseif {$swdata($swdata_ele) == 1} {
						puts $file_handler "#DEFINE $swdata_ele  //USER DEFINED"
					} elseif {$swdata($swdata_ele) == 0} {
						#If extral and set as 0, then mark it as user defined but comment it
						puts $file_handler "//#DEFINE $swdata_ele  //USER DEFINED"
					}
				}
			}
			nonbooleanswitches {
				# Nonbooleanswitches always been writeout with given value for nonbooleanswitches
				if {[array size swdata] != 0} {
					puts $file_handler "// From nonbooleanswitches"
				}
				foreach swdata_ele [lsort -dictionary [array names swdata]] {
					#If both exist 
					if {[lsearch [array names swdata_default] $swdata_ele] >= 0} {
						#If different, then mark it as user defined 
						if {$swdata_default($swdata_ele) ne $swdata($swdata_ele)} {
							puts $file_handler "#DEFINE $swdata_ele $swdata($swdata_ele) //USER DEFINED"
						} else {
							puts $file_handler "#DEFINE $swdata_ele $swdata($swdata_ele)"
						}
						#If extral, then mark it as user defined 
					} else {
						puts $file_handler "#DEFINE $swdata_ele $swdata($swdata_ele) //USER DEFINED"
					}
				}
		
			}
			stringvariables {
				# Stringvariables shall be in double quotes for stringvariables
				if {[array size swdata] != 0} {
					puts $file_handler "// From stringvariables"
				}

				foreach swdata_ele [lsort -dictionary [array names swdata]] {
					#If both exist 
					if {[lsearch [array names swdata_default] $swdata_ele] >= 0} {
						#If different, then mark it as user defined 
						if {$swdata_default($swdata_ele) ne $swdata($swdata_ele)} {
							puts $file_handler "VARIABLE $swdata_ele [regsub -all {\S+} $swdata($swdata_ele) \"&\"] //USER DEFINED"
						} else {
							puts $file_handler "VARIABLE $swdata_ele [regsub -all {\S+} $swdata($swdata_ele) \"&\"]"
						}
						#If extral, then mark it as user defined 
					} else {
						puts $file_handler "VARIABLE $swdata_ele [regsub -all {\S+} $swdata($swdata_ele) \"&\"] //USER DEFINED"
					}
				}
			}

			nonstringvariables {
				# Nonstringvariables write out as-is for nonstringvariables
				if {[array size swdata] != 0} {
					puts $file_handler "// From nonstringvariables"
				}
				foreach swdata_ele [lsort -dictionary [array names swdata]] {
					#If both exist 
					if {[lsearch [array names swdata_default] $swdata_ele] >= 0} {
						#If different, then mark it as user defined 
						if {$swdata_default($swdata_ele) ne $swdata($swdata_ele)} {
							# Setup a temp here incase need to switch & as \"&\"
							#puts $file_handler "VARIABLE $swdata_ele [regsub -all {\S+} $swdata($swdata_ele) \"&\"] //USER DEFINED"
							puts $file_handler "VARIABLE $swdata_ele [regsub -all {\S+} $swdata($swdata_ele) &] //USER DEFINED"
						} else {
							puts $file_handler "VARIABLE $swdata_ele [regsub -all {\S+} $swdata($swdata_ele) &]"
						}
						#If extral, then mark it as user defined 
					} else {
						puts $file_handler "VARIABLE $swdata_ele [regsub -all {\S+} $swdata($swdata_ele) &] //USER DEFINED"
					}
				}
			}
			default {
				error "Incorrect data types specified, check $swtype_ele for more details, it can be only for \"booleanswitches nonbooleanswitches stringvariables nonstringvariables\""	
			}
		}
		array unset swdata
	}
	puts $file_handler "// Rule switches setup done for the rule deck"
	puts $file_handler ""
}

#############################################################################################################################
# Description: this proc help to genarate calibre deck header for rule switch info
# Arguments:	file_handler	-the input file user declare to write in
#				flowtype		-drc/lvs/perc/dfm/ant/erc/dummy etc included
#				typename        -feol/beol 
#				args			-foundary rules
# Example: gen_deck_header::write_user_include_to_file ./header.svrf dummy feol ./golden_feol.svrf
#############################################################################################################################
proc ::gen_deck_header::write_user_include_to_file {file_handler flowtype {typename ""} args} {
	global pv_calibre
	puts $file_handler "// Include following files"
	set flowtype [string tolower $flowtype]
	# Include user specified file first
	if {$typename ne ""} {
		if {[info exists pv_calibre($flowtype,$typename,user_include_file)] && $pv_calibre($flowtype,$typename,user_include_file) ne ""} {
				puts $file_handler "INCLUDE $pv_calibre($flowtype,$typename,user_include_file)"
		} 
	}  
	
	if {[info exists pv_calibre($flowtype,user_include_file)] && $pv_calibre($flowtype,user_include_file) ne ""} {
		puts $file_handler "INCLUDE $pv_calibre($flowtype,user_include_file)"
	}
	if {[info exists pv_calibre($flowtype,pad_text_file)] && $pv_calibre($flowtype,pad_text_file) ne ""} {
		puts $file_handler "INCLUDE $pv_calibre($flowtype,pad_text_file)"
	}

	if {[info exists pv_calibre(user_include_file)] && $pv_calibre(user_include_file) ne ""} {
		puts $file_handler "INCLUDE $pv_calibre(user_include_file)"
	}
	# If foundry or other files required
	if {$args ne ""} { 
		puts $file_handler "// Other incldue files"
		foreach elements $args {
			puts $file_handler "INCLUDE $args"
		}
	}
	puts $file_handler ""
}

#############################################################################################################################
# Description: this proc help to genarate calibre deck header for rule select info
# Arguments:	file_handler	-the input file user declare to write in
#				flowtype		-the flow type for different run, such as DRC/LVS/PERC/DFM/DUMMY/ANT/BUMP etc.
#				args			-setup just incase required
# Example: gen_deck_header::write_rule_select_to_file ./header.svrf drc
#############################################################################################################################
proc ::gen_deck_header::write_rule_select_to_file {file_handler flowtype args} {
	global pv_calibre
	set flowtype [string tolower $flowtype]
	if {[info exist pv_calibre($flowtype,rule_select)] && $pv_calibre($flowtype,rule_select) ne "" || [info exist pv_calibre($flowtype,rule_unselect)] && $pv_calibre($flowtype,rule_unselect) ne ""} {
		puts $file_handler "// Rule selection setup"

		set user_group_select_rules ""
		set user_select_rules ""
		set user_group_unselect_rules ""
		set user_unselect_rules ""

		# Setup select_rules for group rules
		set group_count 0
		if {[info exist pv_calibre($flowtype,rule_select)] && $pv_calibre($flowtype,rule_select) ne ""} {
			foreach ele $pv_calibre($flowtype,rule_select) {
				set group_count [expr $group_count + 1]
				if {[regexp {\*|\?} $ele]} {
					lappend user_group_select_rules user_group_select$group_count
					puts $file_handler "GROUP user_group_select$group_count $ele"
				} else {
					lappend user_select_rules $ele
				}
			}
		}

		# Setup unselect_rules for group rules
		set group_count 0
		if {[info exist pv_calibre($flowtype,rule_unselect)] && $pv_calibre($flowtype,rule_unselect) ne ""} {
			foreach ele $pv_calibre($flowtype,rule_unselect) {
				set group_count [expr $group_count + 1]
				if {[regexp {\*|\?} $ele]} {
					lappend user_group_unselect_rules user_group_unselect$group_count
					puts $file_handler "GROUP user_group_unselect$group_count $ele"
				} else {
					lappend user_unselect_rules $ele
				}
			}
		}
		if {[info exist pv_calibre($flowtype,rule_select)] && $pv_calibre($flowtype,rule_select) ne ""} { 
			if {$user_group_select_rules ne ""} {
				puts $file_handler "DRC SELECT CHECK $user_group_select_rules"
			}
			# Setup select_rule for select check
			if {$user_select_rules ne ""} {
				puts $file_handler "DRC SELECT CHECK $user_select_rules "
			}
		}

		if {[info exist pv_calibre($flowtype,rule_unselect)] && $pv_calibre($flowtype,rule_unselect) ne ""} {
			if {$user_group_unselect_rules ne ""} {
				puts $file_handler "DRC UNSELECT CHECK $user_group_select_rules"
			}
			# Setup select_rule for select check
			if {$user_select_rules ne ""} {
				puts $file_handler "DRC UNSELECT CHECK $user_select_rules "
			}
		}
	}
	if {[info exist pv_calibre($flowtype,rule_select_bylayer)] && $pv_calibre($flowtype,rule_select_bylayer) ne ""} {
		puts $file_handler "// Rule selection by layer setup"
		puts $file_handler "DRC SELECT CHECK BY LAYER $pv_calibre($flowtype,rule_select_bylayer)"
	}
	if {[info exist pv_calibre($flowtype,rule_unselect_bylayer)] && $pv_calibre($flowtype,rule_unselect_bylayer) ne ""} {
		puts $file_handler "// Rule selection by layer setup"
		puts $file_handler "DRC UNSELECT CHECK BY LAYER $pv_calibre($flowtype,rule_unselect_bylayer)"
	}

	puts $file_handler ""
}

#############################################################################################################################
# Description: this proc help to genarate calibre deck header for virtual connect info
# Arguments:	file_handler	-the input file user declare to write in
#				flowtype		-the flow type for different run, such as DRC/LVS/PERC/DFM/DUMMY etc.
#				args			-the other file declare virtual connect if needed
# Example: gen_deck_header::write_virtual_connects_to_file ./header.svrf
#############################################################################################################################
proc ::gen_deck_header::write_virtual_connects_to_file {file_handler flowtype args} {
	global pv_calibre
	set flowtype [string tolower $flowtype]
	# virtual connections shall NOT be applied in  full chip
	if {[info exist pv_calibre(full_chip)] && $pv_calibre(full_chip) ne "1"} {
		# Full chip level shall NOT use virtual_connect
		if {[info exist pv_calibre(vconnect,nets,net_names)] && $pv_calibre(vconnect,nets,net_names) ne ""} {
			set virtual_connect_nets $pv_calibre(vconnect,nets,net_names)
			set virtual_connect_name_str "VIRTUAL CONNECT NAME $virtual_connect_nets"	
			if {[info exist pv_calibre(vconnect,cells,cell_names)] && $pv_calibre(vconnect,cells,cell_names) ne ""} {
				set virtual_connect_cells $pv_calibre(vconnect,cells,cell_names) 
			}
			if {$virtual_connect_cells ne ""} {
				set virtual_connect_name_str "VIRTUAL CONNECT NAME $virtual_connect_nets cell $virtual_connect_cells"	
			}

		}
		# The other related connect statements
		if {$virtual_connect_nets ne "" || $pv_calibre($flowtype,virtual_connect_depth_all)} {
			puts $file_handler "// Virtual connect specifications"
			puts $file_handler "VIRTUAL CONNECT COLON YES"
			if {[info exists pv_calibre($flowtype,virtual_connect_depth_all)] && $pv_calibre($flowtype,virtual_connect_depth_all) == 1} {
				puts $file_handler "VIRTUAL CONNECT DEPTH ALL"
			}
			puts $file_handler $virtual_connect_name_str
			puts $file_handler ""
		}	
	} else {
		puts $file_handler "VIRTUAL CONNECT COLON NO"
	}
}


#############################################################################################################################
# Description: this proc help to genarate waiver options for calibre waive flow
# Arguments:	workdir			-The rpt/db file dir for further usage
#				flowtype		-The flow type for different run, such as DRC/LVS/BUMP/ANT etc.
#				typename		-ERC for LVS
#
# Returns: Strings for all options for DRC run results
# Example: gen_deck_header::write_report_names_to_file $workdir DRC
#############################################################################################################################

proc ::gen_deck_header::get_waive_str {workdir flowtype {typename ""}} {
	global pv_calibre db_dir
	set flowtype [string tolower $flowtype]
	set typename [string tolower $typename]
	# Check if waived_gds_list exist or not
	if {$typename ne "" && [info exist pv_calibre($flowtype,$typename,waived_gds_list)] && [file exist $pv_calibre($flowtype,$typename,waived_gds_list)]} {
		set list_file $pv_calibre($flowtype,$typename,waived_gds_list)
		set flow_typename "$flowtype.$typename"
	} elseif {[info exist pv_calibre($flowtype,waived_gds_list)] && [file exist $pv_calibre($flowtype,waived_gds_list)]} {
		set list_file $pv_calibre($flowtype,waived_gds_list)
		set flow_typename "$flowtype"
	} else {
		set list_file ""
	}
	# Setup waive file
	set waiverstr ""
	if {$list_file ne ""} {
		set waiver_setup [file join $workdir $::env(TOP_MODULE).$flow_typename.waiver.setup]
		set waiver_fileheader [open $waiver_setup w]
		puts $waiver_fileheader "WAIVER_CRITERIA EXTRACT [file join $workdir $::env(TOP_MODULE).$flow_typename.waiver.criteria]"
		puts $waiver_fileheader "INPUT_LIBRARY $db_dir(inputdb)" 
		# Get waive gds list
		set fh [open $list_file r]
		set gds_list [split [string trim [read $fh]]]
		close $fh

		foreach ele $gds_list {
			if {[regexp {^\s*#} $ele] == 0 && $ele ne ""} {
				puts $waiver_fileheader "WAIVER_DATABASE $ele"
			}
		}	
		# GDS INFO setup done, other basic setups
		puts $waiver_fileheader "LAYER_NUMBER					1234"
		puts $waiver_fileheader "DATATYPE_NUMBER					5678"
		puts $waiver_fileheader "CALIBRE_WAIVER_NUMBER			AUTO"
		puts $waiver_fileheader "ENABLE_WAIVER_CELL_REPORTING	YES"
		puts $waiver_fileheader "RETAIN_RESULT_TYPE				YES"
		puts $waiver_fileheader "RUN_LAYOUT_CHECKSUM				NO"
		close $waiver_fileheader
		puts "Calibre waive flow evoked"
		puts "Input waive gds: $list_file"

		set waiverstr "-waiver $waiver_setup"
	} 

	return $waiverstr
}
		
#############################################################################################################################
# Description: this proc help to genarate calibre deck header for report info
# Arguments:	file_handler	-the input file user declare to write in
#				workdir			-the rpt/db file dir for further usage
#				flowtype		-the flow type for different run, such as DRC/LVS/PERC/DFM/DUMMY etc.
#				typename		-p2p/cd/ldl/topo if only flowtype eq "PERC", this one is required
#				exacttype		-the exact type for different run, such as DRC/DUMMY/ANT/BUMP etc. contained by DRC
#								 for perc cnod check only, if set exacttype as "perc", check pv_calibre(perc,cnod,black_box_check,maximum_results)
# Example: gen_deck_header::write_report_names_to_file ./header.svrf WORKDIR DRC ANT
#############################################################################################################################

proc ::gen_deck_header::write_report_names_to_file {file_handler workdir flowtype {exacttype DRC} {typename ""}} {
	global pv_calibre
	set flowtype [string toupper $flowtype]	
	set exacttype [string tolower $exacttype]	

	if {[info exist pv_calibre(drc,sanity_check_only)] && $pv_calibre(drc,sanity_check_only) == 1} {
		set db_file [file join $workdir sanity_$::env(TARGET_NAME).db]
		set rpt_file [file join $workdir sanity_$::env(TARGET_NAME).rpt]
	} else {
		set db_file [file join $workdir $::env(TARGET_NAME).db]
		set rpt_file [file join $workdir $::env(TARGET_NAME).rpt]
	}

	switch -exact $flowtype {
	DRC {
		puts $file_handler "//DRC-type report, output filenames and maximum results count"
		puts $file_handler "$flowtype RESULTS DATABASE \"$db_file\"" 
		puts $file_handler "$flowtype SUMMARY REPORT \"$rpt_file\"" 
		if {$exacttype ne "perc"} {
			if {[info exists pv_calibre($exacttype,maximum_results)] && $pv_calibre($exacttype,maximum_results) ne ""} {
				puts $file_handler "$flowtype MAXIMUM RESULTS $pv_calibre($exacttype,maximum_results)" 
			} else {
				# Default all
				puts $file_handler "$flowtype MAXIMUM RESULTS ALL" 
			}
		} else {
			if {[info exists pv_calibre(perc,cnod,black_box_check,maximum_results)] && $pv_calibre(perc,cnod,black_box_check,maximum_results) ne ""} {
				puts $file_handler "$flowtype MAXIMUM RESULTS $pv_calibre(perc,cnod,black_box_check,maximum_results)" 
			} else {
				# Default all
				puts $file_handler "$flowtype MAXIMUM RESULTS ALL" 
			}
			
		}
		puts $file_handler ""
		# Cell xfrom related
		if {[info exists pv_calibre(cell_space_xform)] && $pv_calibre(cell_space_xform) == "0"} {
			# Turn off cell space xform
			puts $file_handler "//DO NOT append cellname into the signature line in hierarchical results"
			puts $file_handler "DRC CELL NAME NO"
			puts $file_handler ""
		} else {
			# Turn on cell space xform > DEFAULT
			puts $file_handler "//Append cellname into the signature line in hierarchical results"
			puts $file_handler "DRC CELL NAME YES CELL SPACE XFORM"
			puts $file_handler ""
		}
	}
	LVS {
		# FOR LVS, Below section included:
		# 1> Base_report/Summary_report/report_maximum
		# 2> Cell Xform related
		# 3> LVS OPTIONS short_isolation/cell_xform/report_options/error_abort
		# 4> LVS BOX
		# 5> LVS recon or non_recon options
		# 6> LVS Normal related options
		# 7> LVS ERC excution related
		########################################################################
		# LVS Extra statement added 0815
		#if {[info exist pv_calibre(lvs,ignore_layouttext)] && $pv_calibre(lvs,ignore_layouttext) ne ""} {
		#	puts $file_handler "LAYOUT CELL LIST my_list \"$pv_calibre(lvs,ignore_layouttext)\""
		#	puts $file_handler "LAYOUT IGNORE TEXT CELL LIST my_list DATABASE"
		#} else {
		#	puts $file_handler "//pv_calibre(lvs,ignore_layouttext) set ne 1, layout text defined by both database and textfile"
		#}
		

		# 1> Base_report/Summary_report/report_maximum
		set flowtype [string tolower $flowtype]

		puts $file_handler "LVS REPORT \"$rpt_file\"" 
		puts $file_handler "LVS SUMMARY REPORT \"[file join $workdir $::env(TARGET_NAME).summary_rpt]\"" 
		if {[info exists pv_calibre($flowtype,maximum_results)] && $pv_calibre($flowtype,maximum_results)} {
			puts $file_handler "LVS REPORT MAXIMUM $pv_calibre($flowtype,maximum_results)" 
		}
		if {[info exists pv_calibre($flowtype,max_resolution)] && $pv_calibre($flowtype,max_resolution)} {
			puts $file_handler "LVS PROPERTY RESOLUTION MAXIMUM $pv_calibre($flowtype,max_resolution)"
		}
		
		########################################################################
		# 2> Cell Xform related default on
		if {[info exists pv_calibre(cell_space_xform)] && $pv_calibre(cell_space_xform) == "0"} {
			# Turn off cell space xform
			puts $file_handler "//DO NOT append cellname into the signature line in hierarchical results"
			puts $file_handler "DRC CELL NAME NO"
			puts $file_handler ""
		} else {
			# Turn on cell space xform > DEFAULT
			puts $file_handler "//Append cellname into the signature line in hierarchical results"
			puts $file_handler "DRC CELL NAME YES CELL SPACE XFORM"
			puts $file_handler ""
		}

		########################################################################
		# 3.1> LVS-specific option settings, default isolate shorts on
		if {[info exists pv_calibre($flowtype,isolate_shorts)] && $pv_calibre($flowtype,isolate_shorts) == 0} {
			puts $file_handler "LVS ISOLATE SHORTS NO"	
		} else {
			puts $file_handler "LVS ISOLATE SHORTS YES BY CELL BY LAYER"	
		}

		# 3.2> LVS options setup, default FX
		if {[info exists pv_calibre($flowtype,report_option)] && $pv_calibre($flowtype,report_option) ne ""} {
			puts $file_handler "LVS REPORT OPTION $pv_calibre($flowtype,report_option)"
		} else {
			puts $file_handler "LVS REPORT OPTION FX"
		}

		# 3.3> LVS error abort, default on
		if {[info exists pv_calibre($flowtype,abort_on_supply_error)] && $pv_calibre($flowtype,abort_on_supply_error) ne "0"} {
			puts $file_handler "LVS ABORT ON SUPPLY ERROR YES"
		} else {
			puts $file_handler "LVS ABORT ON SUPPLY ERROR NO"
		}

		########################################################################
		# 4> LVS BOX && LVS BLACK BOX
		puts $file_handler ""
		if {[info exist pv_calibre($flowtype,box,cellnames)] || [info exist pv_calibre($flowtype,box,cell_file)]} {
			set boxstr [file_edit_func::connect_elements 0 $pv_calibre($flowtype,box,cellnames) $pv_calibre($flowtype,box,cell_file)]
			if {$boxstr ne ""} {
				puts $file_handler "//LVS BOX settings"
				if {[info exist pv_calibre($flowtype,box,black_box)] && $pv_calibre($flowtype,box,black_box) == 1} {
					puts $file_handler "LVS BOX BLACK $boxstr"
					# Black box reqire addtional commands for port layer recognition
					set portmapstr $pv_calibre($flowtype,black_box_port_mappings)
					foreach {orilayer textlayer connlayer} $portmapstr {
						puts $file_handler "LVS BLACK BOX PORT $orilayer $textlayer $connlayer"
					}
				} else {
					puts $file_handler "LVS BOX $boxstr"
				}
				puts $file_handler ""
			}
		}

		########################################################################
		# 5> LVS Recon related option
		# Set lvs_exec_optstr as global var for further usage
		global lvs_exec_optstr v2lvsworkdir

		if {[info exist pv_calibre($flowtype,recon_enable)] && $pv_calibre($flowtype,recon_enable) == 1} {
			# Basic setup
			puts $file_handler "// LVS Recon settings"
			puts $file_handler "MASK SVDB DIRECTORY \"svdb\" QUERY SI"
			if {$pv_calibre($flowtype,recon,layers) eq "ALL"} {
				puts $file_handler "LVS SI SELECT CONNECTS ALL"
			} else {
				set siconstr ""
				foreach ele_layer $pv_calibre($flowtype,recon,layers) {
					append siconstr \"$ele_layer\"
				}
				puts $file_handler "LVS SI SELECT CONNECTS BY LAYER $siconstr"
			}
			# Option setup
			if {[info exist pv_calibre($flowtype,recon,svdb)] && $pv_calibre($flowtype,recon,svdb) eq ""} {
				set svdbstr ""
			} else {
				set svdbstr "-svdb $pv_calibre($flowtype,recon,svdb)"	
			}

			if {[info exist pv_calibre($flowtype,recon,mode)] && $pv_calibre($flowtype,recon,mode) eq ""} {
				set lvs_exec_optstr "-recon -si $pv_calibre($flowtype,exec_options) -hcell $pv_calibre($flowtype,hcell_list) $svdbstr"
			} elseif {$pv_calibre($flowtype,recon,mode) ne ""} {
				set lvs_exec_optstr "-recon -si=$pv_calibre($flowtype,recon,mode) $pv_calibre($flowtype,exec_options) -hcell $pv_calibre($flowtype,hcell_list)"
			}
		} else {

			########################################################################
			# 6> LVS Normal related option
			# Below setup is not related to recon mode
			# 6.1> Just run netlist comparison if $pv_calibre(lvs,layout_netlist) specified
			if {[info exist pv_calibre($flowtype,layout_netlist)] && $pv_calibre($flowtype,layout_netlist) ne ""} {
				if {[info exist pv_calibre($flowtype,skip_comparison)] && $pv_calibre($flowtype,skip_comparison) == 1} {
					puts "Layout_netlist specified, you can not skip lvs comparison"
					puts "Error: if pv_calibre($flowtype,layout_netlist) exist, pv_calibre($flowtype,skip_comparison) shall not be 1"
					error "Error: if pv_calibre($flowtype,layout_netlist) exist, pv_calibre($flowtype,skip_comparison) shall not be 1"
				} else {
					puts "Layout_netlist specified, just run comparison"
					puts "Layout netlist is  $pv_calibre($flowtype,layout_netlist)"
					puts "Source netlist is  [file join $v2lvsworkdir $::env(TARGET_NAME).cdl]"
					set lvs_exec_optstr "-lvs $pv_calibre($flowtype,exec_options) -hcell $pv_calibre($flowtype,hcell_list) -layout $pv_calibre($flowtype,layout_netlist)"
				}
			} else {
				# 6.2> Just run netlist extraction if $pv_calibre(lvs,skip_comparison) specified
				if {[info exist pv_calibre($flowtype,skip_comparison)] && $pv_calibre($flowtype,skip_comparison) == 1} {
					set lvs_exec_optstr "$pv_calibre($flowtype,exec_options) -hcell $pv_calibre($flowtype,hcell_list) -spice $::env(TOP_MODULE)_extract.spi"
				} else {
				# 6.3> Run normal lvs, extraction && comparison both included
					set lvs_exec_optstr "-lvs $pv_calibre($flowtype,exec_options) -hcell $pv_calibre($flowtype,hcell_list) -spice $::env(TOP_MODULE)_extract.spi"
				}
			}
		}	

		########################################################################
		# 7> LVS ERC excution related
		if {[info exists pv_calibre(lvs,execute_erc)] && $pv_calibre(lvs,execute_erc) == 1} {
			puts $file_handler "// ERC execute report, output_files maximum results specifications"
			puts $file_handler "LVS EXECUTE ERC YES"
			puts $file_handler "ERC RESULTS DATABASE \"[file join $workdir $::env(TARGET_NAME).erc.db]\""
			puts $file_handler "ERC SUMMARY REPORT \"[file join $workdir $::env(TARGET_NAME).erc.rpt]\"" 

			if {[info exists pv_calibre(lvs,erc,maximum_results)] && $pv_calibre(lvs,erc,maximum_results) ne ""} {
				puts $file_handler "ERC MAXIMUM RESULTS $pv_calibre(lvs,erc,maximum_results)" 
			} else {
				puts $file_handler "ERC MAXIMUM RESULTS ALL" 
			}
		} else {
			puts $file_handler "LVS EXECUTE ERC NO"
		}
	}
	PERC {
	
		# Sub_stage base on calibre_perc.tcl, here shall be "topo/cd/p2p/ldl" 
		set flowtype [string tolower $flowtype]
		# PERC Extra statement added 0815
		if {[info exist pv_calibre(perc,ignore_layouttext)] && $pv_calibre(perc,ignore_layouttext) ne ""} {
			puts $file_handler "LAYOUT CELL LIST my_list \"$pv_calibre(perc,ignore_layouttext)\""
			puts $file_handler "LAYOUT IGNORE TEXT CELL LIST my_list DATABASE"
		} else {
			puts $file_handler "//pv_calibre(perc,ignore_layouttext) set ne 1, layout text defined by both database and textfile"
		}
		set summary_file [file join $workdir $typename.summary]
		puts $file_handler "//PERC-type report, output files, maximum results if specified"
		puts $file_handler "PERC SUMMARY REPORT \"$summary_file\""
		if {[info exists pv_calibre(perc,$typename,maximum_results)] && $pv_calibre(perc,$typename,maximum_results) ne ""} {
			puts $file_handler "PERC REPORT MAXIMUM $pv_calibre($flowtype,$typename,maximum_results)" 
		} else {
			puts $file_handler "PERC REPORT MAXIMUM ALL"
		}
		if {[info exists pv_calibre(perc,report_option)] && $pv_calibre(perc,report_option) ne ""} {
			puts $file_handler "LVS REPORT OPTION $pv_calibre(perc,report_option)"
		} else {
			puts $file_handler "LVS REPORT OPTION FX S"
		}

		# Default is PERC NETLIST LAYOUT, seperate CbFPFinalPERC AND CbFPPERC here 0816
		if {$::env(TARGET_NAME) eq "CbFPFinalPERC"} {
			if {[info exist pv_calibre(finalperc,$typename,source_type)] && $pv_calibre(finalperc,$typename,source_type) eq 1 } {
				puts $file_handler "PERC NETLIST SOURCE"
			} else {
				puts $file_handler "PERC NETLIST LAYOUT"
			}
		}
		if {$::env(TARGET_NAME) eq "CbFPPERC"} {
			if {[info exist pv_calibre(fpperc,$typename,source_type)] && $pv_calibre(fpperc,$typename,source_type) eq 1 } {
				puts $file_handler "PERC NETLIST SOURCE"
			} else {
				puts $file_handler "PERC NETLIST LAYOUT"
			}
		}

	}
	DFM {
		puts $file_handler "DFM SUMMARY REPORT $rpt_file"
	}

	default {
		error "DRC/LVS/PERC/DFM are supported by this function" 
	} 

	}
	puts $file_handler ""
}















