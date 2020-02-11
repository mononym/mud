defmodule Mud.Repo.Migrations.AddDescriptionComponentIndexes do
  use Ecto.Migration

  def up do
    execute(
      "CREATE INDEX glance_description_tsv_idx ON description_components USING GIN (to_tsvector('english', glance_description))"
    )

    execute(
      "CREATE INDEX look_description_tsv_idx ON description_components USING GIN (to_tsvector('english', look_description))"
    )

    execute(
      "CREATE INDEX examine_description_tsv_idx ON description_components USING GIN (to_tsvector('english', examine_description))"
    )

    execute("""
      CREATE TRIGGER description_component_glance_tsvector_update BEFORE INSERT OR UPDATE
        ON description_components FOR EACH ROW EXECUTE PROCEDURE
        tsvector_update_trigger(
          glance_description_tsv, 'pg_catalog.english', glance_description
        );
    """)

    execute("""
      CREATE TRIGGER description_component_look_tsvector_update BEFORE INSERT OR UPDATE
        ON description_components FOR EACH ROW EXECUTE PROCEDURE
        tsvector_update_trigger(
          look_description_tsv, 'pg_catalog.english', look_description
        );
    """)

    execute("""
      CREATE TRIGGER description_component_examine_tsvector_update BEFORE INSERT OR UPDATE
        ON description_components FOR EACH ROW EXECUTE PROCEDURE
        tsvector_update_trigger(
          examine_description_tsv, 'pg_catalog.english', examine_description
        );
    """)
  end

  def down do
    execute("DROP INDEX glance_description_tsv_idx")
    execute("DROP INDEX look_description_tsv_idx")
    execute("DROP INDEX examine_description_tsv_idx")
  end
end
