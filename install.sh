clear
HUB=/tmp/perfect
pushd .
rm -rf $HUB
mkdir -p $HUB

function mirror_ex() {
	cd /tmp/perfect
	REPO=$1
	VEND=$2
	RELEASES=$VEND/$REPO/releases
	TAGS=/$RELEASES/tag/
	GITHUB=https://github.com
	LATEST=$(curl -s $GITHUB/$RELEASES | grep $TAGS | head -n 1 | \
	sed $'s/[\"|\<|\>|\/]/\\\n/g' | egrep '[0-9]+.[0-9]+.[0-9]' | head -n 1)
	echo "Caching $VEND/$REPO:$LATEST"
	curl -s -L "$GITHUB/$VEND/$REPO/archive/$LATEST.tar.gz" -o /tmp/a.tgz
	tar xzf /tmp/a.tgz
	rm -rf /tmp/a.tgz
	mv $REPO-$LATEST $REPO
	cd $REPO
}

function mirror() {
	mirror_ex $1 PerfectlySoft
}

function reversion() {
	rm -rf .git
	git init >> /dev/null
	git add *  >> /dev/null
	git commit -m "slim"  >> /dev/null
	VERSION=$(git log|awk '$1=="commit" {print $2}')
	git tag $LATEST $VERSION  >> /dev/null
}

mirror Perfect-LinuxBridge
reversion

mirror Perfect
tee Package.swift << EOF >> /dev/null
import PackageDescription
var urls = [String]()
#if os(Linux)
urls += ["$HUB/Perfect-LinuxBridge"]
#endif
let package = Package(name: "PerfectLib",	targets: [],
	dependencies: urls.map { .Package(url: \$0, majorVersion: 3) }
)
EOF
reversion

mirror Perfect-COpenSSL
reversion

mirror Perfect-COpenSSL-Linux
reversion

mirror Perfect-Thread
tee Package.swift << EOF >> /dev/null
import PackageDescription
var urls = [String]()
#if os(Linux)
urls += ["$HUB/Perfect-LinuxBridge"]
#endif
let package = Package(name: "PerfectThread",	targets: [],
	dependencies: urls.map { .Package(url: \$0, majorVersion: 3) }
)
EOF
reversion

mirror Perfect-Crypto
reversion
tee Package.swift << EOF >> /dev/null
import PackageDescription
#if os(OSX)
	let cOpenSSLRepo = "$HUB/Perfect-COpenSSL"
#else
	let cOpenSSLRepo = "$HUB/Perfect-COpenSSL-Linux"
#endif
let package = Package( name: "PerfectCrypto", targets: [],
    dependencies: [
		.Package(url: "$HUB/Perfect", majorVersion: 3),
		.Package(url: "$HUB/Perfect-Thread", majorVersion: 3),
		.Package(url: cOpenSSLRepo, majorVersion: 3)
	])
EOF
reversion

mirror Perfect-Net
reversion
tee Package.swift << EOF >> /dev/null
import PackageDescription
var urls: [String] = ["$HUB/Perfect-Crypto", "$HUB/Perfect-Thread"]
#if os(Linux)
	urls += ["$HUB/Perfect-LinuxBridge"]
#endif
let package = Package(name: "PerfectNet", targets: [],
    dependencies:  urls.map { .Package(url: \$0, majorVersion: 3) }
)
EOF
reversion

mirror Perfect-HTTP
reversion
tee Package.swift << EOF >> /dev/null
import PackageDescription
var urls: [String] = ["$HUB/Perfect", "$HUB/Perfect-Net"]
#if os(Linux)
	urls += ["$HUB/Perfect-LinuxBridge"]
#endif
let package = Package(name: "PerfectHTTP", targets: [],
    dependencies:  urls.map { .Package(url: \$0, majorVersion: 3) }
)
EOF
reversion

mirror Perfect-WebSockets
tee Package.swift << EOF >> /dev/null
import PackageDescription
let package = Package(name: "PerfectWebSockets", targets: [],
	dependencies: [
		.Package(url: "$HUB/Perfect-HTTP", majorVersion: 3),
		.Package(url: "$HUB/Perfect-Crypto", majorVersion: 3),
	])
EOF
reversion

