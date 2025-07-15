ExUnit.start()

# Configure ExVCR cassette directory and filter sensitive request headers
ExVCR.Config.cassette_library_dir("test/fixtures/vcr_cassettes")
ExVCR.Config.filter_request_headers("Authorization")
