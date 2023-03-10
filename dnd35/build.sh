#!/usr/bin/env bash
curl -sL http://www.andargor.com/files/srd35-db-SQLite-v1.3.zip > srd35-db-SQLite-v1.3.zip && unzip -q -o srd35-db-SQLite-v1.3.zip dnd35.db
rm srd35-db-SQLite-v1.3.zip
sqlite3 dnd35.db .dump | sed 's/longtext/text/g' | sed "s/char(10)/chr(10)/g" | psql dnd35
rm dnd35.db