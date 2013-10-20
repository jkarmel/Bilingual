require 'execjs'
require 'active_support/core_ext'
require "test/unit"

module Bilingual
  CONTEXT = ExecJS.compile File.open('test.js').read
  CONTEXT.eval "objects = []"


  def method_missing *args
    method_name = args[0].to_s.camelize(:lower)
    prop =  "objects[#{@js_index}].#{method_name}"
    if CONTEXT.eval("typeof #{prop} == 'function'")
      arguments = args[1..-1].join ','
      CONTEXT.eval "#{prop}(#{arguments})"
    else
      CONTEXT.eval prop
    end
  end

  def initialize
    CONTEXT.eval("objects.push(new #{self.class.js_class_name})")
    @js_index = CONTEXT.eval("objects.length") - 1
  end

  def self.included(base)
    base.extend(ClassMethods)
  end

  module ClassMethods
    attr_accessor :js_class_name
    def set_js_class class_name
      self.js_class_name = class_name
    end
  end

end

class TestClass
  include Bilingual
  set_js_class 'TestClass'
  def call_js_from_ruby
    from_js + " and from ruby land"
  end
end


class TestBilingual < Test::Unit::TestCase
  def test_something
    test = TestClass.new
    assert test.a == 2
    assert test.call_js_from_ruby == "hey from javascript land and from ruby land"
    assert test.add_two 2 == 4
  end
end
