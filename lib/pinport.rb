require 'mysql2'
require 'yaml'
require 'sequel'
require 'fileutils'
require 'pinport/parser'
require 'pinport/core_ext/hash'
require 'pinport/generators/generator'

module Pinport
  @db = nil
  @settings = nil
  @settings_file = nil
  @notifications = nil
  @verbose_errors = nil

  def self.initialize
    @db = db_connection(self.settings['database'])
    @verbose_errors = self.settings['debug']['errors']['verbose']
  end

  def self.db
    @db ||= db_connection(self.settings['database'])
  end

  def self.settings
    @settings ||= YAML.load_file(self.settings_file)
  end

  def self.settings=(new_settings)
    @settings = new_settings
  end

  def self.schema
    @settings['schema']
  end

  # loads a config file to use with pinport
  # @param file [String] the config file to load
  # @return [Hash] Parsed settings as a hash
  def self.load_config_file(file)
    if File.exists?(file)
      puts "Loading config file: #{file}"
      return YAML.load_file(file)
    else
      puts "Could not find config file: #{file}"
    end
  end

  # updates settings_file and settings vars if specified
  # config file can be found
  # @param file [String] the config file to be loaded for settings
  def self.settings_file=(file)
    if File.exists?(file)
      @settings_file = file
      self.settings = load_config_file(@settings_file)
      puts "Now using settings from: #{@settings_file}"
      return true
    elsif File.exists("#{Dir.pwd}/#{file}")
      @settings_file = "#{Dir.pwd}/#{file}"
      self.settings = load_config_file(@settings_file)
      puts "Now using settings from: #{@settings_file}"
      return true
    else
      raise "Specified settings file could assigned."
    end
  end

  def self.settings_file
    @settings_file ||= 'config.yml'
  end

  def self.root
    File.expand_path '../..', __FILE__
  end

  def self.notifications
    @notifications ||= self.settings['notifications']
  end

  # Establishes a connection to the database
  # @param config [String] path to a YAML file specifying database connection details
  # @return [Sequel::Mysql2::Database]
  def self.db_connection(db_config)
    db_config = db_config.symbolize_keys
    db_config[:test] = true
    begin
      Sequel.mysql2(db_config)
    rescue => e
      puts "An error occurred while establishing database connection."
      puts "Please verify your database connection information."
      if @verbose_errors
        puts "Trace:\n"
        puts e.backtrace
      end
      exit 1
    end
  end

  # Imports pins into database
  #
  # @param file [String] path to the file to be imported
  # @param table [String] the table name that pins should be imported into
  # @param column [String] the column name pins should be inserted into, defaults to "pin"
  # @param filter [String] a string of characters to filter out from each pin
  # @param fix_newlines [Boolean] specifies whether to fix newlines (in case of cross-OS incompatibilities), defaults to true
  def self.import_file(file, table = nil, column = nil, filter = nil, fix_newlines = true)
    source = File.open(file)
    source_dirname = File.dirname(file)
    source_basename = File.basename(file, '.txt')
    cleaned_filename = "#{source_dirname}/#{source_basename}-cleaned.txt"
    sorted_filename = "#{source_dirname}/#{source_basename}-sorted.txt"

    # clean up txt files
    cleaned = Pinport::Parser.dos2unix(file) unless fix_newlines == false
    cleaned = Pinport::Parser.strip_chars(cleaned, filter, cleaned_filename) unless filter == nil

    # perform the sort, if successful...
    if Pinport::Parser.sort_file_contents(cleaned, sorted_filename)

      # build a Sequel dataset and insert pins into it
      # retrieve table/column names from schema if not specified
      table = self.settings['schema']['table'] unless table != nil
      column = self.settings['schema']['column'] unless column != nil
      pins = self.db[table.to_sym]

      # open the sorted file and insert each pin line-by-line
      count = 0
      start_time = Time.now
      File.open(sorted_filename).each_line do |line|
        pins.insert(column.to_sym => line.chomp)
        count += 1
        puts "Imported #{count} pins." if (count % self.notifications['import']['every'] == 0)
      end
      puts "Finished importing #{count} pins into #{table}."

      # remove any temporary files that were created
      File.delete(cleaned_filename) if File.exists?(cleaned_filename)
      File.delete(sorted_filename) if File.exists?(sorted_filename)
    else
      puts "Error encountered while sorting pins in file."
      return false
    end
  end

  # Imports pins from folder containing pin files
  #
  # Accepts the same parameters as `import_file` along with the following:
  # @param extension [String] file extension of files to be imported, defaults to 'txt'
  def self.import_folder(folder, extension = "txt", table = nil, column = nil, filter = nil, fix_newlines = true)
    Dir.glob("#{folder}/*.#{extension}").each do |file|
      import_file(file, table, column, filter)
    end
  end
end