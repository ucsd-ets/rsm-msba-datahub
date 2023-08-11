###################
###################
###################

# This helper script initializes a local Postgresql database and configures it appropriately.
# This includes modifying the inherited postgresql.yml config, creating appropriate directories, 
# starting postgres as a non-root user, and setting user credentials in postgresql.

# Environment variables that are not initialized here are initialized by the launch script referenced in the README.
# 8/10/2023 dafeliton

###################
###################
###################

#!/bin/bash

# If pgdata exists, stop or start depending on if PID file exists
if [ -d "/home/${NB_USER}/pgdata" ]; then
    echo "pgdata/ already exists."
    if [ -f "/home/${NB_USER}/pgdata/pgsql-main.pd" ]; then
        # Stop postgres
        echo "Stopping postgres..."
        pg_ctl -D "/home/${NB_USER}/pgdata/" -l "/home/${NB_USER}/logfile" stop
    else
        # Start postgres
        echo "Starting postgres..."
        pg_ctl -D "/home/${NB_USER}/pgdata/" -l "/home/${NB_USER}/logfile" start
    fi
    exit 0
fi

# Setup vars + ensure pgdata exists
initdb -D pgdata
mkdir "/home/${NB_USER}/pgdata/conf.d" 2>/dev/null

PGDATA="${HOME}/pgdata"
PGCONFIGFILE="${HOME}/pgdata/postgresql.conf"
PGHBAFILE="${HOME}/pgdata/pg_hba.conf"
PGIDENTFILE="${HOME}/pgdata/pg_ident.conf"
PGPIDFILE="${HOME}/pgdata/pgsql-main.pd"
PGUNIXSOCKETDIRS="${HOME}/pgdata/"

CONFIGFILE="/etc/postgresql/${POSTGRES_VERSION}/main/postgresql.conf"
TEMPCONFIGFILE="/home/${NB_USER}/temp_post.yml"

HBAFILE="/etc/postgresql/${POSTGRES_VERSION}/main/pg_hba.conf"

IDENTFILE="/etc/postgresql/${POSTGRES_VERSION}/main/pg_ident.conf"

# Copy config file
echo "Overwriting + modifying configs..."

# Modify PostgreSQL configuration, preserve any other values
awk -F " *= *" \
-v PGDATA="$PGDATA" \
-v PGHBAFILE="$PGHBAFILE" \
-v PGIDENTFILE="$PGIDENTFILE" \
-v PGPIDFILE="$PGPIDFILE" \
-v PGUNIXSOCKETDIRS="$PGUNIXSOCKETDIRS" \
'{
    gsub(/^[ \t]+/, "", $1);
    if ($1 == "data_directory") { print $1 " = '\''" PGDATA "'\''"; next }
    if ($1 == "hba_file") { print $1 " = '\''" PGHBAFILE "'\''"; next }
    if ($1 == "ident_file") { print $1 " = '\''" PGIDENTFILE "'\''"; next }
    if ($1 == "external_pid_file") { print $1 " = '\''" PGPIDFILE "'\''"; next }
    if ($1 == "unix_socket_directories") { print $1 " = '\''" PGUNIXSOCKETDIRS "'\''"; next }
    print $0
}' "$CONFIGFILE" > "$TEMPCONFIGFILE"

# Remove unnecessary value from config
awk '!/^stats_temp_directory/' "$TEMPCONFIGFILE" > "${TEMPCONFIGFILE}.tmp" && mv "${TEMPCONFIGFILE}.tmp" "$TEMPCONFIGFILE"

# Disable SSL (for now?)
awk '{gsub(/ssl[ \t]*=[ \t]*on/, "ssl = off"); print}' "$TEMPCONFIGFILE" > "${TEMPCONFIGFILE}.tmp" && mv "${TEMPCONFIGFILE}.tmp" "$TEMPCONFIGFILE"

# Write config file
mv "$TEMPCONFIGFILE" "$PGCONFIGFILE"

# Write hba file
cp "$HBAFILE" "$PGHBAFILE"

# Write ident file
cp "$IDENTFILE" "$PGIDENTFILE"

# Initialize server, create DB
cd "/home/${NB_USER}"
pg_ctl -D "/home/${NB_USER}/pgdata/" -l "/home/${NB_USER}/logfile" start
createdb -O "${NB_USER}" rsm-docker -p 8765 -h "/home/${NB_USER}/pgdata/"
psql rsm-docker -U "${NB_USER}" -h "/home/${NB_USER}/pgdata/" -p 8765 -c "ALTER USER ${NB_USER} WITH PASSWORD '${PGPASSWORD}';"

echo "#####################################################################################"
echo "#####################################################################################"
echo "#####################################################################################"
echo ""
echo ""
echo ""
echo "Your local, non-root postgres server has been started."
echo "All data is stored in /home/${NB_USER}/pgdata. Please DELETE this dir if you need to init your database setup again."
echo ""
echo "Please write down these commands! You will need to run this if your environment is interrupted."
echo "To START your local postgres server ----> pg_ctl -D /home/${NB_USER}/pgdata -l /home/${NB_USER}/logfile start"
echo "To STOP your local postgres server ----> pg_ctl -D /home/${NB_USER}/pgdata -l /home/${NB_USER}/logfile stop"
echo "Running this script from this point onwards will do the inverse of the DB's state (shorthand for the above commands)."
echo "If it is shutdown, it will be started. If it is active, it will be shutdown."
echo ""
echo ""
echo ""
echo "#####################################################################################"
echo "#####################################################################################"
echo "#####################################################################################"