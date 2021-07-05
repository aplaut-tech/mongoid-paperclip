require "spec_helper"

RSpec.describe Mongoid::Paperclip, type: :unit do
  def read_image_fixture
    File.new("spec/support/avatar.png", "rb")
  end

  describe "avatar" do
    let(:user) { User.create }
    before do
      user.update avatar: read_image_fixture
    end

    it "stores file_name" do
      expect(user.avatar_file_name).to eq("avatar.png")
    end

    it "stores content_type" do
      expect(user.avatar_content_type).to eq("image/png")
    end

    it "stores file_size" do
      expect(user.avatar_file_size).to eq(357)
    end

    it "stores updated_at" do
      expect(user.avatar_updated_at).to be_present
    end

    it "stores fingerprint" do
      expect(user.avatar_fingerprint).to eq("2584a801e588b3fcf4aa074efff77e30")
    end
  end

  describe "multiple attachments" do
    let(:user) { MultipleAttachments.create }

    it "works" do
      user.update avatar: read_image_fixture, icon: read_image_fixture
      expect(user.avatar_file_name).to eq("avatar.png")
      expect(user.icon_file_name).to eq("avatar.png")
    end
  end

  describe "disable fingerprint" do
    let(:user) { NoFingerprint.create }

    before do
      user.update avatar: read_image_fixture
    end

    it "does not store a fingerprint" do
      expect(user.attributes).to_not include("fingerprint")
    end
  end

  describe "embedded documents" do
    let(:post) { Post.create }

    specify do
      post.photos.build(content: read_image_fixture)
      post.save!
      expect(post).to be_valid
      expect { post.reload.photos.first.avatar_file_name }
    end

    specify {
      post.photos.create!(content: read_image_fixture)
      post.reload
      expect(post.photos.count).to eq(1)
      post.write_attributes(photos: [])
      expect(post.save).to eq(true)
      expect(post.photos.count).to eq(0)
    }
  end
end
