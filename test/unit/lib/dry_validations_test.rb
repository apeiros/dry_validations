require 'test_helper'
require 'dry_validations'


class DryValidationsTest < Test::Unit::TestCase
  def setup
    @model = Object.new
    @model.extend DryValidations::DSL
  end

  def test_model_receives_validation_methods
    mock(@model).validates_presence_of :foobar

    @model.validates do
      presence_of :foobar
    end
  end

  def test_model_receives_validation_methods_with_options
    mock(@model).validates_presence_of :foobar, :if => :something

    @model.validates do
      presence_of :foobar, :if => :something
    end
  end

  def test_model_receives_validation_methods_with_shared_options
    mock(@model).validates_presence_of :foobar, :if => :something

    @model.validates :if => :something do
      presence_of :foobar
    end
  end

  def test_specific_options_override_shared_options
    mock(@model).validates_presence_of :foobar, :if => :something_else

    @model.validates :if => :something do
      presence_of :foobar, :if => :something_else
    end
  end

  def test_nested_shared_options
    mock(@model).validates_presence_of :foobar, :if => :something, :and => :whatever

    @model.validates :if => :something do
      with_options :and => :whatever do
        presence_of :foobar
      end
    end
  end
end
