class ImbaGraph < Sinatra::Application
  get '/stats/:username/beers' do
    username = params['username'].downcase
    user = User.find(:username => username)
    return haml(:no_user, :locals => {username: username}) if user.nil? or user.checkins.empty?
    haml(:beers, :locals => {user: user})
  end

  get '/stats/:username/breweries' do
    username = params['username'].downcase
    user = User.find(:username => username)
    return haml(:no_user, :locals => {username: username}) if user.nil? or user.checkins.empty?
    haml(:breweries, :locals => {user: user})
  end

  get '/stats/:username/upload' do
    username = params['username'].downcase
    user = User.find(:username => username)
    return haml(:no_user, :locals => {username: username}) if user.nil? or user.checkins.empty?
    haml(:upload, :locals => {user: user})
  end

  get '/stats/:username/tagged' do
    username = params['username'].downcase
    user = User.find(:username => username)
    return haml(:no_user, :locals => {username: username}) if user.nil? or user.checkins.empty?
    haml(:tagged, :locals => {user: user})
  end

  get '/stats/:username/:year/?' do
    username = params['username'].downcase
    user = User.find(:username => username)
    return haml(:no_user, :locals => {username: username}) if user.nil? or user.checkins.empty?
    year = params['year'].to_i

    haml(:monthly_stats, :locals => {user: user, year: year})
  end

  get '/stats/:username/?' do
    username = params['username'].downcase
    user = User.find(:username => username)
    return haml(:no_user, :locals => {username: username}) if user.nil? or user.checkins.empty?
    haml(:yearly_stats, :locals => {user: user})
  end
end