mirror Perfect-CZlib-src
cd PerfectCZlib
rm -rf amiga contrib doc examples msdoc nintendods old os400 qnx test watcom win32
cd ..
tee Package.swift << EOF >> /dev/null
import PackageDescription
let package = Package(name: "PerfectCZlib", targets: [],dependencies:  [],
 		exclude: ["contrib", "test", "examples"]
)
EOF
reversion

mirror Perfect-Zip
tee Package.swift << EOF >> /dev/null
import PackageDescription
let package = Package(name: "PerfectZip", targets: [
		Target(name: "minizip", dependencies: []),
		Target(name: "PerfectZip", dependencies: ["minizip"]),
	],
	dependencies: [
		.Package(url: "$HUB/Perfect", majorVersion: 3),
		.Package(url: "$HUB/Perfect-CZlib-src", majorVersion: 0),
	])
EOF
reversion

mirror Perfect-HTTPServer
tee Package.swift << EOF >> /dev/null
import PackageDescription
let package = Package(name: "PerfectHTTPServer",
	targets: [
		Target(name: "PerfectCHTTPParser", dependencies: []),
		Target(name: "PerfectHTTPServer", dependencies: ["PerfectCHTTPParser"]),
	],
	dependencies: [
		.Package(url: "$HUB/Perfect-Net", majorVersion: 3),
		.Package(url: "$HUB/Perfect-HTTP", majorVersion: 3),
		.Package(url: "$HUB/Perfect-CZlib-src", majorVersion: 0)
	])
EOF
reversion

mirror Perfect-libcurl
reversion

mirror Perfect-CURL
tee Package.swift << EOF >> /dev/null
import PackageDescription
let package = Package(name: "PerfectCURL", targets: [],
	dependencies: [
		.Package(url: "$HUB/Perfect-libcurl", majorVersion: 2),
		.Package(url: "$HUB/Perfect-HTTP", majorVersion: 3),
	])
EOF
reversion

mirror_ex SwiftMoment iamjono
rm -rf *.playground *.xcodeproj Tests *.md
reversion

mirror Perfect-Logger
tee Package.swift << EOF >> /dev/null
import PackageDescription
let package = Package(name: "PerfectLogger",targets: [],
	dependencies: [
		.Package(url: "$HUB/Perfect", majorVersion: 3),
		.Package(url: "$HUB/SwiftMoment", majorVersion: 1),
		.Package(url: "$HUB/Perfect-CURL", majorVersion: 3),
	])
EOF
reversion

mirror_ex JSONConfig iamjono
tee Package.swift << EOF >> /dev/null
import PackageDescription
let package = Package(name: "JSONConfig", targets: [],
    dependencies: [
        .Package(url: "$HUB/Perfect", majorVersion: 3)
	])
EOF
reversion

mirror_ex SwiftRandom iamjono
reversion

mirror Perfect-RequestLogger
tee Package.swift << EOF >> /dev/null
import PackageDescription
let package = Package(name: "PerfectRequestLogger", targets: [],
	dependencies: [
		.Package(url: "$HUB/Perfect-Logger", majorVersion: 3),
		.Package(url: "$HUB/Perfect-HTTPServer", majorVersion: 3),
		.Package(url: "$HUB/SwiftRandom", majorVersion: 0),
	])
EOF
reversion

mirror Perfect-Mustache
tee Package.swift << EOF >> /dev/null
import PackageDescription
let package = Package(name: "PerfectMustache", targets: [],
	dependencies: [
		.Package(url: "$HUB/Perfect-HTTP", majorVersion: 3),
	])
EOF
reversion

mirror Perfect-SMTP
tee Package.swift << EOF >> /dev/null
import PackageDescription
let package = Package(name: "PerfectSMTP", dependencies: [
    .Package(url: "$HUB/Perfect-CURL", majorVersion: 3)
  ])
EOF
reversion

mirror Perfect-libpq
reversion

mirror Perfect-libpq-linux
reversion

mirror Perfect-PostgreSQL
tee Package.swift << EOF >> /dev/null
import PackageDescription
#if os(OSX)
let url = "$HUB/Perfect-libpq"
#else
let url = "$HUB/Perfect-libpq-linux"
#endif
let package = Package(name: "PerfectPostgreSQL", targets: [],
    dependencies: [
        .Package(url: url, majorVersion: 2)
    ])
EOF
reversion

mirror Perfect-sqlite3-support
reversion

mirror Perfect-SQLite
tee Package.swift << EOF >> /dev/null
import PackageDescription
let package = Package(name: "PerfectSQLite", targets: [],
    dependencies: [
        .Package(url: "$HUB/Perfect-sqlite3-support", majorVersion: 3)
    ])
