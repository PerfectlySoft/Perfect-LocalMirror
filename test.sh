clear
pushd .
rm -rf /tmp/swtest
mkdir /tmp/swtest
cd /tmp/swtest
swift package init --type=executable
rm -rf Tests
HUB=/tmp/perfect tee Package.swift << EOF >> /dev/null
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
		.Package(url: "$HUB/Perfect-Session-Redis", majorVersion: 3),
		.Package(url: "$HUB/Perfect-Repeater", majorVersion: 1),
		.Package(url: "$HUB/Perfect-Hadoop", majorVersion: 1),
		.Package(url: "$HUB/JSONConfig", majorVersion: 3),
		.Package(url: "$HUB/SwiftString", majorVersion: 2),
		.Package(url: "$HUB/SwiftMoment", majorVersion: 1),
		.Package(url: "$HUB/StORM", majorVersion: 3),
		.Package(url: "$HUB/SQLite-StORM", majorVersion: 3),
		.Package(url: "$HUB/CouchDB-StORM", majorVersion: 3),
		.Package(url: "$HUB/Postgres-StORM", majorVersion: 3),
		.Package(url: "$HUB/MySQL-StORM", majorVersion: 3),
		.Package(url: "$HUB/MongoDB-StORM", majorVersion: 3),
		.Package(url: "$HUB/SwiftRandom", majorVersion: 0)
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
import PerfectSessionMySQL
import PerfectSessionPostgreSQL
import PerfectSessionRedis
import PerfectZip
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
time docker run -it -v /tmp:/tmp -w /tmp/swtest rockywei/swift:4.0 /bin/bash -c \
"time swift run"
echo "++++++++++++ M A C O S ++++++++++"
rm -rf .build*
rm -rf *.resolved
rm -rf *.pins
time swift run
popd

rm -rf /tmp/swtest