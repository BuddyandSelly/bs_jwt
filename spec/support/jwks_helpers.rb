# frozen_string_literal: true

##
# Helpers around the JWT fixtures and the Auth0 JWKS endpoint they are signed
# with.
module JwksHelpers
  AUTH0_DOMAIN = 'reverse-retail.eu.auth0.com'
  JWKS_URL = "https://#{AUTH0_DOMAIN}/.well-known/jwks.json"

  def load_fixture(name)
    File.read(File.join(__dir__, '..', 'fixtures', name))
  end

  # Points `BsJwt` at the Auth0 domain the fixtures were issued by and stubs
  # its JWKS endpoint.
  def stub_auth0_jwks(domain: AUTH0_DOMAIN, url: JWKS_URL, status: 200, body: nil)
    BsJwt.auth0_domain = domain
    stub_request(:get, url).to_return(status: status, body: body || load_fixture('jwks.json'))
  end
end
