class AddAttachmentPhotoToPrices < ActiveRecord::Migration
  def self.up
    change_table :prices do |t|
      t.attachment :photo
    end
  end

  def self.down
    remove_attachment :prices, :photo
  end
end
