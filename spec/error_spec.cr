require "spec"
require "../src/error.cr"

class CustomError < Error
  @message = "custom error"
end

def custom_error
  CustomError.throw
end

def standard_error
  Error.throw "error!"
end

def main_program(message : String? = nil) : Error?
  case result = standard_error
  when Error then throw result, message
  end
end

struct TestClass
  def self.receiver
    Error.throw "error"
  end

  def noreceiver
    Error.throw "error"
  end
end

describe Error do
  describe "Error.throw" do
    it "returns an error message" do
      error = standard_error
      error.to_s.should eq "error!"
      error.inspect.should eq <<-E
      error! (Error)
         from spec/error_spec.cr:13 in 'standard_error'
      E
    end

    it "returns a custom error" do
      error = custom_error
      error.should be_a Error
      error.to_s.should eq "custom error"
      error.inspect.should eq <<-E
      custom error (CustomError)
         from spec/error_spec.cr:9 in 'custom_error'
      E
    end

    it "prints the class and a method with no receiver in the backtrace" do
      TestClass.receiver.inspect.should eq <<-E
      error (Error)
         from spec/error_spec.cr:24 in 'TestClass.receiver'
      E
    end

    it "prints the class and a method with a receiver in the backtrace" do
      TestClass.new.noreceiver.inspect.should eq <<-E
      error (Error)
         from spec/error_spec.cr:28 in 'TestClass#noreceiver'
      E
    end
  end

  describe "throw" do
    it "an error with no message" do
      main_program.inspect.should eq <<-E
       (Error)
         from spec/error_spec.cr:13 in 'standard_error'
         from spec/error_spec.cr:18 in 'main_program'
      E
    end

    it "an error with a message" do
      main_program("Not successful").inspect.should eq <<-E
      Not successful (Error)
         from spec/error_spec.cr:13 in 'standard_error'
         from spec/error_spec.cr:18 in 'main_program'
      E
    end
  end
end
