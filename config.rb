set :css_dir, 'stylesheets'
set :js_dir, 'javascripts'
set :images_dir, 'images'

require 'redcarpet'

BLOG_SPACE_ID = ENV['BLOG_SPACE_ID']
ACCESS_TOKEN  = ENV['ACCESS_TOKEN']

if !BLOG_SPACE_ID || !ACCESS_TOKEN
  fail 'Both BLOG_SPACE_ID and ACCESS_TOKEN have to be defined!'
end

class PostMapper < ContentfulMiddleman::Mapper::Base
  def map(context, entry)
    super

    renderer     = Redcarpet::Render::HTML.new
    markdown     = Redcarpet::Markdown.new(renderer, { fenced_code_blocks: true })
    publish_date = entry.published_at
    html         = markdown.render(entry.body)

    slug = if defined?(entry.old_file_name) and (not entry.old_file_name.nil?)
      entry.old_file_name
    else
      entry.title.parameterize
    end

    html_snippet = Sanitize.clean(html)[0..250]
    html_snippet += '...' if html.size > html_snippet.size

    context.post = {
      'published_at' => publish_date,
      'year' => publish_date.year,
      'month' => (publish_date.month >= 10) ? publish_date.month : "0#{publish_date.month}",
      'day' => (publish_date.day >= 10) ? publish_date.day : "0#{publish_date.day}",
      'html' => html,
      'html_snippet' => html_snippet,
      'published' => true,
      'slug' => slug,
      'title' => entry.title,
      'tags' => entry.tags.map(&:id)
    }
  end
end

activate :contentful do |f|
  f.space         = { blog: BLOG_SPACE_ID }
  f.access_token  = ACCESS_TOKEN
  f.cda_query     = { limit: 1000 }
  f.content_types = {
    authors: 'author',
    tags: 'tag',
    posts: { id: 'post', mapper: PostMapper }
  }
end

activate :contentful_pages do |extension|
  extension.data      = 'blog.posts'
  extension.template  = 'post.html.erb'
  extension.permalink = '{slug}.html'
end

activate :blog do |blog|
  blog.permalink = ":title"
  blog.sources   = "blog/:year-:month-:day-:title"
end

# Build-specific configuration
configure :build do
end
