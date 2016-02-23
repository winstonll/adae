class Picture < ActiveRecord::Base

  belongs_to :item

  validates :image,
    attachment_content_type: { content_type: /\Aimage\/.*\Z/ },
    attachment_size: { less_than: 5.megabytes }

  has_attached_file :image,
    :path => ":rails_root/public/images/:id/:filename",
    :url  => "/images/:id/:filename",
    styles: { small: "400x400", med: "800x800", large: "1200x1200" }

  do_not_validate_attachment_file_type :image

end
