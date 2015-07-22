require 'spec_helper'
require 'mongoid/enum/configuration'

class User
  include Mongoid::Document
  include Mongoid::Enum

  enum :status, [:awaiting_approval, :approved, :banned]
  enum :roles, [:author, :editor, :admin], :multiple => true, :default => [], :required => false
end

describe Mongoid::Enum do
  let(:klass) { User }
  let(:instance) { User.new }
  let(:alias_name) { :status }
  let(:field_name) { :"_#{alias_name}" }
  let(:values) { [:awaiting_approval, :approved, :banned] }
  let(:multiple_field_name) { :"_roles" }

  describe "field" do
    it "is defined" do
      expect(klass).to have_field(field_name)
    end

    it "uses prefix defined in configuration" do
      old_field_name_prefix = Mongoid::Enum.configuration.field_name_prefix
      Mongoid::Enum.configure do |config|
        config.field_name_prefix = "___"
      end
      UserWithoutPrefix = Class.new do
        include Mongoid::Document
        include Mongoid::Enum

        enum :status, [:awaiting_approval, :approved, :banned]
      end
      expect(UserWithoutPrefix).to have_field "___status"
      Mongoid::Enum.configure do |config|
        config.field_name_prefix = old_field_name_prefix
      end
    end

    it "is aliased" do
      expect(instance).to respond_to alias_name
      expect(instance).to respond_to :"#{alias_name}="
      expect(instance).to respond_to :"#{alias_name}"
    end

    describe "type" do
      context "when multiple" do
        it "is an array" do
          expect(klass).to have_field(multiple_field_name).of_type(Array)
        end

        it "validates using a custom validator" do
          expect(klass).to custom_validate(multiple_field_name).with_validator(Mongoid::Enum::Validators::MultipleValidator)
        end
      end

      context "when not multiple" do
        it "is a symbol" do
          expect(klass).to have_field(field_name).of_type(Symbol)
        end

        it "validates inclusion in values" do
          expect(klass).to validate_inclusion_of(field_name).to_allow(values)
        end
      end
    end
  end

  describe "'required' option" do
    context "when true" do
      let(:instance) { User.new status: nil }
      it "is not valid with nil value" do
        expect(instance).to_not be_valid
      end
    end

    context "when false" do
      let(:instance) { User.new roles: nil }
      it "is valid with nil value" do
        expect(instance).to be_valid
      end
    end
  end

  describe "constant" do
    it "is set to the values" do
      expect(klass::STATUS).to eq values
    end
  end

  describe "accessors" do
    context "when singular" do
      describe "setter" do
        it "accepts strings" do
          instance.status = 'banned'
          expect(instance.status).to eq :banned
        end

        it "accepts symbols" do
          instance.status = :banned
          expect(instance.status).to eq :banned
        end
      end

      describe "{{value}}!" do
        it "sets the value" do
          instance.save
          instance.banned!
          expect(instance.status).to eq :banned
        end
      end

      describe "{{value}}?" do
        context "when {{enum}} == {{value}}" do
          it "returns true" do
            instance.save
            instance.banned!
            expect(instance.banned?).to eq true
          end
        end
        context "when {{enum}} != {{value}}" do
          it "returns false" do
            instance.save
            instance.banned!
            expect(instance.approved?).to eq false
          end
        end
      end
    end

    context "when multiple" do
      describe "setter" do
        it "accepts strings" do
          instance.roles = "author"
          expect(instance.roles).to eq [:author]
        end

        it "accepts symbols" do
          instance.roles = :author
          expect(instance.roles).to eq [:author]
        end

        it "accepts arrays of strings" do
          instance.roles = ['author', 'editor']
          instance.save
          puts instance.errors.full_messages
          instance.reload
          expect(instance.roles).to include(:author)
          expect(instance.roles).to include(:editor)
        end

        it "accepts arrays of symbols"  do
          instance.roles = [:author, :editor]
          expect(instance.roles).to include(:author)
          expect(instance.roles).to include(:editor)
        end
      end

      describe "{{value}}!" do
        context "when field is nil" do
          it "creates an array containing the value" do
            instance.roles = nil
            instance.save
            instance.author!
            expect(instance.roles).to eq [:author]
          end
        end

        context "when field is not nil" do
          it "appends the value" do
            instance.save
            instance.author!
            instance.editor!
            expect(instance.roles).to eq [:author, :editor]
          end
        end
      end

      describe "{{value}}?" do
        context "when {{enum}} contains {{value}}" do
          it "returns true" do
            instance.save
            instance.author!
            instance.editor!
            expect(instance.editor?).to be true
            expect(instance.author?).to be true
          end
        end

        context "when {{enum}} does not contain {{value}}" do
          it "returns false" do
            instance.save
            expect(instance.author?).to be false
          end
        end
      end
    end
  end

  describe "scopes" do
    context "when singular" do
      it "returns the corresponding documents" do
        instance.save
        instance.banned!
        expect(User.banned.to_a).to eq [instance]
      end
    end

    context "when multiple" do
      context "and only one document" do
        it "returns that document" do
          instance.save
          instance.author!
          instance.editor!
          expect(User.author.to_a).to eq [instance]
        end
      end

      context "and more than one document" do
        it "returns all documents with those values" do
          instance.save
          instance.author!
          instance.editor!
          instance2 = klass.create
          instance2.author!
          expect(User.author.to_a).to eq [instance, instance2]
          expect(User.editor.to_a).to eq [instance]
        end
      end
    end
  end

  describe "default values" do
    context "when not specified" do
      it "uses the first value" do
        instance.save
        expect(instance.status).to eq values.first
      end
    end

    context "when specified" do
      it "uses the specified value" do
        instance.save
        expect(instance.roles).to eq []
      end
    end
  end

  describe ".configuration" do
    it "returns Configuration object" do
      expect(Mongoid::Enum.configuration)
          .to be_instance_of Mongoid::Enum::Configuration
    end
    it "returns same object when called multiple times" do
      expect(Mongoid::Enum.configuration).to be Mongoid::Enum.configuration
    end
  end

  describe ".configure" do
    it "yields configuration if block is given" do
      expect { |b| Mongoid::Enum.configure &b }
          .to yield_with_args Mongoid::Enum.configuration
    end
  end
end
