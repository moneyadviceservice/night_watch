#! /usr/bin/env bash

time bundle install
time bundle exec rspec 2>&1 | tee test.log
