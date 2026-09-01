# frozen_string_literal: true

##
# `BsJwt` holds its configuration in a module level accessor and memoizes the
# JWKS it fetched, so state has to be dropped between examples to keep them
# independent of the (random) execution order.
module BsJwtState
  def self.reset!
    BsJwt.auth0_domain = nil
    BsJwt.remove_instance_variable(:@jwks_key) if BsJwt.instance_variable_defined?(:@jwks_key)
  end
end
