require_relative 'rack_webp_middleware'
require 'dotenv/load'

use RackWebP

# rest of your config.rb
require_relative 'helpers/unsplash_api.rb'
require_relative 'helpers/pexels_api'
require_relative 'helpers/pixabay_api'
require "helpers/custom_helpers"
helpers CustomHelpers

puts "Encoding.default_external: #{Encoding.default_external}"
puts "Encoding.default_internal: #{Encoding.default_internal}"
puts "Locale: #{`locale`}"

Encoding.default_external = Encoding::UTF_8
Encoding.default_internal = Encoding::UTF_8

# Activate and configure extensions
# https://middlemanapp.com/advanced/configuration/#configuring-extensions

activate :autoprefixer do |prefix|
  prefix.browsers = "last 2 versions"
end

# Подключение SASS
configure :development do
  activate :sprockets
  sprockets.append_path File.join(root, 'node_modules')
end

configure :build do
  activate :sprockets
  sprockets.append_path File.join(root, 'node_modules')
  activate :minify_css unless config[:already_activated_minify_css]
  activate :minify_javascript, compressor: Terser.new
  config[:already_activated_minify_css] = true
end

# Layouts
# https://middlemanapp.com/basics/layouts/

# Per-page layout changes
page '/*.xml', layout: false
page '/*.json', layout: false
page '/*.txt', layout: false

# With alternative layout
# page '/path/to/file.html', layout: 'other_layout'

# Proxy pages
# https://middlemanapp.com/advanced/dynamic-pages/

# proxy(
#   '/this-page-has-no-template.html',
#   '/template-file.html',
#   locals: {
#     which_fake_page: 'Rendering a fake page with a local variable'
#   },
# )

# Build-specific configuration
# https://middlemanapp.com/advanced/configuration/#environment-specific-settings

# Helper methods
helpers CustomHelpers

# Добавление отладочной информации
after_configuration do
  ::Middleman::Extensions.register(:debug_encoding) do
    Class.new(::Middleman::Extension) do
      def initialize(app, options_hash={}, &block)
        super

        app.after_build do |builder|
          builder.thor.say_status "Debug", "Encoding.default_external: #{Encoding.default_external}"
          builder.thor.say_status "Debug", "Encoding.default_internal: #{Encoding.default_internal}"
          builder.thor.say_status "Debug", "Locale: #{`locale`}"
        end
      end
    end
  end

  activate :debug_encoding
end
