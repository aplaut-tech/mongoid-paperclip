require "mongoid"
require "mongoid-paperclip"

ENV["MONGOID_ENV"] = "test"
Mongoid.load!("./spec/config/mongoid.yml")

RSpec.configure do |config|
  config.before(:each) do
    Mongoid.purge!
  end
end

# Mock Rails itself so Paperclip can write the attachments to a directory.
class Rails
  def self.root
    __dir__
  end
end

class User
  include Mongoid::Document
  include Mongoid::Paperclip

  has_mongoid_attached_file :avatar
  validates_attachment_content_type :avatar, content_type: /\Aimage\/.*\Z/
end

class Photo
  include Mongoid::Document
  include Mongoid::Paperclip

  embedded_in :post
  has_mongoid_attached_file :content
  validates_attachment_content_type :content, content_type: /\Aimage\/.*\Z/
end

class Post
  include Mongoid::Document

  embeds_many :photos, cascade_callbacks: true
end

class MultipleAttachments
  include Mongoid::Document
  include Mongoid::Paperclip

  has_mongoid_attached_file :avatar
  validates_attachment_content_type :avatar, content_type: /\Aimage\/.*\Z/

  has_mongoid_attached_file :icon
  validates_attachment_content_type :icon, content_type: /\Aimage\/.*\Z/
end

class NoFingerprint
  include Mongoid::Document
  include Mongoid::Paperclip

  has_mongoid_attached_file :avatar, disable_fingerprint: true
  validates_attachment_content_type :avatar, content_type: /\Aimage\/.*\Z/
end
