class AddDiscardedAtToReunions < ActiveRecord::Migration[5.2]
  def change
    add_column :reunions, :discarded_at, :datetime
    add_index :reunions, :discarded_at
  end
end
