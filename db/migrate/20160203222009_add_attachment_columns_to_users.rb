class AddAttachmentColumnsToUsers < ActiveRecord::Migration
  def change
    add_attachment :items, :images
  end
end
