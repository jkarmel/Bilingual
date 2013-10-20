require 'execjs'
require 'active_support/core_ext'

module Bilingual
  CONTEXT = ExecJS.compile File.open('test.js').read
  CONTEXT.eval "objects = []"

  def method_missing *args
    method_name = args[0].to_s.camelize(:lower)
    prop =  "objects[#{@js_index}].#{method_name}"
    if CONTEXT.eval("typeof #{prop} == 'function'")
      CONTEXT.eval "#{prop}()"
    else
      CONTEXT.eval prop
    end
  end

  def initialize
    CONTEXT.eval("objects.push(new TestClass)")
    @js_index = CONTEXT.eval("objects.length") - 1
  end
end

class TestClass
  include Bilingual
  def call_js_from_ruby
    from_js + " and from ruby land"
  end
end

test = TestClass.new
p test.a
p test.call_js_from_ruby
