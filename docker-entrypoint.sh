#!/bin/bash

bundle install
rerun --background 'bundle exec thin start'