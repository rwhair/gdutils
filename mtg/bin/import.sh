#!/usr/bin/env bash
dropdb --if-exists mtg
createdb mtg
pgfutter --dbname mtg --user `whoami` --schema public --table json_import --jsonb jsonobj "`dirname "$0"`/../json/AllSets-x.json"