defmodule Twitter2.Repo.Migrations.AddLikesCountToTweets do
  use Ecto.Migration

  def up do
    execute """
      CREATE OR REPLACE FUNCTION update_likes_count()
      RETURNS trigger AS $$
      BEGIN
        IF (TG_OP = 'INSERT') THEN
        UPDATE tweets SET like_count = like_count + 1
          WHERE id = NEW.tweet_id;
        RETURN NEW;
        ELSIF (TG_OP = 'DELETE') THEN
          UPDATE tweets SET like_count = like_count - 1
            WHERE id = OLD.tweet_id;
          RETURN OLD;
        END IF;
        RETURN NULL;
      END
      $$ LANGUAGE plpgsql;
    """

    execute "DROP TRIGGER IF EXISTS update_likes_count_trg ON likes;"

    execute """
      CREATE TRIGGER update_likes_count_trg
      AFTER INSERT OR DELETE
      ON likes
      FOR EACH ROW
      EXECUTE PROCEDURE update_likes_count();
    """
  end

  def down do
    alter table(:tweets) do
      remove :like_count
    end

    execute "DROP FUNCTION update_likes_count() CASCADE;"
  end
end
