require "crysda"
require "cryplot"

module Crysda::Plot
  VERSION = {{ `shards version "#{__DIR__}"`.chomp.stringify }}
end

require "./crysda-plot/*"
