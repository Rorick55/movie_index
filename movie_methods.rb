require 'pg'

def db_connection
  begin
    connection = PG.connect(dbname: 'movies')
    yield(connection)
  ensure
    connection.close
  end
end

def return_page(page)
  return_page = 0
  if page.to_i <= 1
    return_page = 1
  else
    return_page = page.to_i - 1
  end
end

def all_movies(start)
    movies = db_connection do |conn|
    conn.exec("SELECT movies.title, movies.id, movies.year, movies.rating, genres.name AS genre,
      studios.name AS studio, movies.synopsis FROM movies LEFT OUTER JOIN genres ON genres.id = movies.genre_id
      JOIN studios ON studios.id = movies.studio_id ORDER BY movies.title OFFSET #{start} LIMIT 20;")
  end
  movies.to_a
end

def single_movie(id)
  movies = db_connection do |conn|
      conn.exec("SELECT movies.title, movies.id, movies.year, movies.rating, genres.name AS genre,
        studios.name AS studio, movies.synopsis FROM movies LEFT OUTER JOIN genres ON genres.id = movies.genre_id
        LEFT OUTER JOIN studios ON studios.id = movies.studio_id WHERE movies.id = '#{id}';")
  end
  movies.to_a
end

def movie_cast(id)
    movie_actors = db_connection do |conn|
    conn.exec("SELECT movies.title, actors.id, actors.name AS actor, cast_members.character
      FROM cast_members JOIN actors ON cast_members.actor_id = actors.id
      JOIN movies ON movies.id = cast_members.movie_id WHERE movies.id = '#{id}';")
    end
    movie_actors.to_a
end

def all_actors(start)
   actors = db_connection do |conn|
    conn.exec("SELECT name, id FROM actors ORDER BY name OFFSET #{start} LIMIT 20;")
  end
  actors.to_a
end

def single_actor(id)
   actors = db_connection do |conn|
    conn.exec("SELECT actors.name, actors.id, movies.title, movies.id AS movie_id, cast_members.character
      FROM cast_members JOIN actors ON actors.id = cast_members.actor_id JOIN movies
      ON movies.id = cast_members.movie_id WHERE actors.id = '#{id}';")
  end
  actors.to_a
end

def movie_search(search, start)
  movies = db_connection do |conn|
    conn.exec("SELECT title, id FROM movies WHERE title ILIKE '%#{search}%' ORDER BY title OFFSET #{start} LIMIT 20;")
  end
  movies.to_a
end

def actor_search(search, start)
  actors = db_connection do |conn|
    conn.exec("SELECT name, id FROM actors WHERE name ILIKE '%#{search}%' ORDER BY name OFFSET #{start} LIMIT 20;")
  end
  actors.to_a
end




