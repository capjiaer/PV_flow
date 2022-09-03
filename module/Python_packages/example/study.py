class Abc1():
	def __init__(self):
		super().__init__()
		self.abc = "hello world, here is mainfunc for class Abc()"
		print(self.abc)
	
	def test1(self):
		print("hi, here is func test1 in class Abc1()")

def Abc():
	print("hello, here is std alone func named Abc")
