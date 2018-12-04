require 'sinatra/base'
require 'json'
require 'active_support/all'

module Sinatra
  module FileEncoder
    def encode_from_file_location(file)
      encoded_file = unpack_file(file) if file
      Base64.strict_encode64(encoded_file)
    end

    def unpack_file(file)
      open(file, &:read)
    end

    def helper_dir
      File.dirname(__FILE__)
    end
  end
  helpers FileEncoder
end
