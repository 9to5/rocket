ExUnit.start()

# Configure Mox for HTTP client mocking
Mox.defmock(Rocket.HTTPClientMock, for: Rocket.HTTPClient)
Application.put_env(:rocket, :http_client, Rocket.HTTPClientMock)
