# Register the package
package provide debug_proc 1.0

# This package help to setup debug part if required

# Create namespace
namespace eval ::debug_proc {
	namespace export option_check
}
#############################################################################################################################
# Description: This proc help to genarate calibre deck header for rule deck info
#			   If option list in user_opt_list is not contained in ref_opt_list, then error out and report informaiton
#			   Help for debug base on the requirement
#
# Arguments:	supply_opt_list	- The input options allowed setup by proc
#				user_opt_list	- The input options setup by user
#				required_list	- The ele in list must required
#				debug_info_proc	- A proc help to setup debug info if required
#
# Example: gen_deck_header::write_input_data_to_file ./header.svrf ./top.gds top_cell GDSII
#############################################################################################################################
proc ::debug_proc::option_check { supply_opt_list required_list user_opt_list debug_info_proc } {
	global pv_calibre
	
	# All ele must in supply_opt_list
	foreach ele $user_opt_list {
		if {[lsearch $supply_opt_list $ele] < 0} {
			puts "$ele >> unrecognized option"
			# Execute debug_info directory
			$debug_info_proc
		} 
	}

	# ALL ele in required_list must in user_opt_list
	foreach ele $required_list {
		if {[lsearch $user_opt_list $ele] < 0} {
			puts "$ele >> missing option"
			# Execute debug_info directory
			$debug_info_proc
		}       
	}

}













