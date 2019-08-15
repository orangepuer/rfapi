require 'rails_helper'

RSpec.describe 'articles routes', type: :routing do
  it 'should be route to articles index' do
    expect(get '/articles').to route_to('articles#index')
  end

  it 'should be route to articles show' do
    expect(get '/articles/1').to route_to('articles#show', id: '1')
  end
end