require 'spec_helper'
require 'ostruct'

describe Mongoid::Enum::Validators::MultipleValidator do
  subject { Mongoid::Enum::Validators::MultipleValidator }
  let(:values) { [:lorem, :ipsum, :dolor, :sit] }
  let(:attribute) { :word }
  let(:record) { OpenStruct.new(:errors => {attribute => []}, attribute => values.first) }
  let(:allow_nil) { false }
  let(:validator) { subject.new(:attributes => attribute, :in => values, :allow_nil => allow_nil) }

  describe ".validate_each" do
    context "when allow_nil: true" do
      let(:allow_nil) { true }

      context "and value is nil" do
        before(:each) { validator.validate_each(record, attribute, nil) }
        it "validates" do
          expect(record.errors[attribute].empty?).to be true
        end
      end

      context "and value is []" do
        before(:each) { validator.validate_each(record, attribute, []) }
        it "validates" do
          expect(record.errors[attribute].empty?).to be true
        end
      end
    end

    context "when allow_nil: false" do
      context "and value is nil" do
        before(:each) { validator.validate_each(record, attribute, nil) }
        it "won't validate" do
          expect(record.errors[attribute].any?).to be true
          expect(record.errors[attribute]).to eq ["is not in #{values.join ", "}"]
        end
      end
      context "and value is []" do
        before(:each) { validator.validate_each(record, attribute, []) }
        it "won't validate" do
          expect(record.errors[attribute].any?).to be true
          expect(record.errors[attribute]).to eq ["is not in #{values.join ", "}"]
        end
      end
    end

    context "when value is included" do
      let(:allow_nil) { rand(2).zero? }
      before(:each) { validator.validate_each(record, attribute, [values.sample]) }
      it "validates" do
        expect(record.errors[attribute].empty?).to be true
      end
    end

    context "when value is not included" do
      let(:allow_nil) { rand(2).zero? }
      before(:each) { validator.validate_each(record, attribute, [:amet]) }
      it "won't validate" do
        expect(record.errors[attribute].any?).to be true
      end
    end

    context "when multiple values included" do
      let(:allow_nil) { rand(2).zero? }
      before(:each) { validator.validate_each(record, attribute, [values.first, values.last]) }
      it "validates" do
        expect(record.errors[attribute].empty?).to be true
      end
    end

    context "when one value is not included "do
      let(:allow_nil) { rand(2).zero? }
      before(:each) { validator.validate_each(record, attribute, [values.first, values.last, :amet]) }
      it "won't validate" do
        expect(record.errors[attribute].any?).to be true
      end
    end
  end
end
