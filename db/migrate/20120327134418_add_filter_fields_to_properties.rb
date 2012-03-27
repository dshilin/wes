class AddFilterFieldsToProperties < ActiveRecord::Migration
  def self.up
    add_column :properties, :unit, :string
    add_column :properties, :use_in_filter, :boolean, :null => false, :default => false
  end

  def self.down
    remove_column :properties, :unit
    remove_column :properties, :use_in_filter
  end
end

