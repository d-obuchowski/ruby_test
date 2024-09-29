# README

Instructions to run application:

1. create .env file in your root project path
2. copy data from .example.env file to .env file
3. Insert proper values in .env file
4. run: docker-compose build
5. run: docker-compose run web bundle exec rails db:prepare
6. run: docker-compose up


Instructions to run tests: 

run: docker-compose run --rm -e "RAILS_ENV=test" web bundle exec rspec
