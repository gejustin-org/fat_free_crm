class CreateAddresses < ActiveRecord::Migration
  def self.up
    create_table :addresses do |t|
      t.string :street1
      t.string :street2
      t.string :city
      t.string :state
      t.string :zipcode
      t.string :country, :limit => 2 
      t.string :full_address
      t.string :address_type
 
      t.references :addressable, :polymorphic => true
 
      t.timestamps
      t.datetime :deleted_at
    end

    add_index :addresses, [ :addressable_id, :addressable_type ]

    # Migrate data from assets to Address table into full_address blob
    Contact.find(:all).each do |asset|
      Address.create(:street1 => asset.address, :full_address => asset.address, :address_type => "Business", :addressable => asset)
    end
    
    Account.find(:all).each do |asset|
      Address.create(:street1 => asset.billing_address, :full_address => asset.billing_address, :address_type => "Billing", :addressable => asset)
      Address.create(:street1 => asset.shipping_address, :full_address => asset.shipping_address, :address_type => "Shipping", :addressable => asset)
    end    

    Lead.find(:all).each do |asset|
      Address.create(:street1 => asset.address, :full_address => asset.address, :address_type => "Business", :addressable => asset)
    end

    # Remove addresses columns from assets allready migrated
    remove_column(:contacts, :address)
    remove_column(:accounts, :billing_address)
    remove_column(:accounts, :shipping_address)
    remove_column(:leads,    :address)

  end
 
  def self.down
    drop_table :addresses
  end
end
