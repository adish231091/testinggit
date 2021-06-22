class student
{
	final int a=10;

	static String var1="bangalore";
	void display()
	{
		System.out.println("OUDP is a Oracle product");
	}

	void show()
	{
		System.out.println("OUDP QA Team is in Bangalore");
		String var1="ORACLE";
		String var2= var1.toLowerCase();
		System.out.println(var2);
	}


	public static void main(String []args)
	{
		student s= new student();
		
		s.display();
		s.show();
	}
}


