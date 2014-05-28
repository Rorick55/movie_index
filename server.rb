require 'sinatra'
require 'pg'
require 'pry'

def db_connection
  begin
    connection = PG.connect(dbname: 'movies')

    yield(connection)

  ensure
    connection.close
  end
end

def get_20_movies (page_number, all_movies)
  index = (page_number -1) * 20
  all_movies[index..index + 19]
end

get '/' do

  erb :index
end

get '/movies' do
  @page_number = params[:page] || 1
  if @page_number.to_i <= 1
    @return_page = 1
  else
    @return_page = @page_number.to_i - 1
  end
  movies = db_connection do |conn|
    conn.exec('SELECT title, id FROM movies;')
  end
  @movies = get_20_movies(@page_number.to_i, movies.to_a)
  @page_number = @page_number.to_i + 1

  erb :'movies/index'
end

get '/:title/:id' do
  movies = db_connection do |conn|
    conn.exec('SELECT movies.title, movies.id, movies.year, movies.rating, genres.name AS genre, studios.name AS studio, movies.synopsis FROM movies LEFT OUTER JOIN genres ON genres.id = movies.genre_id JOIN studios ON studios.id = movies.studio_id;')
    end
  actors = db_connection do |conn|
    conn.exec('SELECT movies.title, actors.name AS actor, cast_members.character FROM movies JOIN actors ON movies.actor_id = actors.id JOIN cast_members ON actors.id = cast_members.actor_id;')
    end
  @actors = actors.to_a
  @movies = movies.to_a
  @movies.find do |each_hash|
    each_hash[:title] == params[:title]
    each_hash[:id] == params[:id]
  end

  erb :'movies/show'
end

get 'actors' do
    @page_number = params[:page] || 1
  if @page_number.to_i <= 1
    @return_page = 1
  else
    @return_page = @page_number.to_i - 1
  end
  movies = db_connection do |conn|
    conn.exec('SELECT title, id FROM movies;')
  end
  @movies = get_20_movies(@page_number.to_i, movies.to_a)
  @page_number = @page_number.to_i + 1

  erb :'movies/index'
end

get '/search' do

  erb :search
end

