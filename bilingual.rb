require 'execjs'
require 'active_support/core_ext'


class TestClass
  def initialize
    @context = ExecJS.compile File.open('test.js').read
    @context.eval "objects = []"
    @context.eval("objects.push(new TestClass)")
    @js_index = @context.eval("objects.length") - 1
  end
  def method_missing *args
    method_name = args[0].to_s.camelize(:lower)
    prop =  "objects[#{@js_index}].#{method_name}"
    if @context.eval("typeof #{prop} == 'function'")
      @context.eval "#{prop}()"
    else
      @context.eval prop
    end
  end
  def call_js_from_ruby
    from_js + " and from ruby land"
  end
end

test = TestClass.new
p test.a
p test.call_js_from_ruby
