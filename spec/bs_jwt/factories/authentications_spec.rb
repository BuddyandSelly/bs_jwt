# frozen_string_literal: true

module BsJwt
  RSpec.describe 'bs_jwt_authentication factory' do
    subject(:authentication) { build(:bs_jwt_authentication) }

    it 'builds an Authentication' do
      expect(authentication).to be_a(Authentication)
    end

    it 'builds a valid authentication with default attributes' do
      expect(authentication).to have_attributes(
        display_name: 'Max Mustermann',
        email: 'test@buddyandselly.com',
        roles: []
      )
    end

    it 'builds an authentication with an Auth0 style user id' do
      expect(authentication.user_id).to match(/\Aauth0\|\h{16}\z/)
    end

    it 'builds an authentication that is not expired yet' do
      expect(authentication).not_to be_expired
      expect(authentication.issued_at).to be < authentication.expires_at
    end
  end
end
