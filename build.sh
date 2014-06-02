#!/bin/bash

set -e -x

export RAILS_ENV=build
export BUNDLE_WITHOUT="development"

CI_PIPELINE_COUNTER=${GO_PIPELINE_COUNTER-0}
CI_EXECUTOR_NUMBER=${GO_AGENT_NUMBER-0}

time bundle install
time bundle exec rake gem:build