EOF
reversion

mirror Perfect-mysqlclient
reversion

mirror Perfect-mysqlclient-Linux
reversion

mirror Perfect-MySQL
tee Package.swift << EOF >> /dev/null
import PackageDescription
#if os(OSX)
let url = "$HUB/Perfect-mysqlclient"
#else
let url = "$HUB/Perfect-mysqlclient-Linux"
#endif
let package = Package(name: "PerfectMySQL", targets: [],
    dependencies: [
        .Package(url: url, majorVersion: 2)
    ])
EOF
reversion

mirror Perfect-mariadbclient
reversion

mirror Perfect-mariadbclient-Linux
reversion

mirror Perfect-MariaDB
tee Package.swift << EOF >> /dev/null
import PackageDescription
#if os(OSX)
let url = "$HUB/Perfect-mariadbclient"
#else
let url = "$HUB/Perfect-mariadbclient-Linux"
#endif
let package = Package(name: "MariaDB", targets: [],
    dependencies: [
        .Package(url: url, majorVersion: 2)
    ])
EOF
reversion

mirror Perfect-Redis
tee Package.swift << EOF >> /dev/null
import PackageDescription
let package = Package(name: "PerfectRedis", targets: [],
    dependencies: [
        .Package(url: "$HUB/Perfect-Net", majorVersion: 3)
    ])
EOF
reversion

mirror Perfect-mongo-c
pushd .
MONGOC_VER=$(brew info mongo-c-driver|awk '$1=="mongo-c-driver:" {print $3}')
cd /usr/local/include
ln -s /usr/local/Cellar/mongo-c-driver/$MONGOC_VER/include/libmongoc-1.0
ln -s /usr/local/Cellar/mongo-c-driver/$MONGOC_VER/include/libbson-1.0
popd
reversion

mirror Perfect-mongo-c-linux
tee module.modulemap << EOF >> /dev/null
module libmongoc {
    header "/usr/include/libbson-1.0/bson.h"
    header "/usr/include/libmongoc-1.0/mongoc.h"
    link "mongoc-1.0"
    export *
}
EOF
reversion

mirror Perfect-MongoDB
tee Package.swift << EOF >> /dev/null
import PackageDescription
#if os(OSX)
let url = "$HUB/Perfect-mongo-c"
#else
let url = "$HUB/Perfect-mongo-c-linux"
#endif
let package = Package(
name: "PerfectMongoDB", targets: [],
    dependencies: [
        .Package(url: url, majorVersion: 2),
        .Package(url: "$HUB/Perfect", majorVersion: 3)
    ],
    exclude: ["Sources/libmongoc"])
EOF
reversion

mirror_ex SwiftString iamjono
rm -rf *.xcodeproj
rm -rf .swift-version
rm -rf .travis.yml
rm -rf *.podspec
reversion

mirror Perfect-CouchDB
tee Package.swift << EOF >> /dev/null
import PackageDescription
let package = Package(name: "PerfectCouchDB", targets: [],
	dependencies: [
		.Package(url: "$HUB/Perfect-HTTP", majorVersion: 3),
		.Package(url: "$HUB/Perfect-CURL", majorVersion: 3),
		.Package(url: "$HUB/SwiftString", majorVersion: 2),
	]
)
EOF
reversion

mirror Perfect-Hadoop
tee Package.swift << EOF >> /dev/null
import PackageDescription
let package = Package(name: "PerfectHadoop", targets: [],
	dependencies: [
		.Package(url: "$HUB/Perfect-HTTP", majorVersion: 3),
		.Package(url: "$HUB/Perfect-CURL", majorVersion: 3)
	]
)
EOF
reversion

mirror Perfect-WebRedirects
tee Package.swift << EOF >> /dev/null
import PackageDescription
let package = Package(name: "PerfectWebRedirects", targets: [],
	dependencies: [
		.Package(url: "$HUB/Perfect-HTTPServer", majorVersion: 3),
		.Package(url: "$HUB/Perfect-Logger", majorVersion: 3),
		.Package(url: "$HUB/SwiftString", majorVersion: 2)
	]
)
EOF
reversion

mirror Perfect-Repeater
reversion

mirror Perfect-libxml2
reversion

