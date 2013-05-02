class Hash
  # Returns a hash containing symbolized keys
  #
  # @param hash [Hash]
  # @return [Hash] The same hash with symbolized keys
  def symbolize_keys
    return nil unless hash
    result = {}
    each_key do |key|
      result[key.to_sym] = self[key]
    end
    result
  end

end