#!/bin/sh

SYNTAX="syntax: $0 <target_dir> <pipeline_name>"

if [ $# -eq "0" ]; then
    echo "Target directory and Pipeline name are required"
    echo "$SYNTAX"
    exit 1
fi

# Tool Meta Data
STAGE="SCA"
TOOL="dependency-check"
REPORT_MANAGER_DIRECTORY="/var/jenkins_home/userContent/components/Report_manager.py"

VERSION="latest"
BIBIMBOB_DIRECTORY=$HOME/bibim
TARGET_DIRECTORY="$1"
PIPELINE_NAME="$2"
REPORT_DIRECTORY="$BIBIMBOB_DIRECTORY/report"
REPORT_FORMAT="json"
REPORT_FILE_NAME="sca-dependency-check-report.$REPORT_FORMAT"
SCRIPT=$(readlink -f "$0")
SCRIPTPATH=$(dirname "$SCRIPT")

if [ ! -d "$REPORT_DIRECTORY" ]; then
    echo "Initially creating persistent directory: $REPORT_DIRECTORY"
    mkdir -p "$REPORT_DIRECTORY"
fi

echo "ggshield: target directory is $TARGET_DIRECTORY"
ls -al $TARGET_DIRECTORY
echo "ggshield: report directory is $REPORT_DIRECTORY"

cp $SCRIPTPATH/Dockerfile ./dependency-check_Dockerfile

docker build -t dependency-check:$VERSION -f dependency-check_Dockerfile .

docker run --rm \
    --env GITGUARDIAN_API_KEY=1 \
    --volume "$REPORT_DIRECTORY":/report \
    ggshield:$VERSION secret scan \
    --json \
    path . --recursive -y > $REPORT_DIRECTORY/$REPORT_FILE_NAME || true

echo "ggshield: scanning completed."

ls -al $REPORT_DIRECTORY
