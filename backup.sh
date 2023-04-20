#!/bin/bash

# Edit this values
GITHUB_USERNAME=$1 # You github usernmame
OAUTH_TOKEN=$2 # Token from https://github.com/settings/tokens
BACKUP_PATH="${3:-backup}" # Backup destination
TODAY_DATE_PREFIX=$(date +%Y%m%d%H%M%S)

if [ -z "$GITHUB_USERNAME" ]
then
      echo "Please provide github username"
      exit 1;
fi

if [ -z "$OAUTH_TOKEN" ]
then
      echo "Please provide github personal token"
      exit 1;
fi

# Fetch all repositories
ALL_REPOSITORIES=""
fetch_repositories() {
	PAGE=1
	while :
	do
	    if [ -z "$OAUTH_TOKEN" ]
	    then
	      PAGE_REPOSITORIES=`curl "https://api.github.com/users/${GITHUB_USERNAME}/repos?per_page=100&page=${PAGE}" | jq -r '.[] | "\(.name),\(.full_name),\(.private),\(.html_url)"'`
	    else
	      PAGE_REPOSITORIES=`curl -H "Authorization: token ${OAUTH_TOKEN}" -s "https://api.github.com/user/repos?per_page=100&page=${PAGE}" | jq -r '.[] | "\(.name),\(.full_name),\(.private),\(.html_url)"'`
	    fi

	    TOTAL_PAGE_REPOSITORIES=`echo $PAGE_REPOSITORIES | tr -cd " " | wc -c`

		  ALL_REPOSITORIES="${ALL_REPOSITORIES} ${PAGE_REPOSITORIES}"

	    if [ "$TOTAL_PAGE_REPOSITORIES" = "99" ]; then
		    let PAGE++
	    else
	    	break;
	    fi
	done
}

fetch_repositories

TOTAL_REPOSITORIES=`echo $ALL_REPOSITORIES | tr -cd " " | wc -c`

echo "Backing up $TOTAL_REPOSITORIES repositories"

COUNT=1
for REPO in $ALL_REPOSITORIES
do
    REPO_NAME=`echo ${REPO} | cut -d ',' -f1`
    REPO_FULLNAME=`echo ${REPO} | cut -d ',' -f2`
    REPO_OWNER=`echo ${REPO_FULLNAME} | cut -d '/' -f1`
    PRIVATE_FLAG=`echo ${REPO} | cut -d ',' -f3`
    SSH_ARCHIVE_URL="git@github.com:${REPO_FULLNAME}.git"
    HTTP_ARCHIVE_URL="https://${GITHUB_USERNAME}:${OAUTH_TOKEN}@github.com/${REPO_FULLNAME}.git"
    CLONE_TARGET="${BACKUP_PATH}/$TODAY_DATE_PREFIX/${REPO_OWNER}/${REPO_NAME}.git"
    mkdir -p "${CLONE_TARGET}"
    echo "Clone: ${SSH_ARCHIVE_URL} in ${CLONE_TARGET}";
    git clone --mirror $HTTP_ARCHIVE_URL $CLONE_TARGET
    #git clone --mirror $SSH_ARCHIVE_URL $CLONE_TARGET
    echo "${COUNT}/${TOTAL_REPOSITORIES}: Clonned ${CLONE_TARGET}"
	  let COUNT++
done

echo "Done!"