#!/bin/bash

# Script to sync local directory with Github repository

git add .
git commit -m "Commit"
git pull 
# git remote add origin git@github.com:mges501York/Group-4-Term-3
git push origin master
git pull