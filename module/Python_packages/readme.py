# Here is a python module example for usage
#>1 Import package, you can see study.py in the appended path
import sys
sys.path.append("./PV_flow/module/Python_packages/")
#>2 Import module
from example import study

#>3 Try functions
#3.1 invoke class Abc1() function main func:
study.Abc1()
#3.2 invoke class Abc1() functions test1()
study.Abc1().test1()
#3.3 invoke function Abc() -- Not class here
study.Abc()
