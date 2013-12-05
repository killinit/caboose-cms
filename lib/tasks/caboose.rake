require "caboose/version"
require "caboose/migrations"

namespace :caboose do  
  
  desc "Creates/verifies that all database tables and fields are correctly added."
  task :db => :environment do
    Caboose::Schema.create_schema
    Caboose::Schema.load_data
  end

  desc "Creates all caboose tables"
  task :create_schema => :environment do Caboose::Schema.create_schema end

  desc "Loads data into caboose tables"
  task :load_data => :environment do Caboose::Schema.load_data end

  #=============================================================================
  
  desc "Resets the admin password to 'caboose'"
  task :reset_admin_pass => :environment do  
    admin_user = Caboose::User.where(username: 'admin').first
    admin_user.password = Digest::SHA1.hexdigest(Caboose::salt + 'caboose')
    admin_user.save    
  end

  desc "Sync production db to development"
  task :sync_dev_db do
    
    ddb = Rails.application.config.database_configuration['development']
    pdb = Rails.application.config.database_configuration['production']
    
    dump_file = "#{Rails.root}/db/backups/#{pdb['database']}_#{DateTime.now.strftime('%FT%T')}.dump"
    if !File.exists?("#{Rails.root}/db/backups")
      `mkdir -p #{Rails.root}/db/backups`
    end
    
    puts "Capturing production database..."
    `heroku pgbackups:capture`
    
    puts "Downloading production database dump file..."
    `curl -o #{dump_file} \`heroku pgbackups:url\``
    
    puts "Restoring development database from dump file..."
    `pg_restore --verbose --clean --no-acl --no-owner -h #{ddb['host']} -U #{ddb['username']} -d #{ddb['database']} #{dump_file}`
    
  end
  
end
