#!/bin/bash
set -o errexit -o noclobber -o nounset -o pipefail -u

showHelp() {
# `cat << EOF` This means that cat should stop reading when EOF is detected
cat << EOF  
Usage: $0 [-v] [-h] [-r repository-owner] [-r repository-name] [-t github-token]
Obtain a list of issues and their labels for a GitHub repository

-h,                Display help

-o,                (required) Set the GitHub repository owner, i.e. algorand

-r,                (required) Set the GitHub repository to obtain open issues from, i.e. go-algorand

-t,                (optional) GitHub token used to authenticate to the GitHub API

-v,                Run script in verbose mode. Will print out each step of execution.
EOF
# EOF is found above and hence cat command stops reading. This is equivalent to echo but much neater when printing out.
}

# Script arguments
while getopts :r:o:t:hv flag
do
    case "${flag}" in
        r) repository=${OPTARG};;
        o) owner=${OPTARG};;
        t) token=${OPTARG};;
        v)
            set -xv # Set xtrace and verbose mode
        ;;
        h) showHelp;;
        \? ) echo "Usage: $0 [-v] [-h] [-r repository-owner] [-r repository-name] [-t github-token]";;
    esac
done

# If token is not provided into the script, set from environment variable
if [ -z ${token+x} ];
    then
        token=$GITHUB_TOKEN
fi


# Obtain open issues for a repository
response=$(curl -0 "https://api.github.com/repos/${owner}/${repository}/issues?state=open" \
  -H "Accept: application/vnd.github+json" \
  -H "Authorization: token ${token}")

# Parse response to obtain relevant information
jq '.[] | {title,state,url,labels}' <<< $response