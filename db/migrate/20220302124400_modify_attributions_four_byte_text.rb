class ModifyVernacularsFourByteText < ActiveRecord::Migration[5.2]
  def up
    Attribution.connection.execute(%{
      ALTER TABLE attributions CONVERT TO CHARACTER SET utf8mb4 COLLATE utf8mb4_bin,
      MODIFY `name` text CHARACTER SET utf8mb4 COLLATE utf8mb4_bin,
      MODIFY `other_info` text CHARACTER SET utf8mb4 COLLATE utf8mb4_bin;
    })
  end

  def down
    Attribution.connection.execute(%{
      ALTER TABLE attributions CONVERT TO CHARACTER SET utf8 COLLATE utf8_general_ci,
      MODIFY `name` text CHARACTER SET utf8 COLLATE utf8_general_ci,
      MODIFY `other_info` text CHARACTER SET utf8 COLLATE utf8_general_ci;
    })
  end
end
