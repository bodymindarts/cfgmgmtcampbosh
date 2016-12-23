require 'sinatra'

set :bind, '0.0.0.0'

set :logging, true

alloc_id = ENV['NOMAD_ALLOC_ID']

get '/' do
  "Hello ConfigManagementCamp from nomad - NOMAD_ALLOC_ID: #{alloc_id}"
end
