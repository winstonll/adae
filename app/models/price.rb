class Price < ActiveRecord::Base
	belongs_to :item

	has_attached_file :photo, styles: { medium: "300x300>", thumb: "100x100>" },
			:default_url => "/paperclip/default/default_food.png"
  validates_attachment_content_type :photo, content_type: /\Aimage\/.*\Z/
end
