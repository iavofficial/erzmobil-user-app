#!/bin/bash
set -eo pipefail

source "$HOME/.erzmobil.profile"

bundle install
bundle exec fastlane "$@"

