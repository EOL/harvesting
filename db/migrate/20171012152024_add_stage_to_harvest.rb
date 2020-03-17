class AddStageToHarvest < ActiveRecord::Migration[4.2]
  def change
    add_column :harvests, :stage, :integer,
      comment: 'enum: all of the method names called in ResourceHarvester#start (q.v.)'
  end
end
