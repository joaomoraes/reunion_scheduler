class AddStateToReunions < ActiveRecord::Migration[5.2]
  def up
    execute <<-SQL
      CREATE TYPE reunion_states AS ENUM ('published', 'draft');
    SQL
    add_column :reunions, :state, :reunion_states, default: 'draft'
    add_index :reunions, :state
  end
  def down
    remove_index :reunions, :state
    remove_column :reunions, :state
    execute <<-SQL
      DROP TYPE reunion_states;
    SQL
  end
end
