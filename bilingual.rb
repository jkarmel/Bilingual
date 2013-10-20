require 'execjs'
require 'active_support/core_ext'
require "test/unit"

module Bilingual
  CONTEXT = ExecJS.compile File.open('test.js').read
  CONTEXT.eval "objects = []"

  def initialize
    CONTEXT.eval("objects.push(new #{self.class.js_class_name})")
    js_index = CONTEXT.eval("objects.length") - 1
    @js_object_reference = "objects[#{js_index}]"
  end

  def method_missing *args
    sync do
      property_name = args[0].to_s.camelize(:lower)
      property_reference =  "#{@js_object_reference}.#{property_name}"
      if CONTEXT.eval("typeof #{property_reference} == 'function'")
        arguments = args[1..-1].join ','
        CONTEXT.eval "#{property_reference}(#{arguments})"
      else
        CONTEXT.eval property_reference
      end
    end
  end

  def js_object
    CONTEXT.eval @js_object_reference
  end

  def sync_ruby_to_js name
    var = self.__send__ "#{name}"
    if var.class.name == "String"
      CONTEXT.eval "#{@js_object_reference}.#{name.camelize(:lower)} = '#{var}'"
    end
  end

  def sync_js_to_ruby name
    val = CONTEXT.eval "#{@js_object_reference}.#{name.camelize(:lower)}"
    __send__ "#{name}=", val
  end

  def sync
    self.class.vars_to_sync.each do |name|
      sync_ruby_to_js name
    end

    ret = yield

    self.class.vars_to_sync.each do |name|
      sync_js_to_ruby name
    end
    ret
  end

  def self.included(base)
    base.extend(ClassMethods)
  end

  module ClassMethods
    attr_accessor :js_class_name
    attr_accessor :vars_to_sync
    def set_js_class class_name
      self.js_class_name = class_name
    end
    def js_sync *names
      self.vars_to_sync = names.map &:to_s
    end
  end

end

class TestClass
  include Bilingual
  set_js_class 'TestClass'
  attr_accessor :full_name
  js_sync :full_name
  def call_js_from_ruby
    from_js + " and from ruby land"
  end
end

class Person
  include Bilingual
  set_js_class 'Person'
  attr_accessor :first_name, :last_name
  js_sync :first_name, :last_name
  def call_js_from_ruby
    from_js + " and from ruby land"
  end
end


class TestBilingual < Test::Unit::TestCase
  def tests
    test = TestClass.new
    assert test.a == 2
    assert test.call_js_from_ruby == "hey from javascript land and from ruby land"
    assert test.add_two 2 == 4
    assert test.object['prop'] == 'val'

    person = Person.new
    person.first_name = "Jeremy"
    person.last_name = "Karmel"
    assert_equal person.initials, "JK"
    assert_equal person.full_name, "Jeremy Karmel"
  end
end
