#!/bin/sh

SYNTAX="syntax: $0 <target_dir> <pipeline_name>"

if [ $# -eq "0" ]; then
    echo "Target directory and Pipeline name is required"
    echo "$SYNTAX"
    exit 1
fi

# Tool Meta Data
STAGE="SIS"
TOOL="ggshield"
REPORT_MANAGER_DIRECTORY="/var/jenkins_home/userContent/components/Report_manager.py"

VERSION="latest"
BIBIMBOB_DIRECTORY=$HOME/bibim
TARGET_DIRECTORY="$1"
PIPELINE_NAME="$2"
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
    --env GITGUARDIAN_API_KEY=A6aF18A3aB5C3DCEeEcaFdde2CeE9aB8dd5Ef12767709A142E0214A15cCEB2a17fAAf6F \
    --volume "$REPORT_DIRECTORY":/report \
    ggshield:$VERSION \
    ggshield secret scan \
    --json \
    path . --recursive -y  > $REPORT_DIRECTORY/$REPORT_FILE_NAME || true

echo "ggshield: scanning completed."

cat $REPORT_DIRECTORY/$REPORT_FILE_NAME

python3 $REPORT_MANAGER_DIRECTORY $PIPELINE_NAME $STAGE $TOOL $REPORT_DIRECTORY/$REPORT_FILE_NAME