mirror Perfect-XML
tee Package.swift << EOF >> /dev/null
import PackageDescription
let package = Package( name: "PerfectXML", dependencies:[
      .Package(url: "$HUB/Perfect-libxml2", majorVersion: 2)
    ])
EOF
reversion

mirror Perfect-FileMaker
tee Package.swift << EOF >> /dev/null
import PackageDescription
let package = Package( name: "PerfectFileMaker", dependencies:[
      .Package(url: "$HUB/Perfect-XML", majorVersion: 3),
      .Package(url: "$HUB/Perfect-CURL", majorVersion: 3)
    ])
EOF
reversion

mirror Perfect-Notifications
tee Package.swift << EOF >> /dev/null
import PackageDescription
let package = Package( name: "PerfectNotifications", dependencies:[
      .Package(url: "$HUB/Perfect-HTTPServer", majorVersion: 3)
    ])
EOF
reversion

mirror Perfect-libSASL
reversion

mirror_ex Perfect-ICONV PerfectSideRepos
reversion

mirror Perfect-OpenLDAP
reversion

mirror Perfect-LDAP
tee Package.swift << EOF >> /dev/null
import PackageDescription
let package = Package(name: "PerfectLDAP", targets: [], 
		dependencies: [
        .Package(url: "$HUB/Perfect-ICONV", majorVersion: 3),
        .Package(url: "$HUB/Perfect-libSASL", majorVersion: 1),
        .Package(url: "$HUB/Perfect-OpenLDAP", majorVersion: 1)
    ])
EOF
reversion

mirror Perfect-Markdown
reversion

mirror Perfect-Python
reversion

mirror Perfect-libKafka
reversion

mirror Perfect-Kafka
tee Package.swift << EOF >> /dev/null
import PackageDescription
#if os(Linux)
let package = Package( name: "PerfectKafka", dependencies:[
      .Package(url: "$HUB/Perfect-LinuxBridge", majorVersion: 3),
      .Package(url: "$HUB/Perfect-libKafka", majorVersion: 1)
    ])
#else
let package = Package( name: "PerfectKafka", dependencies:[
      .Package(url: "$HUB/Perfect-libKafka", majorVersion: 1)
    ])
#endif
EOF
reversion

mirror Perfect-libMosquitto
reversion

mirror Perfect-Mosquitto
tee Package.swift << EOF >> /dev/null
import PackageDescription
#if os(Linux)
let package = Package( name: "PerfectMosquitto", dependencies:[
      .Package(url: "$HUB/Perfect-LinuxBridge", majorVersion: 3),
      .Package(url: "$HUB/Perfect-libMosquitto", majorVersion: 1)
    ])
#else
let package = Package( name: "PerfectMosquitto", dependencies:[
      .Package(url: "$HUB/Perfect-libMosquitto", majorVersion: 1)
    ])
#endif
EOF
reversion

mirror_ex StORM SwiftORM
tee Package.swift << EOF >> /dev/null
import PackageDescription
let package = Package( name: "StORM", targets: [],
	dependencies: [
		.Package(url: "$HUB/Perfect", majorVersion: 3),
	])
EOF
reversion

mirror_ex SQLite-StORM SwiftORM
tee Package.swift << EOF >> /dev/null
import PackageDescription
let package = Package( name: "SQLiteStORM", targets: [],
	dependencies: [
		.Package(url: "$HUB/StORM", majorVersion: 3),
		.Package(url: "$HUB/Perfect-SQLite", majorVersion: 3),
		.Package(url: "$HUB/Perfect-Logger", majorVersion: 3),
	])
EOF
reversion

mirror_ex MySQL-StORM SwiftORM
tee Package.swift << EOF >> /dev/null
import PackageDescription
let package = Package( name: "MySQLStORM", targets: [],
	dependencies: [
		.Package(url: "$HUB/StORM", majorVersion: 3),
		.Package(url: "$HUB/Perfect-MySQL", majorVersion: 3),
		.Package(url: "$HUB/Perfect-Logger", majorVersion: 3),
	])
EOF
reversion

mirror_ex MongoDB-StORM SwiftORM
tee Package.swift << EOF >> /dev/null
import PackageDescription
let package = Package( name: "MongoDBStORM", targets: [],
	dependencies: [
		.Package(url: "$HUB/StORM", majorVersion: 3),
		.Package(url: "$HUB/Perfect-MongoDB", majorVersion: 3),
		.Package(url: "$HUB/Perfect-Logger", majorVersion: 3),
		.Package(url: "$HUB/SwiftRandom", majorVersion: 0)
	])
