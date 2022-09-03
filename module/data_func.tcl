# Register the package
package provide data_func 1.0

# This package help to gen data, return lists for further usage

# Create namespace
namespace eval ::data_func {
	namespace export get_datatype get_dbdir get_execopt get_layout_file
}
#############################################################################################################################
# Description: help to set execopt for the further usage
# Arguments: 
#			-flowtype DRC/DUMMY/ANT/BUMP/LVS/PERC
#			-stage erc or perc substage (more details needed)
# Example: data_func::get_execopt $flowtype $args
#############################################################################################################################

proc ::data_func::get_execopt {flowtype {stage ""} args} {
	global pv_calibre sub_stage
	set flowtype [string tolower $flowtype]
	if {[info exists pv_calibre($flowtype,lsf_remote_file)] && [file exists $pv_calibre($flowtype,lsf_remote_file)]} {
		set lsf_remote_str "-hyper remote -remotedata -recoveroff -remotefile $pv_calibre($flowtype,lsf_remote_file)"
	} else {
		set lsf_remote_str ""
	}
  
	if {[info exists pv_calibre($flowtype,exec_options)] && $pv_calibre($flowtype,exec_options) ne ""} {
		set exec_opt_base $pv_calibre($flowtype,exec_options) 
	} else {
		switch -exact $flowtype { 
			drc {
				if {[info exist pv_calibre($flowtype,localcpu_usage)] && $pv_calibre($flowtype,localcpu_usage) ne ""} {
					set exec_opt_base "-$flowtype -hier -turbo $pv_calibre($flowtype,localcpu_usage)"
				} else {
					set exec_opt_base "-$flowtype -hier -turbo 16"
				}
			}
      
			dummy {
				if {[info exist pv_calibre($flowtype,localcpu_usage)] && $pv_calibre($flowtype,localcpu_usage) ne ""} {
					set exec_opt_base "-drc -hier -turbo $pv_calibre($flowtype,localcpu_usage)"
				} else {
					set exec_opt_base "-drc -hier -turbo 16"
				}
			}
      
      lvs {
				if {$stage eq ""} {
					if {[info exist pv_calibre($flowtype,localcpu_usage)] && $pv_calibre($flowtype,localcpu_usage) ne ""} {
						set exec_opt_base "-$flowtype -hier -turbo $pv_calibre($flowtype,localcpu_usage)"
					} else {
						set exec_opt_base "-$flowtype -hier -turbo 16"
					}
				} elseif {$stage eq "erc"} {
					if {[info exist pv_calibre($flowtype,$stage,localcpu_usage)] && $pv_calibre($flowtype,$stage,localcpu_usage) ne ""} {
						set exec_opt_base "-$flowtype -hier -turbo $pv_calibre($flowtype,$stage,localcpu_usage)"
					} else {
						set exec_opt_base "-$flowtype -hier -turbo 16"
					}
				}
			}

			bump {
				if {[info exist pv_calibre($flowtype,localcpu_usage)] && $pv_calibre($flowtype,localcpu_usage) ne ""} {
					set exec_opt_base "-drc -hier -turbo $pv_calibre($flowtype,localcpu_usage)"
				} else {
					set exec_opt_base "-drc -hier -turbo 16"
				}
			}

			ant {
				if {[info exist pv_calibre($flowtype,localcpu_usage)] && $pv_calibre($flowtype,localcpu_usage) ne ""} {
					set exec_opt_base "-drc -hier -turbo $pv_calibre($flowtype,localcpu_usage)"
				} else {
					set exec_opt_base "-drc -hier -turbo 16"
				}
			}

			perc {
				if { [lsearch [list "p2p" "cd" "ldl" "cnod"] $sub_stage] >= 0 } {
					if {[info exist pv_calibre($flowtype,localcpu_usage)] && $pv_calibre($flowtype,localcpu_usage) ne ""} {
						set exec_opt_base "-perc -hier -ldl -turbo $pv_calibre($flowtype,localcpu_usage) -ys_hyper" 
					} else {
						set exec_opt_base "-perc -hier -ldl -turbo 16 -ys_hyper"
					}
				} elseif {$sub_stage eq "topo"} {
					if {[info exist pv_calibre($flowtype,localcpu_usage)] && $pv_calibre($flowtype,localcpu_usage) ne ""} {
						set exec_opt_base "-perc -hier -turbo $pv_calibre($flowtype,localcpu_usage)" 
					} else {
						set exec_opt_base "-perc -hier -turbo 16"
					}
				} else {
					# The sub_stage here is black_box_check	
					if {[info exist pv_calibre(perc,cnod,black_box_check,localcpu_usage)] && $pv_calibre(perc,cnod,black_box_check,localcpu_usage) ne ""} {          
						set exec_opt_base "-drc -hier -turbo $pv_calibre(perc,cnod,black_box_check,localcpu_usage)"
					} else {
						set exec_opt_base "-drc -hier -turbo 16"
					}
				}
			}

		}
	}      
	return [list exec_opt_str $exec_opt_base lsf_remote_str $lsf_remote_str]
}      

