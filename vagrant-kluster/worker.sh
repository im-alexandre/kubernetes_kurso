#!/bin/bash

while [ ! -f /vagrant/join-command.sh ]; do
    echo "waiting for join-command.sh"
    sleep 5
done

bash /vagrant/join-command.sh
