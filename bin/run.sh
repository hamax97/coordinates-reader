#!/usr/bin/env bash

service postgresql start

bin/rails assets:precompile
bin/rails db:create db:migrate
bin/rails active_storage:install

bin/rails server -b 0.0.0.0 -p 3000
