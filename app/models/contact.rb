class Contact
  include ActiveAttr::Model
  attr_accessor :name, :email, :subject, :content

  validates :name, :email, :subject, :content, presence: true
  validates_format_of :email, :with => /\A[-a-z0-9_+\.]+\@([-a-z0-9]+\.)+[a-z0-9]{2,4}\z/i
  validates_length_of :content, :maximum => 500

end