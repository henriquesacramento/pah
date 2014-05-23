class HerokuApp < Rails::Generators::AppGenerator
  DEFAULT_ADDONS = %w(heroku-postgresql:dev pgbackups:auto-month loggly:mole sendgrid:starter rollbar newrelic:stark)

  attr_reader :name, :description, :config

  def initialize(config)
    @config = config
    @name = @config[:heroku][:name]
    @description = description

    add_secret_token
    add_timezone_config
    add_addons
    add_heroku_git_remote
    check_canonical_domain
    check_collaborators
  end

  def add_addons
    DEFAULT_ADDONS.each { |addon| add_heroku_addon(addon) }
  end

  def add_secret_token
    say "Creating SECRET_KEY_BASE for Heroku '#{name}.herokuapp.com'".magenta
    system "heroku config:set SECRET_KEY_BASE=#{SecureRandom::hex(60)} --app #{name}"
  end

  def add_heroku_git_remote
    say "Adding Heroku git remote for deploy to '#{name}'.".magenta
    system "git remote add heroku git@heroku.com:#{name}.git"
  end

  def add_heroku_addon(addon)
    say "Adding heroku addon [#{addon}] to '#{name}'.".magenta
    system "heroku addons:add #{addon} --app #{name}"
  end

  def add_canonical_domain(domain)
    system "heroku domains:add #{domain} --app #{name}"
  end

  def add_collaborator(email)
    system "heroku sharing:add #{email} --app #{name}"
  end

  def add_timezone_config
    say "Adding timezone config on Heroku".magenta
    system "heroku config:set TZ=America/Sao_Paulo --app #{name}"
  end

  def open
    say "Pushing application to heroku...".magenta

    system "git push heroku master"

    system "heroku open --app #{name}"
  end

  private
    def check_canonical_domain
      domain = @config[:heroku][:domain]
      add_canonical_domain(domain) unless domain.blank?
    end

    def check_collaborators
      collaborators = @config[:heroku][:collaborators]

      if collaborators.present?
        collaborators.split(",").map(&:strip).each { |email| add_collaborator(email) }
      end
    end
end

copy_static_file 'Procfile'
git add: 'Procfile'
git_commit 'Add Procfile'

if @config[:heroku][:create?]
  production_app = HerokuApp.new @config
  production_app.open if @config[:heroku][:deploy?]
end
