ExUnit.start()

Mox.defmock(Rocket.ConfigProviderMock, for: Rocket.ConfigProvider)
Mox.defmock(Rocket.HTTPClientMock, for: Rocket.HTTPClient)
Mox.defmock(Rocket.ResponseHandlerMock, for: Rocket.Response.ResponseHandler)

Application.put_env(:rocket, :config_provider, Rocket.ConfigProviderMock)
Application.put_env(:rocket, :http_client, Rocket.HTTPClientMock)
Application.put_env(:rocket, :response_handler, Rocket.ResponseHandlerMock)

Application.stop(:rocket)
