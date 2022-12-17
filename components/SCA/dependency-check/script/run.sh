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

BIBIMBOB_DIRECTORY=$HOME/bibim
TARGET_DIRECTORY="$1"
PIPELINE_NAME="$2"
REPORT_DIRECTORY="$BIBIMBOB_DIRECTORY/report"
REPORT_FILE_NAME="dependency-check-report.json"
REPORT_FORMAT="JSON"

DC_VERSION="latest"
DC_DIRECTORY="$BIBIMBOB_DIRECTORY/OWASP-Dependency-Check"
DC_PROJECT="dependency-check scan: $(pwd)"
DATA_DIRECTORY="$DC_DIRECTORY/data"
CACHE_DIRECTORY="$DC_DIRECTORY/data/cache"

SCRIPT=$(readlink -f "$0")
SCRIPTPATH=$(dirname "$SCRIPT")

if [ ! -d "$DATA_DIRECTORY" ]; then
    echo "Initially creating persistent directory: $DATA_DIRECTORY"
    mkdir -p "$DATA_DIRECTORY"
fi
if [ ! -d "$CACHE_DIRECTORY" ]; then
    echo "Initially creating persistent directory: $CACHE_DIRECTORY"
    mkdir -p "$CACHE_DIRECTORY"
fi

echo "dependency-check: target directory is $TARGET_DIRECTORY"
ls -al $TARGET_DIRECTORY
echo "dependency-check: report directory is $REPORT_DIRECTORY"

cp $SCRIPTPATH/Dockerfile ./dependency-check_Dockerfile

docker build -t dependency-check:$DC_VERSION -f dependency-check_Dockerfile .

docker run --rm \
    -e user=$USER \
    -u $(id -u ${USER}):$(id -g ${USER}) \
    --volume "$DATA_DIRECTORY":/usr/share/dependency-check/data:z \
    --volume "$REPORT_DIRECTORY":/report:z \
    dependency-check:$DC_VERSION \
    /bin/sh -c " \
    /usr/share/dependency-check/bin/dependency-check.sh \
    --scan /src \
    --format $REPORT_FORMAT \
    --project $DC_PROJECT \
    --out /report > /dev/null; cat /report/dependency-check-report.json" > $REPORT_DIRECTORY/$REPORT_FILE_NAME

echo "dependency-check: scanning completed."

cat $REPORT_DIRECTORY/$REPORT_FILE_NAME

python3 $SCRIPTPATH/parser.py $REPORT_DIRECTORY/$REPORT_FILE_NAME $REPORT_DIRECTORY/$REPORT_FILE_NAME

python3 $REPORT_MANAGER_DIRECTORY $PIPELINE_NAME $STAGE $TOOL $REPORT_DIRECTORY/$REPORT_FILE_NAME
