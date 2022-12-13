#!/bin/sh

SYNTAX="syntax: $0 <target_dir>"

if [ $# -eq "0" ]; then
    echo "Target directory is required"
    echo "$SYNTAX"
    exit 1
fi

VERSION="latest"
BIBIMBOB_DIRECTORY=$HOME/bibim
TARGET_DIRECTORY="$1"
REPORT_DIRECTORY="$BIBIMBOB_DIRECTORY/report"
REPORT_FORMAT="json"
REPORT_FILE_NAME="sis-ggshield-report.$REPORT_FORMAT"
SCRIPT=$(readlink -f "$0")
SCRIPTPATH=$(dirname "$SCRIPT")

if [ ! -d "$REPORT_DIRECTORY" ]; then
    echo "Initially creating persistent directory: $REPORT_DIRECTORY"
    mkdir -p "$REPORT_DIRECTORY"
fi

echo "ggshield: target directory is $TARGET_DIRECTORY"
ls -al $TARGET_DIRECTORY
echo "ggshield: report directory is $REPORT_DIRECTORY"

cp $SCRIPTPATH/Dockerfile ./ggshield_Dockerfile

docker build -t ggshield:$VERSION -f ggshield_Dockerfile .

docker run --rm \
    --env GITGUARDIAN_API_KEY=1 \
    --volume "$REPORT_DIRECTORY":/report \
    ggshield:$VERSION secret scan \
    --json \
    path . --recursive -y > $REPORT_DIRECTORY/$REPORT_FILE_NAME || true

echo "ggshield: scanning completed."

ls -al $REPORT_DIRECTORY
