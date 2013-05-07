module Pinport
  class Error < StandardError
  end

  class DatabaseConnectionError < Error
    def message
      @msg = "An error occurred while establishing database connection.\n"
      @msg += "Please verify your database connection information."
      @msg
    end
  end

  class InvalidFileError < SystemCallError
    def message
      "An invalid file or directory was specified. Please try again."
    end
  end

  class UnexpectedArgumentError < ArgumentError
    def message
      "Encountered an unexpected argument."
    end
  end

  class DirectoryArgumentError < UnexpectedArgumentError
    def message
      "A directory was supplied as an argument to a method expecting a file argument."
    end
  end
end