EOF
reversion

mirror_ex CouchDB-StORM SwiftORM
tee Package.swift << EOF >> /dev/null
import PackageDescription
let package = Package( name: "CouchDBStORM", targets: [],
	dependencies: [
		.Package(url: "$HUB/StORM", majorVersion: 3),
		.Package(url: "$HUB/Perfect-CouchDB", majorVersion: 3),
		.Package(url: "$HUB/Perfect-Logger", majorVersion: 3),
		.Package(url: "$HUB/SwiftRandom", majorVersion: 0)
	])
EOF
reversion

mirror_ex Postgres-StORM SwiftORM
tee Package.swift << EOF >> /dev/null
import PackageDescription
let package = Package( name: "PostgresStORM", targets: [],
	dependencies: [
		.Package(url: "$HUB/StORM", majorVersion: 3),
		.Package(url: "$HUB/Perfect-PostgreSQL", majorVersion: 3),
		.Package(url: "$HUB/Perfect-Logger", majorVersion: 3),
		.Package(url: "$HUB/Perfect-XML", majorVersion: 3)
	])
EOF
reversion

mirror Perfect-Session
tee Package.swift << EOF >> /dev/null
import PackageDescription
let package = Package( name: "PerfectSession", targets: [],
	dependencies: [
		.Package(url: "$HUB/Perfect-HTTPServer", majorVersion: 3),
		.Package(url: "$HUB/Perfect-Logger", majorVersion: 3),
		.Package(url: "$HUB/Perfect-Repeater", majorVersion: 1),
		.Package(url: "$HUB/SwiftString", majorVersion: 2),
	]
)
EOF
reversion

mirror Perfect-Session-MySQL
tee Package.swift << EOF >> /dev/null
import PackageDescription
let package = Package(name: "PerfectSessionMySQL", targets: [],
	dependencies: [
		.Package(url: "$HUB/Perfect-Session", majorVersion: 3),
		.Package(url: "$HUB/Perfect-MySQL", majorVersion: 3),
	]
)
EOF
reversion

mirror Perfect-Session-PostgreSQL
tee Package.swift << EOF >> /dev/null
import PackageDescription
let package = Package(name: "PerfectSessionPostgreSQL",targets: [],
	dependencies: [
		.Package(url: "$HUB/Perfect-Session", majorVersion: 3),
		.Package(url: "$HUB/Perfect-PostgreSQL", majorVersion: 3),
	])
EOF
reversion

mirror Perfect-Session-Redis
tee Package.swift << EOF >> /dev/null
import PackageDescription
let package = Package(name: "PerfectSessionRedis", targets: [],
	dependencies: [
		.Package(url: "$HUB/Perfect-Session", majorVersion: 3),
		.Package(url: "$HUB/Perfect-Redis", majorVersion: 3),
	])
EOF
reversion

mirror Perfect-Session-MongoDB
tee Package.swift << EOF >> /dev/null
import PackageDescription
let package = Package(name: "PerfectSessionMongoDB",targets: [],
	dependencies: [
		.Package(url: "$HUB/Perfect-Session", majorVersion: 3),
		.Package(url: "$HUB/MongoDB-StORM", majorVersion: 3),
	])
EOF
reversion

mirror Perfect-Session-SQLite
tee Package.swift << EOF >> /dev/null
import PackageDescription
let package = Package(name: "PerfectSessionSQLite",targets: [],
	dependencies: [
		.Package(url: "$HUB/Perfect-Session", majorVersion: 3),
		.Package(url: "$HUB/SQLite-StORM", majorVersion: 3),
	])
EOF
reversion

mirror Perfect-Session-CouchDB
tee Package.swift << EOF >> /dev/null
import PackageDescription
let package = Package(name: "PerfectSessionCouchDB",targets: [],
	dependencies: [
		.Package(url: "$HUB/Perfect-Session", majorVersion: 3),
		.Package(url: "$HUB/CouchDB-StORM", majorVersion: 3),
	])
EOF
reversion

mirror_ex Turnstile stormpath
reversion

mirror_ex Turnstile-Perfect PerfectSideRepos
tee Package.swift << EOF >> /dev/null
import PackageDescription
let package = Package(name: "TurnstilePerfect", targets: [],
	dependencies: [
		.Package(url: "$HUB/Perfect-HTTP", majorVersion: 3),
		.Package(url: "$HUB/Turnstile", majorVersion: 1),
		.Package(url: "$HUB/Perfect-Mustache", majorVersion: 3),
		.Package(url: "$HUB/SwiftString", majorVersion: 2)
	])
