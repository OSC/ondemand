#!/usr/bin/env ruby

# use this file when you need to generate a new checksum for testing against.
# ./checksum.rb spec/fixture/the-file-i-changed

require "digest"

def read_file_omitting_comments(input)
  File.readlines(input).reject { |line| line =~ /^\s*#/ }.join('')
end

def checksum(input)
  Digest::SHA256.hexdigest(read_file_omitting_comments(input))
end

puts checksum(ARGV[0])
