require 'spec_helper'

describe Mongoid::Enum::Configuration do
  subject { Mongoid::Enum::Configuration.new }

  describe "field_name_prefix" do
    it "has '_' as default value" do
      expect(subject.field_name_prefix).to eq "_"
    end
  end

  describe "scope_method_prefix" do
    it "has '' as default value" do
      expect(subject.scope_method_prefix).to eq ''
    end
  end
end
