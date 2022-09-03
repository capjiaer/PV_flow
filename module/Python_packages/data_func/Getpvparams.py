import sys, os, re, json

# Generate all dict for each ele in supported_list

class Getpvparams_dict():
	def __init__(self):
        		super().__init__()
		# INI setup for pv_functions
		self.input_file2 = "/home/apchen1/project/module_setup/calibre/decksetup/TSMC/default_setup.tcl"
		self.pv_fprun_list = ["xCbFPIPMerge", "xCbFPDummyFEOL", "xCbFPDummyBEOL", "xCbFPDummyMerge", "xCbFPDRC", "xCbFPPGShort", "xCbFPPERC"]
		self.pv_finalrun_list = ["xCbFinalIPMerge", "xCbFinalDummyFEOL", "xCbFinalDummyBEOL", "xCbFinalDummyMerge", "xCbFinalDRC", "xCbFinalBUMP", "xCbFinalANT", "xCbFinalLVS", "xCbFinalPERC"]
        self.supported_list = ["ipmerge", "dummy", "drc" ,"bump" ,"ant" ,"lvs", "perc"]
		for ele in self.supported_list:
			exec("self.%s = {}" %ele)
		self.final_target_list = self.pv_fprun_list + self.pv_finalrun_list
	def gen_params_dict(self, supported_ele, file1, file2 = "/home/apchen1/project/module_setup/calibre/decksetup/TSMC/default_setup.tcl"):
		"""
		This function works for the Params about the input situation
		the input comes from 2 files
		> 1: Default setupfile
		> 2: override.params
		"""
		root1, extension1 = os.path.splitext(file1)
		root2, extension2 = os.path.splitext(file2)
		# Check if a .params file
		if extension1 != ".params":
			print("Error, the input_file1 shall be a params file")
			exit()
		with open(file1, 'r') as file1_handle:        
			for lines in file1_handle.readlines():
				# Get all PV_CALIBRE lines
				matchobj = re.match(r'(^PV_CALI.*) = (.*)', lines)
				if matchobj:
					for ele in self.supported_list:
						if ele in matchobj.group(1).lower():
							# Setup all related dict base on PV_CALIBRE lines        
							exec('self.%s[\'%s\'] = \'%s\'' %(ele, matchobj.group(1), matchobj.group(2)))
		print("=============== params record =============")	
		for ele in self.supported_list:
			if ele in supported_ele.lower():
				exec('if len(self.%s) > 0:print("your " + ele + " setup >")' %(ele))
				exec('for key,value in self.%s.items():print(key, "=", value)' %(ele))
                
# Below work for debug						
if __name__ == '__main__':
	input_file1 = "/home/apchen1/project/module_setup/calibre/module/cad_tools/Python_packages/data_func/testcase/override.params"
	Getpvparams_dict().gen_params_dict(input_file1)	        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
