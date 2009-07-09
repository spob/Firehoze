# don't generate doc we'll never see
echo "gem: --no-ri --no-rdoc" >> ~/.gemrc

# install required gems
sudo gem install hpricot
sudo gem install right_http_connection

sudo rake gems:install RAILS_ENV=production

# Assembles Rails database.yml based on information
# provided from a ReadyStack redeploy
#
# WC_DB_ENGINE = [mysql|postgresql]
# WC_APP_NAME = The name of you app, the GitHub repo name
# WC_DB_PASSWORD = the DB password, chosen on the UI
echo WC_DB_ENGINE=${WC_DB_ENGINE}

echo "
login: &login
  adapter: ${WC_DB_ENGINE}
  database: ${WC_APP_NAME}
  username: ${WC_APP_NAME}
  password: ${WC_DB_PASSWORD}
  host: localhost
" > config/database.yml

if [ "${WC_DB_ENGINE}" == "mysql" ]; then
echo "
production:
  <<: *login
  encoding: utf8
" >> config/database.yml
fi

if [ "${WC_DB_ENGINE}" == "postgresql" ]; then
echo "
production:
<<: *login
encoding: unicode
pool: 5
port: 5432
" >> config/database.yml
fi

mkdir log
chown www-data log

rake db:migrate RAILS_ENV=production
rake db:seed RAILS_ENV=production