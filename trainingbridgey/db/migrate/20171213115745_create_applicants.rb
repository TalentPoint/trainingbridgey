class CreateApplicants < ActiveRecord::Migration[5.0]
  def self.up
    create_table :applicants do |t|
      t.string :bridger
      t.string :status
      t.date :date
      t.string :jobboard
      t.timestamps
    end
  end

  def self.down
    drop_table :applicants
  end
end
