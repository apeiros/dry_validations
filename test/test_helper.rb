require 'rr'
require 'test/unit'

$LOAD_PATH.unshift(File.expand_path('../../lib', __FILE__))

class Test::Unit::TestCase
  include RR::Adapters::TestUnit
end

# Fake Activerecord::Base
class ActiveRecord; class Base; end; end
