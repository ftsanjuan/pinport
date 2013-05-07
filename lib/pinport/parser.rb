module Pinport
  class Parser
    require 'tempfile'
    require 'shellwords'

    class << self
      # Fixes linebreaks on files
      # @param file [String] path to the file to be processed by dos2unix
      # @param output_path [String] path to file where output should be returned, defaults to same path as `file` parameter
      # @return [String] path to file that was processed
      def dos2unix(file, output_path = nil)
        puts "Fixing newlines for #{file} ..."
        if File.exists?(file)
          input = File.open(file)
          output = Tempfile.new("/tmp")
          regex = /\r\n/
          newstring = "\n"
          while (line = input.gets) do
            output_line = line.gsub(regex, newstring)
            output << output_line
          end
          input.close
          output.close
          output_path = file unless output_path != nil
          system("mv #{Shellwords.shellescape(output.path)} #{Shellwords.shellescape(output_path)}")
          puts "Parser: Corrected newlines."
          return output_path
          # return "Newlines were successfully fixed for #{file}"
        else
          puts "Specified file does not exist."
          return nil
        end
      end

      # Strips characters to be filtered
      # @param file [String] path to the file to be processed
      # @param chars [String] a string of characters to be filtered out
      # @param output_path [String] path to file where output should be returned, defaults to same path as `file` parameter
      # @return [String] path to file that was processed
      def strip_chars(file, chars, output_path = nil)
        puts "Filtering: #{file} ..."
        if File.exists?(file)
          input = File.open(file)
          output = Tempfile.new("/tmp")
          while (line = input.gets) do
            output_line = line.gsub!(chars, '')
            output << output_line
          end
          input.close
          output.close
          output_path = file unless output_path != nil
          system("mv #{Shellwords.shellescape(output.path)} #{Shellwords.shellescape(output_path)}")
          puts "Parser: Filtered #{chars}."
          return output_path
        else
          puts "Specified file does not exist."
          return nil
        end
      end

      # Runs the `sort` command to sort a text file
      # Returns true if successfully outputted to a file
      # Otherwise returns the contents of the result
      # @param input [String] path to the file to be sorted
      # @param output_path [String] the path to
      def sort_file_contents(input, output_path = nil)
        puts "Sorting: #{input} ..."
        # Shellescape arguments to prevent errors
        system("sort #{Shellwords.shellescape(input)} -o #{Shellwords.shellescape(output_path)}") unless output_path == nil
        return true

        # otherwise: return the result
        `sort #{input}`
      end
    end
  end
end