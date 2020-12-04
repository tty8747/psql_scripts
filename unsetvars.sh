#!/bin/bash

for i in $(cat ./.env | awk '{ print $2 }' | awk -F'=' '{ print $1 }' | xargs echo)
  do
    unset $i
done
