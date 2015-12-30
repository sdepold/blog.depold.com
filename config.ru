require 'rack'
require 'rack/contrib/try_static'
require 'rack-rewrite'


use Rack::Rewrite do
  # Remove trailing slash to fix static file lookup
  rewrite %r{^(.+)/$}, '$1'
end

# Serve files from the build directory
use Rack::TryStatic,
  root: 'build',
  urls: %w[/],
  try: ['.html', 'index.html', '/index.html']

run lambda { |env|
  four_oh_four_page = File.expand_path("../build/404/index.html", __FILE__)
  [ 404, { 'Content-Type'  => 'text/html'}, [ File.read(four_oh_four_page) ]]
}
