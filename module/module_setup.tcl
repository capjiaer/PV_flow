# Register the package
package provide file_edit_func 1.0
package provide rule_temp 1.0
package provide old_files 1.0

# This package help to gen cshfile, env var setup, deal with files
# Create namespace
namespace eval ::file_edit_func {
	namespace export get_para_data
}

namespace eval ::rule_temp {
	namespace export write_file
}


namespace eval ::old_files {
	namespace export backup
}

#############################################################################################################################
# Description: this proc help to reset the variable for pv calibre run and set it as a tcl scripts for the further usage
# Arguments: 
#		outputfile	- the file for output tcl file for PV calibre run
#		inputfile	- the file for readin to reset 
#		mode		
#			- 1: copy the PV_CALIBRE* LINE
#			- 2: switch PV_CALIBRE* LINE as tcl structure: set PV_CALIBRE_VAR value
#			- 3: switch PV_CALIBRE* LINE as array structure: set pv_calibre(VAR) value
# Example: file_edit_func::get_para_data $calibre_ipmerge_params $::env(BASE_DIR)/tile.params 1
#############################################################################################################################
proc ::file_edit_func::get_para_data {outputfile inputfile {mode 3}} {

	set inputfile [open $inputfile "r"]
	set outputfile [open $outputfile "w"]
	puts $outputfile "# Default setup ref: /home/apchen1/project/module_setup/calibre/decksetup/TSMC/default_setup.tcl"
	while {[gets $inputfile line] >= 0} {
  	if {[regexp "(^PV_CALIBRE_)((\[A-Z\]+_)*)(\\w+)\\s+=\\s+(.*)" $line all_match sp1 sp2 sp3 sp4 sp5]} {
			if {$mode eq "3"} {
				# set as a PV array	
				# modify the $sp2 from sp2 var1_var2_ to "var1 var2 {}"
				set sp2_list [split $sp2 "_"]
				# modify $sp2 to "var1,var2,"
				set sp2_list [string tolower [join $sp2_list ","]]
				puts $outputfile "set pv_calibre(${sp2_list}${sp4}) $sp5"
			}

			if {$mode eq "2"} { 
				# just copy lines
				puts $outputfile $line
			}

			if {$mode eq "1"} {
				# transform as normal tcl mode
				set line_list [split $line "="]
				puts $outputfile "set [lindex $line_list 0] [lindex $line_list 1]" 
			} 
		}
	}
	close $inputfile
	close $outputfile

}


#############################################################################################################################
# Description: this proc help to concat numorous files and lists together then export the result in a new file
# Arguments: 
#		output_file	- the file for output elements merged file for calibre run, if set 0, then output nothing and return list        
#		args -shall be a file or a list
# Example: file_edit_func::connect_elements output.text ./a.text ./b.text $a $b $c
#############################################################################################################################
proc ::file_edit_func::connect_elements {{output_file 0} args} {        
	set element_final_list	[list]
	foreach arg $args {

		if {[file exist $arg]} {
			# if the args is file, then lappend all efficient lines to list lib_final_list.
			set fp [open $arg "r"]
			while {[gets $fp line] >= 0} {
				# skip ^# lines and empty lines
				if {[llength $line] != 0 && ![regexp "^\\s+#" $line] && ![regexp "^#" $line] } {
					set element_final_list [lappend element_final_list $line] 
				}
			}        
			close $fp
		} else {
			# if the args is not a file, then lappend all efficient elements to list lib_final_list
			set element_final_list [concat $element_final_list $arg]
		}
	}

	# all results puts to outputfile if output_file ne 0
	if {$output_file != 0} {	
		set output_file [open $output_file "w"]
		foreach ele $element_final_list {
			puts $output_file $ele 
		}
		close $output_file 
	}	
	return $element_final_list
}

#############################################################################################################################
# Description: this proc help to translate a csh template into a outputfile with different keyword for the further csh usage
# Arguments: 
#		temp_file		-input temp_file to be processed
#		out_file		-output file to be written after processing temp_file
#		mapdict			-keyword mapping dictionary for substituting keywords
#		-opendelimiter	-open delimiter string, default is "<<"
#		-closedelimiter	-close delimiter string, default is ">>"
#		-delundef		-if delete the undefined keyword (1) or preserve (0)
#
# Example: rule_temp::write_file temp_file output.text $mapdict -delundef 1
#############################################################################################################################

proc ::rule_temp::write_file {temp_file out_file mapdict args} {
	array set optargs [list -opendelimiter "<<" -closedelimiter ">>" -permissions "rw-r--r--" -delundef 0]        
	array set optargs $args
	set infile [open $temp_file "r"]
	set outfile [open $out_file "w"]
	while {[gets $infile line] >= 0} {
		if {[regexp "${optargs(-opendelimiter)}\\S+${optargs(-closedelimiter)}" $line]} {
			set rol $line
			set printline ""        
			# loop over this line untill process all keyword 
			while {$rol ne ""} {
				if {[regexp "^(.*?)${optargs(-opendelimiter)}(\\S+?)${optargs(-closedelimiter)}(.*)$" $rol -> sol match_var rol]} {
					append printline $sol
					if {[dict exists $mapdict $match_var]} {
						append printline [dict get $mapdict $match_var]        
					} elseif {$optargs(-delundef) == 0} {
						# preserve undefined keyword if required
						append printline "${optargs(-opendelimiter)}${match_var}${optargs(-closedelimiter)}"
					}
				} else {
					append printline $rol
					set rol ""
				}
			}
			# replace finished        
			puts $outfile $printline
		} else {
			# copy the line without keyword
			puts $outfile $line
		}
	}
	close $infile
	close $outfile
	file attributes $out_file -permission $optargs(-permissions)
}
#############################################################################################################################
# Description: this proc help to backup old csh/tcl/log files
# Arguments: 
#		filedir		- default 1, this proc will 
#					  > set [file join $::env(BASE_DIR) data $target_action] as source_dir
#					  > set [file join $source_dir $dirname] as target_dir        
#					  user can also setup a normalize dir to reset source_dir/target_dir
#		dirname		- the dirname for old files setup
#		args		- csh/log/tcl etc.. that user may decide with type files to move
#
# Example: old_files::backup 1 old_file *.csh *.log *.tcl *.py 
#############################################################################################################################
        
proc ::old_files::backup {{filedir 1} dirname args} {
	global pv_calibre target_action
	# Redirect CbFinalDummyFEOL CbFinalDummyBEOL CbFPDummyFEOL CbFPDummyBEOL
	if {$target_action eq "CbFinalDummyFEOL" || $target_action eq "CbFinalDummyBEOL"} {
		set target_action "CbFinalDummy" 
	}
	if {$target_action eq "CbFPDummyFEOL" || $target_action eq "CbFPDummyBEOL"} {
		set target_action "CbFPDummy"
	}        
	# Filedir setup, Default 1
	if {$filedir eq 1} {
		set source_dir [file join $::env(BASE_DIR) data $target_action] 
	} else {
		set source_dir $filedir 
	} 

	set target_dir [file join $source_dir $dirname] 

	file mkdir $target_dir
	foreach ele $args {        
		lappend old_filetype $ele
	}
	set old_files [glob -nocomplain -type f $source_dir/*{[join $old_filetype ","]}]
	# Move old file to $dirname
	foreach oldfile $old_files {
		file rename -force $oldfile [file join $target_dir [file tail $oldfile]] 
	}
}        
        
        
        
        
        
        
        
        
        
