#!/bin/sh

bundle install --gemfile=.fastlane/Gemfile --path .bundle
BUNDLE_GEMFILE=.fastlane/Gemfile bundle exec fastlane start_deploy