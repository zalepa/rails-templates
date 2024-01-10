# frozen_string_literal: true

# Gem configuration
gem 'devise'       # use devise for user authentication
gem 'haml-rails'   # add haml for alternative templating
gem 'high_voltage' # add high_voltage for static pages

# Configure high_voltage root path
initializer 'high_voltage.rb', <<-CODE
  HighVoltage.configure do |config|
    config.home_page = 'home'
  end
CODE

# Create the homepage
file 'app/views/pages/home.html.haml', <<-CODE
  %h1 Homepage
CODE

# Install and configure Devise
generate 'devise:install'
environment "config.action_mailer.default_url_options = { host: 'localhost', port: 3000 }", env: 'development'

# Create header partial with login links
file 'app/views/shared/_header.html.haml', <<-CODE
  .p-2.flex.flex-row.bg-slate-100.justify-between.mb-2
    %h1 Site
    %ul.flex.flex-row
      - if user_signed_in?
        %li.px-2
          = link_to 'Logout', destroy_user_session_path, method: :delete, data: { turbo_method: :delete }
      - else
        %li.px-2
          = link_to 'Login', new_user_session_path
        %li.px-2
          = link_to 'Register', new_user_registration_path
CODE

# Create a header and alert panel and insert into application layout
layout_path = "app/views/layouts/application.html.erb"
content_to_add = <<~HTML
  \t\t<%= render 'shared/header' %>
  \t\t<% if notice %><p class="notice"><%= notice %></p><% end %>
  \t\t<% if alert %><p class="alert"><%= alert %></p><% end %>
HTML
insert_into_file layout_path, content_to_add, after: "<body>\n"

# Generate devise User and views
generate 'devise User'
generate 'devise:views'

# Create dummy user
insert_into_file 'db/seeds.rb', 'User.create(email: "john@example.com", password: "password")'

# Bring up database
rails_command 'db:drop'
rails_command 'db:create'
rails_command 'db:migrate'
rails_command 'db:seed'