#############################################################################################################################
# Description: help to set 2 args for the further usage
# Arguments: 
#			-NA return a list: [list layouttype $layouttype dfmdbtype $dfmdbtype] 
# Example: data_func::get_datatype
#############################################################################################################################

proc ::data_func::get_datatype { } {
	global pv_calibre
	if { [info exist pv_calibre(layout_system)] && $pv_calibre(layout_system) ne ""} {
		if {[string toupper $pv_calibre(layout_system)] eq "OASIS"} {
			set layouttype "OASIS"
			set dfmdbtype "oas"
		} elseif {[string toupper $pv_calibre(layout_system)] eq "GDSII"} {
			set layouttype "GDSII"
			set dfmdbtype "gds"
		} else {
			error "Only OASIS or GDSII is supportted for the layout system"
		}

	} else {
		set layouttype "OASIS"
		set dfmdbtype "oas"
	}
	return [list layouttype $layouttype dfmdbtype $dfmdbtype] 
}
#############################################################################################################################
# Description: help to get gds files 
# Arguments: 
#		stage	-       
#				>1, get gds file type before merge
#				>2, get gds file merged but before mfill, if not exist, then search stage 1
#				>3, get gds file merged_mfill, if not exist, then search previous stage untill get results
#		
# Example: data_func::get_layout_file perc CbFinalDummyMerge 3
#############################################################################################################################

proc ::data_func::get_layout_file {flowtype target_action dfmdbtype {stage "3"}} {
	global pv_calibre datatype
	set flowtype [string tolower $flowtype]
	# 1: if file exist for final one, then setup as the file 
	if {$stage >= 1 && [info exist pv_calibre($flowtype,inputdb)] && [file exist $pv_calibre($flowtype,inputdb)]} {
		set layout_file [file normalize $pv_calibre($flowtype,inputdb)]
	} elseif {$stage eq 3 && [file exist [file join $::env(BASE_DIR) data $::env(TOP_MODULE).$target_action.merged_mfill.$dfmdbtype]]} {
		set layout_file [file join $::env(BASE_DIR) data $::env(TOP_MODULE).$target_action.merged_mfill.$dfmdbtype]
	} elseif {$stage >= 2 && [file exist [file join $::env(BASE_DIR) data $::env(TOP_MODULE).$target_action.merged.$dfmdbtype]]} {
  	set layout_file [file join $::env(BASE_DIR) data $::env(TOP_MODULE).CbFinalDummyMerge.merged.$dfmdbtype]
	} elseif {$stage >= 1 && [file exist [file join $::env(BASE_DIR) data $::env(TOP_MODULE).CbFPIPMerge.merged.$dfmdbtype]]} {
		set layout_file [file join $::env(BASE_DIR) data $::env(TOP_MODULE).CbFPIPMerge.merged.$dfmdbtype]
	} else {
  		error "Error, layout file doesn't exist, please check with your statement"
	}
	return $layout_file
}

