clear
pushd .
rm -rf /tmp/swtest
mkdir /tmp/swtest
cd /tmp/swtest
swift package init --type=executable
rm -rf Tests
export HUBEX=/private/var
export HUB=$HUBEX/perfect

tee Package.swift << EOF >> /dev/null
import PackageDescription
let package = Package(
	name: "swtest",	targets: [],
  dependencies: [
		.Package(url: "$HUB/Perfect-HTTPServer", majorVersion: 3),
		.Package(url: "$HUB/Perfect-RequestLogger", majorVersion: 3),
		.Package(url: "$HUB/Perfect-Mustache", majorVersion: 3),
		.Package(url: "$HUB/Perfect-WebSockets", majorVersion: 3),
		.Package(url: "$HUB/Perfect-WebRedirects", majorVersion: 3),
		.Package(url: "$HUB/Perfect-Notifications", majorVersion: 3),
		.Package(url: "$HUB/Perfect-Zip", majorVersion: 3),
		.Package(url: "$HUB/Perfect-XML", majorVersion: 3),
		.Package(url: "$HUB/Perfect-SMTP", majorVersion: 3),
		.Package(url: "$HUB/Perfect-PostgreSQL", majorVersion: 3),
		.Package(url: "$HUB/Perfect-SQLite", majorVersion: 3),
		.Package(url: "$HUB/Perfect-MySQL", majorVersion: 3),
		.Package(url: "$HUB/Perfect-MariaDB", majorVersion: 3),
		.Package(url: "$HUB/Perfect-MongoDB", majorVersion: 3),
		.Package(url: "$HUB/Perfect-Redis", majorVersion: 3),
		.Package(url: "$HUB/Perfect-CouchDB", majorVersion: 3),
		.Package(url: "$HUB/Perfect-FileMaker", majorVersion: 3),
		.Package(url: "$HUB/Perfect-Session-MySQL", majorVersion: 3),
		.Package(url: "$HUB/Perfect-Session-PostgreSQL", majorVersion: 3),
		.Package(url: "$HUB/Perfect-Session-MongoDB", majorVersion: 3),
		.Package(url: "$HUB/Perfect-Session-Redis", majorVersion: 3),
		.Package(url: "$HUB/Perfect-Session-SQLite", majorVersion: 3),
		.Package(url: "$HUB/Perfect-Session-CouchDB", majorVersion: 3),
		.Package(url: "$HUB/Perfect-Markdown", majorVersion: 3),
		.Package(url: "$HUB/Perfect-Python", majorVersion: 3),
		.Package(url: "$HUB/Perfect-LDAP", majorVersion: 3),
		.Package(url: "$HUB/Perfect-Kafka", majorVersion: 3),
		.Package(url: "$HUB/Perfect-Mosquitto", majorVersion: 3),
		.Package(url: "$HUB/Perfect-OAuth2", majorVersion: 3),
		.Package(url: "$HUB/Perfect-Repeater", majorVersion: 1),
		.Package(url: "$HUB/Perfect-Hadoop", majorVersion: 1),
		.Package(url: "$HUB/Perfect-Turnstile-SQLite", majorVersion: 3),
		.Package(url: "$HUB/Perfect-Turnstile-MySQL", majorVersion: 3),
		.Package(url: "$HUB/Perfect-Turnstile-PostgreSQL", majorVersion: 3),
		.Package(url: "$HUB/Perfect-Turnstile-MongoDB", majorVersion: 3),
		.Package(url: "$HUB/Perfect-Turnstile-CouchDB", majorVersion: 3),
		.Package(url: "$HUB/Perfect-LocalAuthentication-PostgreSQL", majorVersion: 3),
		.Package(url: "$HUB/JSONConfig", majorVersion: 3),
		.Package(url: "$HUB/SwiftString", majorVersion: 2),
		.Package(url: "$HUB/SwiftMoment", majorVersion: 1),
		.Package(url: "$HUB/StORM", majorVersion: 3),
		.Package(url: "$HUB/SQLite-StORM", majorVersion: 3),
		.Package(url: "$HUB/CouchDB-StORM", majorVersion: 3),
		.Package(url: "$HUB/Postgres-StORM", majorVersion: 3),
		.Package(url: "$HUB/MySQL-StORM", majorVersion: 3),
		.Package(url: "$HUB/MongoDB-StORM", majorVersion: 3),
		.Package(url: "$HUB/SwiftRandom", majorVersion: 0),
	]
)
EOF
tee Sources/swtest/main.swift << EOF >> /dev/null
import PerfectLib
import PerfectHTTP
import PerfectHTTPServer
import PerfectThread
import PerfectLogger
import PerfectRequestLogger
import PerfectNet
import PerfectXML
import PerfectCrypto
import PerfectCURL
import PerfectSMTP
import PerfectMustache
import PerfectPostgreSQL
import PerfectSQLite
import PerfectMySQL
import PerfectRedis
import PerfectMongoDB
import PerfectRepeater
import PerfectNotifications
import PerfectCouchDB
import PerfectFileMaker
import PerfectHadoop
import PerfectWebSockets
import PerfectWebRedirects
import PerfectPython
import PerfectMarkdown
import PerfectLDAP
import PerfectKafka
import PerfectMosquitto
import PerfectSession
import PerfectSessionMySQL
import PerfectSessionPostgreSQL
import PerfectSessionRedis
import PerfectSessionMongoDB
import PerfectSessionSQLite
import PerfectSessionCouchDB
import PerfectTurnstileSQLite
import PerfectTurnstileMySQL
import PerfectTurnstilePostgreSQL
import PerfectTurnstileMongoDB
import PerfectTurnstileCouchDB
import PerfectLocalAuthentication
import PerfectZip
import OAuth2
import MariaDB
import SwiftMoment
import SwiftRandom
import SwiftString
import JSONConfig
import StORM
import SQLiteStORM
import CouchDBStORM
import PostgresStORM
import MySQLStORM
import MongoDBStORM
print("Hello, Perfect!")
EOF

echo "++++++++++++ L I N U X ++++++++++"
docker pull rockywei/swift:4.0
time docker run -it -v $HUBEX:$HUBEX -v /tmp:/tmp -w /tmp/swtest \
rockywei/swift:4.0 /bin/bash -c \
"time swift run"
echo "++++++++++++ M A C O S ++++++++++"
rm -rf .build*
rm -rf *.resolved
rm -rf *.pins
time swift run
popd

pushd .
rm -rf /tmp/swtest
mkdir /tmp/swtest
cd /tmp/swtest
swift package init --type=executable
rm -rf Tests
tee Package.swift << EOF >> /dev/null
import PackageDescription
let package = Package(
	name: "swtest",	targets: [],
  dependencies: [
		.Package(url: "$HUB/Perfect-LocalAuthentication-MySQL", majorVersion: 3),
	]
)
EOF
tee Sources/swtest/main.swift << EOF >> /dev/null
import PerfectLocalAuthentication
print("Hello, Perfect Authentication MySQL!")
EOF
echo "++++++++++++ L I N U X ++++++++++"
docker pull rockywei/swift:4.0
time docker run -it -v $HUBEX:$HUBEX -v /tmp:/tmp -w /tmp/swtest \
rockywei/swift:4.0 /bin/bash -c \
"time swift run"
echo "++++++++++++ M A C O S ++++++++++"
rm -rf .build*
rm -rf *.resolved
rm -rf *.pins
time swift run
popd
rm -rf /tmp/swtest