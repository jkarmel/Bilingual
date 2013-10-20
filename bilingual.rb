require 'execjs'


class TestClass
  def initialize
    @context = ExecJS.compile File.open('test.js').read
    @context.eval "objects = []"
    @context.eval("objects.push(new TestClass)")
    @js_index = @context.eval("objects.length") - 1
  end
  def method_missing *args
    prop =  "objects[#{@js_index}].#{args[0]}"
    if @context.eval("typeof #{prop} == 'function'")
      @context.eval "#{prop}()"
    else
      @context.eval prop
    end
  end
end

test = TestClass.new
p test.a
p test.b
p test.fn