#############################################################################################################################
# Description:	Help to get DBdir for further usage return a list:
#				[list inputdb $inputdb outputdb $outputdb prefix $prefix temp_output $temp_outputdb stage $stage] 
#				inputdb			> a db required for target_action
#				outputdb		> a db for final output.
#				stage			> feol/beol
#				prefix			> assign by different target_action
#				temp_outputdb	> for dummy merge with refcell addin in hierachy base on inputdb
# Arguments: 
#		target_action	- CbFPIPMerge/CbFPDummy/CbFPDummyMerge/CbFPDRC/CbFPPGShort/CbFinalIPMerge/CbFinalDummy/
#						  CbFinalDummyMerge/CbFinalDRC/CbFinalLVS/CbFinalANT/CbFinalBUMP/CbFinalPERC 
#		dfmdbtype		- gds/oas
# Example: data_func::get_dbdir CbFPIPMerge oas
#############################################################################################################################
proc ::data_func::get_dbdir {target_action dfmdbtype} {
	global pv_calibre

	set dfmdbtype [string tolower $dfmdbtype]
	switch -exact $target_action { 
		CbFPIPMerge {
			if {[info exist pv_calibre(fpipmerge,inputdb)] && $pv_calibre(fpipmerge,inputdb) ne ""} {
				set inputdb $pv_calibre(fpipmerge,inputdb)
			} else {
				set inputdb	[file join $::env(BASE_DIR) data $::env(TOP_MODULE).FP.oas]
			}
			set outputdb [file join $::env(BASE_DIR) data $::env(TOP_MODULE).$target_action.merged.$dfmdbtype]
      set prefix "CbFPIP"
			set stage ""
			set temp_outputdb ""
		}
		CbFPDummyFEOL {
			if {[info exist pv_calibre(fpdummy,inputdb)] && $pv_calibre(fpdummy,inputdb) ne ""} {
				set inputdb $pv_calibre(fpdummy,inputdb)
			} else {
				set inputdb	[file join $::env(BASE_DIR) data $::env(TOP_MODULE).CbFPIPMerge.merged.$dfmdbtype]
			}
			set outputdb ""
			set prefix "CbFPDummy"
			set stage "feol"
			set temp_outputdb ""
		}
		CbFPDummyBEOL {
			if {[info exist pv_calibre(fpdummy,inputdb)] && $pv_calibre(fpdummy,inputdb) ne ""} {
				set inputdb $pv_calibre(fpdummy,inputdb)
			} else {
				set inputdb	[file join $::env(BASE_DIR) data $::env(TOP_MODULE).CbFPIPMerge.merged.$dfmdbtype]
			}
			set outputdb ""
			set prefix "CbFPDummy"    
			set stage "beol"
			set temp_outputdb ""
		}

		CbFPDummyMerge {
			if {[info exist pv_calibre(fpdummymerge,inputdb)] && $pv_calibre(fpdummymerge,inputdb) ne ""} {
				set inputdb $pv_calibre(fpdummymerge,inputdb)
			} else {
				set inputdb	[file join $::env(BASE_DIR) data $::env(TOP_MODULE).CbFPIPMerge.merged.$dfmdbtype]
			}
			set outputdb [file join $::env(BASE_DIR) data $::env(TOP_MODULE).$target_action.merged_mfill.$dfmdbtype]
			set prefix "CbFPDummy"
			set stage ""
			set temp_outputdb [file join $::env(BASE_DIR) data refcell_$::env(TOP_MODULE).CbFPIPMerge.merged.$dfmdbtype]
		}
		CbFPDRC {
			if {[info exist pv_calibre(fpdrc,inputdb)] && $pv_calibre(fpdrc,inputdb) ne ""} {
				set inputdb $pv_calibre(fpdrc,inputdb)
			} else {
				set inputdb_mfill [file join $::env(BASE_DIR) data $::env(TOP_MODULE).CbFPIPMerge.merged_mfill.$dfmdbtype]
				if {[file exist $inputdb_mfill]} {
					set inputdb	$inputdb_mfill
				} else {
					set inputdb [file join $::env(BASE_DIR) data $::env(TOP_MODULE).CbFPIPMerge.merged.$dfmdbtype]
				}
			}
			set outputdb ""
			set prefix "CbFPDRC"
			set stage ""
			set temp_outputdb ""
		}

		CbFPPGShort {
			# Setup verilog files for v2lvs      
 			if {[info exist pv_calibre(fppgshort,input_verilog)] && $pv_calibre(fppgshort,input_verilog) ne ""} {
				set inputverilog $pv_calibre(fppgshort,input_verilog)
			} else {
				set inputverilog [file join $::env(BASE_DIR) data Place.v.gz]
			}
			# Setup layout files for extraction
			if {[info exist pv_calibre(fppgshort,inputdb)] && $pv_calibre(fppgshort,inputdb) ne ""} {     
 				set inputdb $pv_calibre(fppgshort,inputdb)
			} else {
				set inputdb_mfill [file join $::env(BASE_DIR) data $::env(TOP_MODULE).CbFPIPMerge.merged_mfill.$dfmdbtype]
				if {[file exist $inputdb_mfill]} {
					set inputdb	$inputdb_mfill
				} else {
					set inputdb [file join $::env(BASE_DIR) data $::env(TOP_MODULE).CbFPIPMerge.merged.$dfmdbtype]
				}
			}     
			set outputdb [file join $::env(BASE_DIR) data $::env(TOP_MODULE).$target_action.spi]
			set prefix "CbFPPGShort"
			set stage ""
			set temp_outputdb ""
			return [list inputdb $inputdb inputverilog $inputverilog outputdb $outputdb prefix $prefix temp_output $temp_outputdb stage $stage]
		}
		CbFinalIPMerge {
			if {[info exist pv_calibre(finalipmerge,inputdb)] && $pv_calibre(finalipmerge,inputdb) ne ""} {
				set inputdb $pv_calibre(finalipmerge,inputdb)
			} else {
				set inputdb	[file join $::env(BASE_DIR) data ReRoute.oas]
			}
			set outputdb [file join $::env(BASE_DIR) data $::env(TOP_MODULE).$target_action.merged.$dfmdbtype]
			set prefix "CbFinalIP"      
			set stage ""
			set temp_outputdb ""
		}

		CbFinalDummyFEOL {
			if {[info exist pv_calibre(finaldummy,inputdb)] && $pv_calibre(finaldummy,inputdb) ne ""} {
				set inputdb $pv_calibre(finaldummy,inputdb)
			} else {      
				set inputdb	[file join $::env(BASE_DIR) data $::env(TOP_MODULE).CbFinalIPMerge.merged.$dfmdbtype]
			}
			set outputdb ""
			set prefix "CbFinalDummy"
			set stage "feol"
			set temp_outputdb ""
		}
		CbFinalDummyBEOL {
			if {[info exist pv_calibre(finaldummy,inputdb)] && $pv_calibre(finaldummy,inputdb) ne ""} {
				set inputdb $pv_calibre(finaldummy,inputdb)
			} else {
				set inputdb	[file join $::env(BASE_DIR) data $::env(TOP_MODULE).CbFinalIPMerge.merged.$dfmdbtype]
			}
			set outputdb ""
			set prefix "CbFinalDummy"
			set stage "beol"
			set temp_outputdb ""
		}
		CbFinalDummyMerge {
			if {[info exist pv_calibre(finaldummymerge,inputdb)] && $pv_calibre(finaldummymerge,inputdb) ne ""} {
				set inputdb $pv_calibre(finaldummymerge,inputdb)
			} else {
				set inputdb	[file join $::env(BASE_DIR) data $::env(TOP_MODULE).CbFinalIPMerge.merged.$dfmdbtype]
			}
			set outputdb [file join $::env(BASE_DIR) data $::env(TOP_MODULE).$target_action.merged_mfill.$dfmdbtype]
			set prefix "CbFinalDummy"
			set stage ""
			set temp_outputdb [file join $::env(BASE_DIR) data refcell_$::env(TOP_MODULE).CbFinalIPMerge.merged.$dfmdbtype]
		}

		CbFinalDRC {
			if {[info exist pv_calibre(finaldrc,inputdb)] && $pv_calibre(finaldrc,inputdb) ne ""} {
				set inputdb $pv_calibre(finaldrc,inputdb)
			} else {
				set inputdb_mfill [file join $::env(BASE_DIR) data $::env(TOP_MODULE).CbFinalDummyMerge.merged_mfill.$dfmdbtype]
				if {[file exist $inputdb_mfill]} {
					set inputdb	$inputdb_mfill
				} else {    
					set inputdb [file join $::env(BASE_DIR) data $::env(TOP_MODULE).CbFinalIPMerge.merged.$dfmdbtype]
				}
			}
			set outputdb ""
			set prefix "CbFinalDRC"
			set stage ""
			set temp_outputdb ""
		}
		CbFinalANT {
			if {[info exist pv_calibre(finalant,inputdb)] && $pv_calibre(finalant,inputdb) ne ""} {
				set inputdb $pv_calibre(finalant,inputdb)
			} else {
				set inputdb_mfill [file join $::env(BASE_DIR) data $::env(TOP_MODULE).CbFinalDummyMerge.merged_mfill.$dfmdbtype]
				if {[file exist $inputdb_mfill]} {
					set inputdb	$inputdb_mfill    
				} else {
					set inputdb [file join $::env(BASE_DIR) data $::env(TOP_MODULE).CbFinalDummyMerge.merged.$dfmdbtype]
				}
			}
			set outputdb ""
			set prefix "CbFinalANT"
			set stage ""
			set temp_outputdb ""
		}
		CbFinalBUMP {
			if {[info exist pv_calibre(finalbump,inputdb)] && $pv_calibre(finalbump,inputdb) ne ""} {
				set inputdb $pv_calibre(finalbump,inputdb)
			} else {
				set inputdb_mfill [file join $::env(BASE_DIR) data $::env(TOP_MODULE).CbFinalDummyMerge.merged_mfill.$dfmdbtype]
				if {[file exist $inputdb_mfill]} {
					set inputdb	$inputdb_mfill
				} else {
					set inputdb [file join $::env(BASE_DIR) data $::env(TOP_MODULE).CbFinalDummyMerge.merged.$dfmdbtype]
				}
			}
			set outputdb ""
			set prefix "CbFinalBUMP"
			set stage ""
			set temp_outputdb ""
		}

		CbFinalLVS {        
			# Setup verilog files for v2lvs
			if {[info exist pv_calibre(lvs,input_verilog)] && $pv_calibre(lvs,input_verilog) ne ""} {
				set inputverilog $pv_calibre(lvs,input_verilog)
			} else {
				set inputverilog [file join $::env(BASE_DIR) data ReRoute.v.gz]
			}
			# Setup layout files for extraction    
			if {[info exist pv_calibre(lvs,inputdb)] && $pv_calibre(lvs,inputdb) ne ""} {
				set inputdb $pv_calibre(lvs,inputdb)
			} else {
				set inputdb [file join $::env(BASE_DIR) data $::env(TOP_MODULE).CbFinalDummyMerge.merged_mfill.$dfmdbtype]
			}
			# Here the outputdb is a spice file
			set outputdb [file join $::env(BASE_DIR) data $::env(TOP_MODULE).$target_action.spi]    
			set prefix "CbFinalLVS"
			set stage ""
			set temp_outputdb ""

			return [list inputdb $inputdb inputverilog $inputverilog outputdb $outputdb prefix $prefix temp_output $temp_outputdb stage $stage]
		}
		CbFPPERC {
			# Setup layout files && spice files for perc extraction
			global datatype
			# Here inputdb is $::env(TOP_MODULE).CbFPIPMerge.merged.$dfmdbtype
			set inputgds [data_func::get_layout_file fpperc CbFPIPMerge $datatype(dfmdbtype) 1]
			puts "the input layout file for CbFPPERC is $inputgds"    
			if {[info exist pv_calibre(fpperc,spice_netlist)] && $pv_calibre(fpperc,spice_netlist) ne ""} {
				set inputspi $pv_calibre(fpperc,spice_netlist)
			} else {
				# Further work reqired for spice setup, check v2lvs dir
				set inputspi [file join $::env(BASE_DIR) data CbFPPGShort v2lvs CbFPPGShort.cdl]
			}    
			# Check if work in source base
			if {[info exist pv_calibre(fpperc,topo,source_type)] && $pv_calibre(fpperc,topo,source_type) ne ""} {
				puts "the input spice netlist for CbFPPERC TOPO is $inputspi"
			}

			set outputdb ""
			set prefix "CbFPPERC"
			# LDL is not required for CbFPPERC
			set stage "topo p2p cd"
			set temp_outputdb ""
			return [list inputgds $inputgds inputspi $inputspi outputdb $outputdb prefix $prefix temp_output $temp_outputdb stage $stage]
		}

		CbFinalPERC {
			# Setup layout files && spice files for perc extraction
			global datatype
			# Here inputdb is $::env(TOP_MODULE).CbFPFinalDummyMerge.merged_mfill.$dfmdbtype
			set inputgds [data_func::get_layout_file finalperc CbFinalDummyMerge $datatype(dfmdbtype) 3 ]    
			puts "the input layout file for CbFinalPERC is $inputgds"
			if {[info exist pv_calibre(perc,spice_netlist)] && $pv_calibre(perc,spice_netlist) ne ""} {
				set inputspi $pv_calibre(perc,spice_netlist)
			} else {
				set inputspi [file join $::env(BASE_DIR) data $::env(TOP_MODULE).CbFinalLVS.spi]
			}
			# Check if work in source base    
  		if {[info exist pv_calibre(perc,topo,source_type)] && $pv_calibre(perc,topo,source_type) ne ""} {
				puts "the input spice netlist for CbFinalPERC TOPO is $inputspi"
			}

			set outputdb ""
			set prefix "CbFinalPERC"
			set stage "topo p2p cd ldl"
			set temp_outputdb ""  

			return [list inputgds $inputgds inputspi $inputspi outputdb $outputdb prefix $prefix temp_output $temp_outputdb stage $stage]
		}

	}
	return [list inputdb $inputdb outputdb $outputdb prefix $prefix temp_output $temp_outputdb stage $stage]
}    
    
    
    
    
    
    
    
    
    
    
    
    
      
