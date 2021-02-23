defmodule Mud.Repo.Migrations.AddTemplateIdToProduct do
  use Ecto.Migration

  def change do
    alter table(:shop_products) do
      add(:template_id, references(:templates, on_delete: :delete_all, type: :binary_id))
    end

    create(index(:shop_products, [:template_id]))
  end
end
