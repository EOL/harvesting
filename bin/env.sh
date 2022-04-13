#!/bin/bash
export $(cat /app/docker/.env | xargs)
git config --global user.email $EOL_GITHUB_EMAIL
git config --global user.name $EOL_GITHUB_USER
