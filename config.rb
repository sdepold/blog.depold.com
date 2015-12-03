set :css_dir, 'stylesheets'
set :js_dir, 'javascripts'
set :images_dir, 'images'

BLOG_SPACE_ID = ENV['BLOG_SPACE_ID']
ACCESS_TOKEN  = ENV['ACCESS_TOKEN']

if !BLOG_SPACE_ID || !ACCESS_TOKEN
  fail 'Both BLOG_SPACE_ID and ACCESS_TOKEN have to be defined!'
end

class PostMapper < ContentfulMiddleman::Mapper::Base
  def map(context, entry)
    super

    puts entry.published_at
    publish_date  = entry.published_at
    context.year  = publish_date.year
    context.month = if publish_date.month >= 10 then publish_date.month else "0#{publish_date.month}" end
    context.day   = if publish_date.day >= 10 then publish_date.day else "0#{publish_date.day}" end

    if defined? entry.old_file_name and (not entry.old_file_name.nil?)
      context.slug = entry.old_file_name
    else
      context.slug = entry.title.parameterize
    end

    context.published = true
  end
end

activate :contentful do |f|
  f.space         = { blog: BLOG_SPACE_ID }
  f.access_token  = ACCESS_TOKEN
  f.cda_query     = { limit: 1000 }
  f.content_types = {
    users: 'user',
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
