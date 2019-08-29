shared_examples_for 'unauthorized_requests' do
  let(:error) do
    {
        status: "401",
        source: { pointer: "/code" },
        title: "Authentication code is invalid",
        detail: "You must provide valid code in order to exchange it for token."
    }.as_json
  end

  it 'should return 401 status code' do
    subject
    expect(response).to have_http_status 401
  end

  it 'should return proper error body' do
    subject
    expect(json['errors']).to include(error)
  end
end