#!/bin/sh

SYNTAX="syntax: $0 <target_dir> <pipeline_name>"

if [ $# -eq "0" ]; then
    echo "Target directory and Pipeline name are required"
    echo "$SYNTAX"
    exit 1
fi

# Tool Meta Data
STAGE="SIS"
TOOL="Gitleaks"
REPORT_MANAGER_DIRECTORY="/var/jenkins_home/userContent/components/Report_manager.py"

VERSION="latest"
BIBIMBOB_DIRECTORY=$HOME/bibim
TARGET_DIRECTORY="$1"
PIPELINE_NAME="$2"
REPORT_DIRECTORY="$BIBIMBOB_DIRECTORY/report"
REPORT_FORMAT="json"
REPORT_FILE_NAME="sis-gitleaks-report.$REPORT_FORMAT"

SCRIPT=$(readlink -f "$0")
SCRIPTPATH=$(dirname "$SCRIPT")

if [ ! -d "$REPORT_DIRECTORY" ]; then
    echo "Initially creating persistent directory: $REPORT_DIRECTORY"
    mkdir -p "$REPORT_DIRECTORY"
fi

echo "ggshield: target directory is $TARGET_DIRECTORY"
ls -al $TARGET_DIRECTORY
echo "ggshield: report directory is $REPORT_DIRECTORY"

cp $SCRIPTPATH/Dockerfile ./gitleaks_Dockerfile

docker build -t gitleaks:$VERSION -f gitleaks_Dockerfile .


docker run --rm  \
    --volume "$REPORT_DIRECTORY":/report:z \
    gitleaks:$VERSION \
    /bin/bash -c " \
    gitleaks detect \
    --no-git \
    --source /src \
    --report-format $REPORT_FORMAT \
    --report-path /report/$REPORT_FILE_NAME > /dev/null; \
    cat /report/$REPORT_FILE_NAME" > $REPORT_DIRECTORY/$REPORT_FILE_NAME

echo "gitleaks: scanning completed."

ls -al $REPORT_DIRECTORY

python3 $REPORT_MANAGER_DIRECTORY $PIPELINE_NAME $STAGE $TOOL $REPORT_DIRECTORY/$REPORT_FILE_NAME
