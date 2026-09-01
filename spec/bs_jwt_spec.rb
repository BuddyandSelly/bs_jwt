# frozen_string_literal: true

RSpec.describe BsJwt do
  it 'has a version number' do
    expect(BsJwt::VERSION).not_to be nil
  end

  describe '#verify_and_decode_auth0_hash!/1' do
    context 'called with an Auth0 Hash with valid structure' do
      it 'calls #verify_and_decode!/1 with the JWT token' do
        expect(described_class).to receive(:verify_and_decode!).with('Jan.Pawel.Drugi')
        described_class.verify_and_decode_auth0_hash!('credentials' => { 'id_token' => 'Jan.Pawel.Drugi' })
      end
    end

    context 'called with nil' do
      it 'raises an ArgumentError' do
        allow(described_class).to receive(:verify_and_decode!)
        expect { described_class.verify_and_decode_auth0_hash!(nil) }.to raise_exception(ArgumentError)
      end
    end

    context 'called with invalid Hash' do
      it 'calls #verify_and_decode!/1 with nil' do
        expect(described_class).to receive(:verify_and_decode!).with(nil)
        described_class.verify_and_decode_auth0_hash!('credentials' => nil)
      end
    end
  end

  describe '#verify_and_decode_auth0_hash/1' do
    context 'called with an Auth0 Hash with valid structure' do
      it 'calls #verify_and_decode/1 with the JWT token' do
        expect(described_class).to receive(:verify_and_decode).with('Jan.Pawel.Drugi')
        described_class.verify_and_decode_auth0_hash('credentials' => { 'id_token' => 'Jan.Pawel.Drugi' })
      end
    end

    context 'called with nil' do
      it 'raises an ArgumentError' do
        allow(described_class).to receive(:verify_and_decode)
        expect { described_class.verify_and_decode_auth0_hash(nil) }.to raise_exception(ArgumentError)
      end
    end

    context 'called with invalid Hash' do
      it 'calls #verify_and_decode/1 with nil' do
        expect(described_class).to receive(:verify_and_decode).with(nil)
        described_class.verify_and_decode_auth0_hash('credentials' => nil)
      end
    end
  end

  describe '#verify_and_decode' do
    context 'called with a valid JWT' do
      it 'returns an Authentication object with the right attributes' do
        stub_auth0_jwks
        jwt = load_fixture('valid_jwt')

        actual = described_class.verify_and_decode(jwt)

        expect(actual).to have_attributes(
          display_name: 'Jannik Graw',
          expires_at: Time.at(1529694629),
          issued_at: Time.at(1529658629),
          token: jwt,
          email: 'j.graw@buddyandselly.com',
          user_id: 'auth0|4e3a2fef71b571961c1b229',
          roles: ['admin']
        )
      end
    end

    it 'returns nil for JWT with invalid signature' do
      stub_auth0_jwks
      jwt = load_fixture('jwt_with_invalid_signature')
      expect(described_class.verify_and_decode(jwt)).to be_nil
    end

    it 'returns nil for JWT signed by wrong authority' do
      stub_auth0_jwks
      jwt = load_fixture('jwt_signed_by_wrong_authority')
      expect(described_class.verify_and_decode(jwt)).to be_nil
    end

    it 'returns nil when called with nil' do
      expect(described_class.verify_and_decode(nil)).to be_nil
    end
  end

  describe '#verify_and_decode!' do
    context 'called with a valid JWT' do
      it 'returns an Authentication object with the right attributes' do
        stub_auth0_jwks
        jwt = load_fixture('valid_jwt')

        actual = described_class.verify_and_decode!(jwt)

        expect(actual).to have_attributes(
          display_name: 'Jannik Graw',
          expires_at: Time.at(1529694629),
          token: jwt,
          email: 'j.graw@buddyandselly.com',
          user_id: 'auth0|4e3a2fef71b571961c1b229',
          roles: ['admin']
        )
      end
    end

    it 'raises an InvalidToken error for JWT with invalid signature' do
      stub_auth0_jwks
      jwt = load_fixture('jwt_with_invalid_signature')

      expect { described_class.verify_and_decode!(jwt) }.to raise_exception(BsJwt::InvalidToken)
    end

    it 'raises an InvalidToken error for JWT signed by wrong authority' do
      stub_auth0_jwks
      jwt = load_fixture('jwt_signed_by_wrong_authority')

      expect { described_class.verify_and_decode!(jwt) }.to raise_exception(BsJwt::InvalidToken)
    end

    it 'raises an InvalidToken error when called with nil' do
      expect { described_class.verify_and_decode!(nil) }.to raise_exception(BsJwt::InvalidToken)
    end
  end

  describe '#jwks_key' do
    it 'fetches the key set from the configured Auth0 domain' do
      request = stub_auth0_jwks

      expect(described_class.jwks_key).to be_a(JSON::JWK::Set)
      expect(request).to have_been_requested
    end

    it 'fetches the key set only once' do
      request = stub_auth0_jwks

      2.times { described_class.jwks_key }

      expect(request).to have_been_requested.once
    end

    context 'called with a domain that already contains a scheme' do
      it 'does not prepend https for an https domain' do
        request = stub_auth0_jwks(domain: "https://#{JwksHelpers::AUTH0_DOMAIN}")

        described_class.jwks_key

        expect(request).to have_been_requested
      end

      it 'does not prepend https for an http domain' do
        domain = "http://#{JwksHelpers::AUTH0_DOMAIN}"
        request = stub_auth0_jwks(domain: domain, url: "#{domain}#{BsJwt::DEFAULT_ENDPOINT}")

        described_class.jwks_key

        expect(request).to have_been_requested
      end
    end

    context 'called without a configured auth0_domain' do
      it 'raises a ConfigMissing error when it is nil' do
        described_class.auth0_domain = nil

        expect { described_class.jwks_key }
          .to raise_exception(BsJwt::ConfigMissing, 'auth0_domain is not set')
      end

      it 'raises a ConfigMissing error when it is empty' do
        described_class.auth0_domain = ''

        expect { described_class.jwks_key }
          .to raise_exception(BsJwt::ConfigMissing, 'auth0_domain is not set')
      end

      it 'raises a ConfigMissing error when it cannot be checked for emptiness' do
        described_class.auth0_domain = 42

        expect { described_class.jwks_key }
          .to raise_exception(BsJwt::ConfigMissing, 'auth0_domain is not set')
      end
    end

    context 'called when the JWKS endpoint does not answer successfully' do
      it 'raises a NetworkError' do
        stub_auth0_jwks(status: 500, body: 'Internal Server Error')

        expect { described_class.jwks_key }
          .to raise_exception(BsJwt::NetworkError, 'Fetching JWKS key failed')
      end
    end
  end
end
