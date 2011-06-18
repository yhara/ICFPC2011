$:.unshift(File.expand_path("../lib", File.dirname(__FILE__)))

require "test/unit"
require "pp"
require "tempfile"
require "fileutils"
require "stringio"

class Test::Unit::TestCase
end
