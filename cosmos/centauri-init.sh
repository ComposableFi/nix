#!/usr/bin/env bash
parser_definition() {
    setup REST help:usage -- "Usage: example.sh [options]... [arguments]..."
    msg -- 'Options:'
    option FRESH -f --fresh on:true -- "takes one optional argument"
}

eval "$(getoptions parser_definition) exit 1"

env

if test "$FRESH" != "false"; then
    echo "$CHAIN_DATA"
    rm --force --recursive "$CHAIN_DATA"
fi
