class CreateReunions < ActiveRecord::Migration[5.2]
  def change
    create_table :reunions do |t|
      t.date :start_date
      t.date :end_date
      t.string :name
      t.text :description
      t.string :location

      t.timestamps
    end
  end
end
