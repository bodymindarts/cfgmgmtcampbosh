require 'sinatra'

set :bind, '0.0.0.0'

set :logging, true

get '/' do
  'Hello ConfigManagementCamp from nomad!'
end
