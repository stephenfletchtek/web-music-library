require "spec_helper"
require "rack/test"
require_relative '../../app'

def reset_albums_table
  seed_sql = File.read('spec/seeds/albums_seeds.sql')
  connection = PG.connect({ host: '127.0.0.1', dbname: 'music_library_test' })
  connection.exec(seed_sql)
end

describe Application do
  before(:each) do 
    reset_albums_table
  end
  # This is so we can use rack-test helper methods.
  include Rack::Test::Methods

  # We need to declare the `app` value by instantiating the Application
  # class so our tests work.
  let(:app) { Application.new }

  context "homepage" do
    it "shows home page with links" do
      response = get('/')
      expect(response.status).to eq(200)
      expect(response.body).to include('<h1>Music Library - Run by Duck Power</h1>')
      expect(response.body).to include('<a href="/albums">List of albums</a>')
      expect(response.body).to include('<a href="/artists">List of artists</a>')
    end
  end

  context "GET /albums" do
    it "gets all albums and displays in html" do
      response = get('/albums')
      expect(response.status).to eq(200)
      expect(response.body).to include('<a href="/albums/1">Doolittle</a>')
      expect(response.body).to include('<a href="/albums/2">Surfer Rosa</a>')
      expect(response.body).to include('<a href="/albums/3">Waterloo</a>')
      expect(response.body).to include('<a href="/albums/4">Super Trouper</a>')
      expect(response.body).to include('<a href="/albums/5">Bossanova</a>')
      expect(response.body).to include('<a href="/albums/6">Lover</a>')
      expect(response.body).to include('<a href="/albums/7">Folklore</a>')
      expect(response.body).to include('<a href="/albums/8">I Put a Spell on You</a>')
      expect(response.body).to include('<a href="/albums/9">Baltimore</a>')
      expect(response.body).to include('<a href="/albums/10">Here Comes the Sun</a>')
      expect(response.body).to include('<a href="/albums/11">Fodder on My Wings</a>')
      expect(response.body).to include('<a href="/albums/12">Ring Ring</a>')
    end
  end

  context "GET /artists" do
    it "returns 200 OK and a list of artists with links" do
      response = get('/artists')
      expect(response.status).to eq(200)
      expect(response.body).to include('<a href="/artists/1">Pixies</a>')
      expect(response.body).to include('<a href="/artists/2">ABBA</a>')
      expect(response.body).to include('<a href="/artists/3">Taylor Swift</a>')
      expect(response.body).to include('<a href="/artists/4">Nina Simone</a>')
      expect(response.body).to include('<a href="/artists/5">Kiasmos</a>')
    end
  end

  context "GET /albums/:id" do
    it "returns 200 OK and displays album/1 retrieved" do
      response = get('/albums/1')
      expect(response.status).to eq(200)
      expect(response.body).to include('<h1>Doolittle</h1>')
      expect(response.body).to include('Release year: 1989')
      expect(response.body).to include('Artist: Pixies')
    end

    it "returns 200 OK and displays album/1 retrieved" do
      response = get('/albums/2')
      expect(response.status).to eq(200)
      expect(response.body).to include('<h1>Surfer Rosa</h1>')
      expect(response.body).to include('Release year: 1988')
      expect(response.body).to include('Artist: Pixies')
    end
  end

  context "GET /artists/:id" do
    it "returns 200 OK and displays artist/1 retreived" do
      response = get('/artists/1')
      expect(response.status).to eq (200)
      expect(response.body).to include('<h1>Pixies</h1>')
      expect(response.body).to include('Genre: Rock')
    end

    it "returns 200 OK and displays artist/2 retreived" do
      response = get('/artists/2')
      expect(response.status).to eq (200)
      expect(response.body).to include('<h1>ABBA</h1>')
      expect(response.body).to include('Genre: Pop')
    end
  end

  context "Get /albums/new" do
    it "gets form and returns 200 OK" do
      response = get('/albums/new')
      expect(response.status).to eq(200)
      expect(response.body).to include('<form action="/albums" method="POST">')
      expect(response.body).to include('<input type="text" name="title">')
      expect(response.body).to include('<option value=1>Pixies</option>')
    end
  end

  context "Post /albums" do
    it 'returns 200 OK, checks non-html content and confirms album added to database' do
      response = post('/albums', title: 'Voyage', release_year: '2022', artist_id: '2')
      expect(response.status).to eq(200)
      expect(response.body).to include('Voyage')
      response = get('/albums')
      expect(response.body).to include('Voyage')
    end

    it "creates album and shows confirmation page" do
      response = post('/albums', title: 'Big Bad Wolf', release_year: '2011', artist_id: '6')
      expect(response.status).to eq (200)
      expect(response.body).to include('<h1>Album added: Big Bad Wolf</h1>')
    end

    it "should validate album parameters" do
      response = post('/albums', wrong_label: 'OK Computer', wrong_2: 1989, wrong_3: 4)
      expect(response.status).to eq(400)
    end
  end

  context "Get /artists/new" do
    it "gets form and returns 200 OK" do
      response = get('/artists/new')
      expect(response.status).to eq(200)
      expect(response.body).to include('<form action="/artists" method="POST">')
      expect(response.body).to include('<label>Artist Name: </label>')
      expect(response.body).to include('<input type="text" name="name">')
      expect(response.body).to include('<label>Genre: </label>')
      expect(response.body).to include('<input type="text" name="genre">')
      expect(response.body).to include('<input type="submit" value="submit">')
    end
  end
    
  context "POST /artists" do
    it "returns 200 OK, checks non-html content, and confirms artist added to database" do
      response = post('/artists', name: 'Wild nothing', genre: 'Indie')
      expect(response.status).to eq(200)
      expect(response.body).to include('Wild nothing')
      response = get('/artists')
      expect(response.body).to include('Wild nothing')
    end

    it "creates artist and shows confirmation page" do
      response = post('/artists', name: 'Duck Sauce', genre: 'Electronic')
      expect(response.status).to eq(200)
      expect(response.body).to include('<h1>Artist added: Duck Sauce</h1>')
    end

    it "should validate artist parameters" do
      response = post('/artists', wrong_name: 'Duck Sauce', wrong_genre: 'Electronic')
      expect(response.status).to eq(400)
    end
  end
end
