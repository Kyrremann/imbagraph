Sequel.migration do
  change do
    create_table(:tagged) do
      primary_key :id
      Int :user_id, null: false
      Int :tagged_user_id, null: false
      Int :checkin_id, null: false
    end

    alter_table(:checkins) do
      add_column :parsed_tagged, :bool, default: false
    end
  end
end
