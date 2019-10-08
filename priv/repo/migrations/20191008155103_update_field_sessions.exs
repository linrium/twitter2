defmodule Twitter2.Repo.Migrations.UpdateFieldSessions do
  use Ecto.Migration

  def change do
    alter table(:sessions) do
      modify :token, :text
    end
  end
end
