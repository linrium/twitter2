defmodule Twitter2.Repo.Migrations.AddRetweetsCountToTweets do
  use Ecto.Migration

  def up do
    execute """
      CREATE OR REPLACE FUNCTION update_retweets_count()
      RETURNS trigger AS $$
      BEGIN
        IF (TG_OP = 'INSERT') THEN
        UPDATE tweets SET retweet_count = retweet_count + 1
          WHERE id = NEW.original_tweet_id;
        RETURN NEW;
        ELSIF (TG_OP = 'DELETE') THEN
          UPDATE tweets SET retweet_count = retweet_count - 1
            WHERE id = OLD.original_tweet_id;
          RETURN OLD;
        END IF;
        RETURN NULL;
      END
      $$ LANGUAGE plpgsql;
    """

    execute "DROP TRIGGER IF EXISTS update_retweets_count_trg ON tweets;"

    execute """
      CREATE TRIGGER update_retweets_count_trg
      AFTER INSERT OR DELETE
      ON tweets
      FOR EACH ROW
      EXECUTE PROCEDURE update_retweets_count();
    """
  end

  def down do
    alter table(:tweets) do
      remove :retweet_count
    end

    execute "DROP FUNCTION update_retweets_count() CASCADE;"
  end
end
