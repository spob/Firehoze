module Exceptions
  # A general purpose exception to signify that a condition that should never be true has occurred,
  # indicating a bug in the program
  class AssertionFailed < StandardError; end 
end