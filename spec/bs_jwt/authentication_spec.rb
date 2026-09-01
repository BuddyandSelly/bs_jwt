# frozen_string_literal: true

module BsJwt
  RSpec.describe Authentication do
    describe '.new' do
      it 'works with an attributes hash with string keys' do
        attributes = { 'user_id': '123', 'email': 'test@test.de' }

        authentication = Authentication.new(attributes)

        expect(authentication).to have_attributes(attributes)
      end

      it 'works with an attributes hash with symbol keys' do
        attributes = { user_id: '123', email: 'test@test.de' }

        authentication = Authentication.new(attributes)

        expect(authentication).to have_attributes(attributes)
      end

      it 'works without any attributes' do
        authentication = Authentication.new

        expect(authentication).to have_attributes(
          roles: [],
          display_name: nil,
          token: nil,
          expires_at: nil,
          email: nil,
          user_id: nil,
          issued_at: nil
        )
      end

      it 'keeps the given roles' do
        authentication = Authentication.new(roles: %w[admin])

        expect(authentication.roles).to eq(%w[admin])
      end
    end

    describe '.from_jwt_payload' do
      let(:payload) do
        {
          'https://buddy.buddyandselly.com/roles' => %w[admin],
          'nickname' => 'Jannik Graw',
          'name' => 'j.graw@buddyandselly.com',
          'sub' => 'auth0|4e3a2fef71b571961c1b229',
          'iat' => 1529658629,
          'exp' => 1529694629
        }
      end

      it 'maps the JWT payload onto the attributes' do
        authentication = described_class.from_jwt_payload(payload, 'the.jwt.token')

        expect(authentication).to have_attributes(
          roles: %w[admin],
          display_name: 'Jannik Graw',
          token: 'the.jwt.token',
          expires_at: Time.at(1529694629),
          email: 'j.graw@buddyandselly.com',
          user_id: 'auth0|4e3a2fef71b571961c1b229',
          issued_at: Time.at(1529658629)
        )
      end

      it 'defaults the roles to an empty array when the claim is missing' do
        authentication = described_class.from_jwt_payload(
          payload.except('https://buddy.buddyandselly.com/roles'), 'the.jwt.token'
        )

        expect(authentication.roles).to eq([])
      end
    end

    describe '#has_role?' do
      subject { build(:bs_jwt_authentication, roles: %w[content_mgr admin]) }

      it { expect(subject.has_role?('admin')).to be true }
      it { expect(subject.has_role?('sales_mgr')).to be false }
    end

    describe '#expired?' do
      context 'when expires_at is in the future' do
        let(:authentication) { build(:bs_jwt_authentication, expires_at: 2137.seconds.from_now) }

        it { expect(authentication).not_to be_expired }
      end

      context 'when expires_at is in the past' do
        let(:authentication) { build(:bs_jwt_authentication, expires_at: 2137.seconds.ago) }

        it { expect(authentication).to be_expired }
      end
    end

    describe '#to_h' do
      it 'returns a hash with all attributes of the instance' do
        authentication = build(:bs_jwt_authentication)

        hash = authentication.to_h

        expect(hash).to eq(
          'roles' => authentication.roles,
          'display_name' => authentication.display_name,
          'token' => authentication.token,
          'expires_at' => authentication.expires_at,
          'email' => authentication.email,
          'user_id' => authentication.user_id,
          'issued_at' => authentication.issued_at
        )
      end
    end
  end
end
