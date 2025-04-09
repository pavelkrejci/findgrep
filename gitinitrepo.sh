#!/bin/bash

usage() {
	[ -n "$1" ] && echo "Error: $1"
	echo "Usage:"
	echo "$(basename $0) <new git repo name>"
	echo " - creates new repository in ~/git-repos and initialize it with git init bare"
	exit 2
}

[ -z "$1" ] && usage

GITNAME=~/git-repos/$1.git

[ -d "$GITNAME" ] && usage "Repository $GITNAME already exists."

mkdir -p "$GITNAME"
cd "$GITNAME"
git init --bare

cd hooks
ln -s ~/llm-tools/post-receive

