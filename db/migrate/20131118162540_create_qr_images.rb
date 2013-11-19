class CreateQrImages < ActiveRecord::Migration
  def change
    create_table :qr_images do |t|
    	t.string 	:qrimageable_type
     	t.integer 	:qrimageable_id
      	t.string 	:picture
      	t.integer 	:size

      	t.timestamps
    end
  end
end


