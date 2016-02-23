class AddPapercliptoPicture < ActiveRecord::Migration
  def change
      add_attachment :pictures, :image
  end
end
