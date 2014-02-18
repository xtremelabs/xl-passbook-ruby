require "spec_helper"

describe Passbook do

  class DummyPass; end

  let(:dummy) { DummyPass.new }

  context "#object_matches_pass_config:" do

    context "when object responds to :pass_id" do

      before(:each) { DummyPass.any_instance.stub(:pass_id).and_return "test_pass" }

      it "returns true when object.pass_id == specified pass_id" do
        expect(Passbook.object_matches_pass_config dummy, "test_pass", {}).to be_true
      end

      it "returns false when object is no match" do
        expect(Passbook.object_matches_pass_config dummy, "new_pass", {}).to be_false
      end

    end

    context "when object doesn't respond to :pass_id" do

      let(:pass_config) { { "class" => "DummyPass" } }

      it "returns true when object class name == class name in pass config" do
        expect(Passbook.object_matches_pass_config dummy, "random_pass", pass_config).to be_true
      end

      it "returns false when object is no match" do
        pass_config["class"] = "NotAMatch"
        expect(Passbook.object_matches_pass_config dummy, "random_pass", pass_config).to be_false
      end

    end

  end

  context "#find_pass_id_for:" do

    before do
      Passbook::Config.instance.stub(:pass_config).and_return(
        "test_pass1" => {
            "cert_path"     => "some/random/path1",
            "cert_password" => SecureRandom.hex(10),
            "template_path" => "another/random/path1",
            "class"         => "DummyPass"
        },
        "test_pass2" => {
            "cert_path"     => "some/random/path2",
            "cert_password" => SecureRandom.hex(10),
            "template_path" => "another/random/path3",
            "class"         => "DummyPass"
        },
        "test_pass3" => {
            "cert_path"     => "some/random/path3",
            "cert_password" => SecureRandom.hex(10),
            "template_path" => "another/random/path3",
            "class"         => "DummyPass"
        }
      )
    end

    context "when object responds to :pass_id" do

      it "returns a String when object.pass_id == specified pass_id" do
        DummyPass.any_instance.stub(:pass_id).and_return "test_pass2"
        expect(Passbook.find_pass_id_for dummy).to eq("test_pass2")
      end

      it "returns Nil when object is no match" do
        DummyPass.any_instance.stub(:pass_id).and_return "test_pass9"
        expect(Passbook.find_pass_id_for dummy).to be_nil
      end

    end

    context "when object doesn't respond to :pass_id" do

      it "returns a String when object class name == class name in pass config" do
        expect(Passbook.find_pass_id_for dummy).to eq("test_pass1")
      end

      it "returns Nil when object is no match" do
        dummy.stub_chain(:class, :to_s).and_return "FakeName"
        expect(Passbook.find_pass_id_for dummy).to be_nil
      end

    end

  end


end
