require 'faker'
describe "An example of the comparison Matchers" do

   it "C28170: should show how the comparison Matchers work" do
      a = 1
      b = 2
      c = 3		
      d = 'test string'
      
      # The following Expectations will all pass
      expect(b).to be > a
      
      #expect(a).to be >= a 
  
   end
   
end
