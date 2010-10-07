# DryValidations provides a simple DSL to dry up your validations.
# Example:
#   # Old validations
#   class Foo < ActiveRecord::Base
#     validates_presence_of :foo
#     validates_presence_of :bar
#     validates_length_of :bla1, :minimum => 1, :maximum => 200
#     validates_length_of :bla2, :minimum => 1, :maximum => 200
#     validates_length_of :bla3, :minimum => 1, :maximum => 300
#     validates_length_of :bla4, :minimum => 1, :maximum => 200
#     validates_length_of :blu1, :minimum => 1, :maximum => 200, :if => :has_blu?
#     validates_length_of :blu2, :minimum => 1, :maximum => 200, :if => :has_blu?
#     validates_length_of :blu3, :minimum => 1, :maximum => 300, :if => :has_blu?
#     validates_length_of :blu4, :minimum => 1, :maximum => 200, :if => :has_blu?
#   end
#
#   # Converted to
#   class Foo < ActiveRecord::Base
#     validates do
#       presence_of :foo
#       presence_of :bar
#
#       with_options :minimum => 1, :maximum => 200 do
#         length_of :bla1 # minimum and maximum are "inherited" from `with_options`
#         length_of :bla2
#         length_of :bla3, :maximum => 300 # local maximum overrides the inherited one
#         length_of :bla4
#
#         with_options :if => :has_blu? do
#           length_of :blu1 # nested `with_options` are merged
#           length_of :blu2
#           length_of :blu3, :maximum => 300
#           length_of :blu4
#         end
#       end
#     end
#   end
module DryValidations
  # ActiveRecord::Base becomes extended by this module, providing
  # ActiveRecord::Base::validates.
  module DSL

    # All methods invoked within the block (except for 'with_options') are
    # prefixed with 'validates_' and delegated to the model, e.g.
    #   presence_of :something
    # becomes
    #   validates_presence_of :something
    #
    def validates(options=nil, &block)
      DryValidations::Proxy.new(self, options, &block)
    end
  end

  # Internal class handling the delegation of the method invocations
  class Proxy # :nodoc:
    def initialize(model, options, &validations)
      @model   = model
      @options = options
      instance_eval(&validations)
    end

    # All subsequent method calls receive these additional options
    def with_options(options, &validations)
      nested_options = @options ? @options.merge(options) : options
      DryValidations::Proxy.new(@model, nested_options, &validations)
    end

    def method_missing(name, *args, &block)
      if @options then
        if args.last.is_a?(Hash) then
          args[-1] = @options.merge(args[-1])
        else
          args << @options
        end
      end
      @model.send("validates_#{name}", *args, &block)
    end
  end
end