EOF
reversion

mirror Perfect-Turnstile-SQLite
tee Package.swift << EOF >> /dev/null
import PackageDescription
let package = Package(name: "PerfectTurnstileSQLite",	targets: [],
	dependencies: [
		.Package(url: "$HUB/SQLite-StORM", majorVersion: 3),
		.Package(url: "$HUB/Perfect-HTTPServer", majorVersion: 3),
		.Package(url: "$HUB/Perfect-Mustache", majorVersion: 3),
		.Package(url: "$HUB/SwiftString", majorVersion: 2),
		.Package(url: "$HUB/SwiftRandom", majorVersion: 0),
		.Package(url: "$HUB/Turnstile-Perfect", majorVersion: 3),
		.Package(url: "$HUB/Perfect-RequestLogger", majorVersion: 3),
	])
EOF
reversion

mirror Perfect-Turnstile-MySQL
tee Package.swift << EOF >> /dev/null
import PackageDescription
let package = Package(name: "PerfectTurnstileMySQL",	targets: [],
	dependencies: [
		.Package(url: "$HUB/MySQL-StORM", majorVersion: 3),
		.Package(url: "$HUB/Perfect-HTTPServer", majorVersion: 3),
		.Package(url: "$HUB/Perfect-Mustache", majorVersion: 3),
		.Package(url: "$HUB/SwiftRandom", majorVersion: 0),
		.Package(url: "$HUB/Turnstile-Perfect", majorVersion: 3),
	])
EOF
reversion

mirror Perfect-Turnstile-PostgreSQL
tee Package.swift << EOF >> /dev/null
import PackageDescription
let package = Package(name: "PerfectTurnstilePostgreSQL",	targets: [],
	dependencies: [
		.Package(url: "$HUB/Postgres-StORM", majorVersion: 3),
		.Package(url: "$HUB/Perfect-HTTPServer", majorVersion: 3),
		.Package(url: "$HUB/Perfect-Mustache", majorVersion: 3),
		.Package(url: "$HUB/SwiftString", majorVersion: 2),
		.Package(url: "$HUB/SwiftRandom", majorVersion: 0),
		.Package(url: "$HUB/Turnstile-Perfect", majorVersion: 3),
	])
EOF
reversion

mirror Perfect-Turnstile-MongoDB
tee Package.swift << EOF >> /dev/null
import PackageDescription
let package = Package(name: "PerfectTurnstileMongoDB",	targets: [],
	dependencies: [
		.Package(url: "$HUB/MongoDB-StORM", majorVersion: 3),
		.Package(url: "$HUB/Perfect-HTTPServer", majorVersion: 3),
		.Package(url: "$HUB/Perfect-Mustache", majorVersion: 3),
		.Package(url: "$HUB/SwiftString", majorVersion: 2),
		.Package(url: "$HUB/SwiftRandom", majorVersion: 0),
		.Package(url: "$HUB/Turnstile-Perfect", majorVersion: 3),
	])
EOF
reversion

mirror Perfect-Turnstile-CouchDB
tee Package.swift << EOF >> /dev/null
import PackageDescription
let package = Package(name: "PerfectTurnstileCouchDB",	targets: [],
	dependencies: [
		.Package(url: "$HUB/CouchDB-StORM", majorVersion: 3),
		.Package(url: "$HUB/Perfect-HTTPServer", majorVersion: 3),
		.Package(url: "$HUB/Perfect-Mustache", majorVersion: 3),
		.Package(url: "$HUB/SwiftString", majorVersion: 2),
		.Package(url: "$HUB/SwiftRandom", majorVersion: 0),
		.Package(url: "$HUB/Turnstile-Perfect", majorVersion: 3),
	])
EOF
reversion

mirror PerfectTemplate
tee Package.swift << EOF >> /dev/null
import PackageDescription
let package = Package(name: "PerfectTemplate", targets: [],
	dependencies: [
		.Package(url: "$HUB/Perfect-HTTPServer", majorVersion: 3),
	])
EOF
reversion

# Clean up
popd

printf "\n\x1b[1mNow Perfect local mirros are ready: /tmp/perfect\x1b[0m\n"
