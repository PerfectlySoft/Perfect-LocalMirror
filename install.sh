clear
HUB=/private/var/perfect
pushd .
sudo rm -rf $HUB
sudo mkdir -p $HUB
sudo chown $USER $HUB

function mirror_ex() {
	cd $HUB
	REPO=$1
	VEND=$2
	RELEASES=$VEND/$REPO/releases
	TAGS=/$RELEASES/tag/
	GITHUB=https://github.com
	LATEST=$(curl -s $GITHUB/$VEND/$REPO/tags | grep $TAGS | head -n 1 | \
	sed $'s/[\"|\<|\>|\/]/\\\n/g' | egrep '[0-9]+.[0-9]+.[0-9]' | head -n 1)
	echo "Caching $VEND/$REPO:$LATEST"
	curl -s -L "$GITHUB/$VEND/$REPO/archive/$LATEST.tar.gz" -o /tmp/a.tgz
	tar xzf /tmp/a.tgz
	rm -rf /tmp/a.tgz
	#chown $USER $REPO-$LATEST
	mv $REPO-$LATEST $REPO
	cd $REPO
}

function mirror() {
	mirror_ex $1 PerfectlySoft
}

function reversion() {
	rm -rf .git Tests
	git init >> /dev/null
	git add *  >> /dev/null
	git commit -m "slim"  >> /dev/null
	VERSION=$(git log|awk '$1=="commit" {print $2}')
	git tag $LATEST $VERSION  >> /dev/null
}

function repath() {
	REPO=$1
	mkdir Sources/$REPO
	mv Sources/*.swift Sources/$REPO
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
// swift-tools-version:4.0
import PackageDescription
let package = Package(name: "PerfectHTTPServer", 
	products: [.library(name: "PerfectHTTPServer",targets: ["PerfectHTTPServer"]),],
    dependencies: [
		.package(url: "$HUB/Perfect-Net", .branch("master")),
		.package(url: "$HUB/Perfect-HTTP", .branch("master")),
		.package(url: "$HUB/Perfect-CZlib-src", .branch("master"))
    ],
    targets: [
        .target(
            name: "PerfectCHTTPParser",
            dependencies: []),
        .target(
            name: "PerfectHTTPServer",
            dependencies: ["PerfectNet", "PerfectHTTP", "PerfectCHTTPParser", "PerfectCZlib"]),
    ])
EOF
reversion

mirror Perfect-libcurl
reversion

mirror Perfect-CURL
repath PerfectCURL
tee Package.swift << EOF >> /dev/null
// swift-tools-version:4.0
import PackageDescription
let package = Package(name: "PerfectCURL", 
	products: [.library(name: "PerfectCURL",targets: ["PerfectCURL"]),],
    dependencies: [
		.package(url: "$HUB/Perfect-libcurl", .branch("master")),
		.package(url: "$HUB/Perfect-HTTP", .branch("master")),
    ],
    targets: [
        .target(
            name: "PerfectCURL",
            dependencies: ["PerfectHTTP"]),
    ])
EOF
reversion

mirror_ex SwiftMoment iamjono
rm -rf *.playground *.xcodeproj Tests *.md
reversion

mirror Perfect-Logger
tee Package.swift << EOF >> /dev/null
// swift-tools-version:4.0
import PackageDescription
let package = Package(name: "PerfectLogger", 
	products: [.library(name: "PerfectLogger",targets: ["PerfectLogger"]),],
    dependencies: [
		.package(url: "$HUB/Perfect-CURL", .branch("master")),
	],
    targets: [
        .target(
            name: "PerfectLogger",
            dependencies: ["PerfectCURL"]),
    ])
EOF
reversion

mirror_ex JSONConfig iamjono
repath JSONConfig
tee Package.swift << EOF >> /dev/null
// swift-tools-version:4.0
import PackageDescription
let package = Package(name: "JSONConfig", 
	products: [.library(name: "JSONConfig",targets: ["JSONConfig"]),],
    dependencies: [
		.package(url: "$HUB/Perfect", .branch("master")),
	],
    targets: [
        .target(
            name: "JSONConfig",
            dependencies: ["PerfectLib"]),
    ])
EOF
reversion

mirror_ex SwiftRandom iamjono
reversion

mirror Perfect-RequestLogger
tee Package.swift << EOF >> /dev/null
// swift-tools-version:4.0
import PackageDescription
let package = Package(name: "PerfectRequestLogger", 
	products: [.library(name: "PerfectRequestLogger",targets: ["PerfectRequestLogger"]),],
    dependencies: [
		.package(url: "$HUB/Perfect-Logger", .branch("master")),
	],
    targets: [
        .target(
            name: "PerfectRequestLogger",
            dependencies: ["PerfectLogger"]),
    ])
EOF
reversion

mirror Perfect-Mustache
repath PerfectMustache
tee Package.swift << EOF >> /dev/null
// swift-tools-version:4.0
import PackageDescription
let package = Package(name: "PerfectMustache", 
	products: [.library(name: "PerfectMustache",targets: ["PerfectMustache"]),],
    dependencies: [
		.package(url: "$HUB/Perfect-HTTP", .branch("master")),
	],
    targets: [
        .target(
            name: "PerfectMustache",
            dependencies: ["PerfectHTTP"]),
    ])
EOF
reversion

mirror Perfect-SMTP
tee Package.swift << EOF >> /dev/null
// swift-tools-version:4.0
import PackageDescription
let package = Package(name: "PerfectSMTP", 
	products: [.library(name: "PerfectSMTP",targets: ["PerfectSMTP"]),],
    dependencies: [
		.package(url: "$HUB/Perfect-CURL", .branch("master")),
	],
    targets: [
        .target(
            name: "PerfectSMTP",
            dependencies: ["PerfectCURL"]),
    ])
EOF
reversion

mirror Perfect-libpq
reversion

mirror Perfect-libpq-linux
reversion

mirror Perfect-CRUD
reversion

mirror Perfect-PostgreSQL
tee Package.swift << EOF >> /dev/null
// swift-tools-version:4.0
import PackageDescription
#if os(OSX)
let client_url = "$HUB/Perfect-libpq"
#else
let client_url = "$HUB/Perfect-libpq-linux"
#endif
let package = Package(name: "PerfectPostgreSQL", 
	products: [.library(name: "PerfectPostgreSQL",targets: ["PerfectPostgreSQL"]),],
    dependencies: [
      .package(url: "$HUB/Perfect-CRUD", .branch("master")),
      .package(url: client_url, .branch("master"))
    ],
    targets: [
        .target(
            name: "PerfectPostgreSQL",
            dependencies: ["PerfectCRUD"]),
    ])
EOF
reversion

mirror Perfect-sqlite3-support
reversion

mirror Perfect-SQLite
tee Package.swift << EOF >> /dev/null
// swift-tools-version:4.0
import PackageDescription
let package = Package(name: "PerfectSQLite", 
	products: [.library(name: "PerfectSQLite",targets: ["PerfectSQLite"]),],
    dependencies: [
      .package(url: "$HUB/Perfect-CRUD", .branch("master")),
      .package(url: "$HUB/Perfect-sqlite3-support", .branch("master"))
    ],
    targets: [
        .target(
            name: "PerfectSQLite",
            dependencies: ["PerfectCRUD"]),
    ])
EOF
reversion

mirror Perfect-mysqlclient
reversion

mirror Perfect-mysqlclient-Linux
reversion

mirror Perfect-MySQL
tee Package.swift << EOF >> /dev/null
// swift-tools-version:4.0
import PackageDescription
#if os(OSX)
let client_url = "$HUB/Perfect-mysqlclient"
#else
let client_url = "$HUB/Perfect-mysqlclient-Linux"
#endif
let package = Package(name: "PerfectMySQL", 
	products: [.library(name: "PerfectMySQL",targets: ["PerfectMySQL"]),],
    dependencies: [
      .package(url: "$HUB/Perfect-CRUD", .branch("master")),
      .package(url: client_url, .branch("master"))
    ],
    targets: [
        .target(
            name: "PerfectMySQL",
            dependencies: ["PerfectCRUD"]),
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

mirror_ex Perfect-CBSON PerfectSideRepos
tee Package.swift << EOF >> /dev/null
import PackageDescription
let package = Package(
	name: "PerfectCBSON",
	pkgConfig: "libbson-1.0",
	providers: [
		.Brew("mongo-c-driver"),
		.Apt("libbson-dev"),
	]
)
EOF
reversion

mirror_ex Perfect-CMongo PerfectSideRepos
tee Package.swift << EOF >> /dev/null
import PackageDescription
let package = Package(
	name: "PerfectCMongo",
	pkgConfig: "libmongoc-1.0",
	providers: [
		.Brew("mongo-c-driver"),
		.Apt("libbson-dev"),
	],
	dependencies: 
	[.Package(url: "$HUB/Perfect-CBSON", majorVersion: 0)]
)
EOF
reversion

mirror Perfect-MongoDB
tee Package.swift << EOF >> /dev/null
import PackageDescription
let package = Package(
name: "PerfectMongoDB", targets: [],
    dependencies: [
        .Package(url: "$HUB/Perfect-CBSON", majorVersion: 0),
				.Package(url: "$HUB/Perfect-CMongo", majorVersion: 0),
        .Package(url: "$HUB/Perfect", majorVersion: 3)
    ])
EOF
reversion

mirror_ex SwiftString iamjono
rm -rf *.xcodeproj
rm -rf .swift-version
rm -rf .travis.yml
rm -rf *.podspec
reversion

mirror Perfect-CouchDB
repath PerfectCouchDB
tee Package.swift << EOF >> /dev/null
// swift-tools-version:4.0
import PackageDescription
let package = Package(name: "PerfectCouchDB", 
	products: [.library(name: "PerfectCouchDB",targets: ["PerfectCouchDB"]),],
    dependencies: [
		.package(url: "$HUB/Perfect-CURL", .branch("master")),
		.package(url: "$HUB/SwiftString", .branch("master")),
	],
    targets: [
        .target(
            name: "PerfectCouchDB",
            dependencies: ["PerfectCURL"]),
    ])
EOF
reversion

mirror Perfect-Hadoop
repath PerfectHadoop
tee Package.swift << EOF >> /dev/null
// swift-tools-version:4.0
import PackageDescription
let package = Package(name: "PerfectHadoop", 
	products: [.library(name: "PerfectHadoop",targets: ["PerfectHadoop"]),],
    dependencies: [
		.package(url: "$HUB/Perfect-CURL", .branch("master")),
	],
    targets: [
        .target(
            name: "PerfectHadoop",
            dependencies: ["PerfectCURL"]),
    ])
EOF
reversion

mirror Perfect-WebRedirects
tee Package.swift << EOF >> /dev/null
// swift-tools-version:4.0
import PackageDescription
let package = Package(name: "PerfectWebRedirects", 
	products: [.library(name: "PerfectWebRedirects",targets: ["PerfectWebRedirects"]),],
    dependencies: [
		.package(url: "$HUB/Perfect-Logger", .branch("master")),
	],
    targets: [
        .target(
            name: "PerfectWebRedirects",
            dependencies: ["PerfectLogger"]),
    ])
EOF
reversion

mirror Perfect-Repeater
reversion

mirror Perfect-libxml2
reversion

mirror Perfect-XML
tee Package.swift << EOF >> /dev/null
// swift-tools-version:4.0
import PackageDescription
let package = Package(name: "PerfectXML", 
	products: [.library(name: "PerfectXML",targets: ["PerfectXML"]),],
    dependencies: [
		.package(url: "$HUB/Perfect-libxml2", .branch("master")),
	],
    targets: [
        .target(
            name: "PerfectXML",
            dependencies: []),
    ])
EOF
reversion

mirror Perfect-FileMaker
repath PerfectFileMaker
tee Package.swift << EOF >> /dev/null
// swift-tools-version:4.0
import PackageDescription
let package = Package(name: "PerfectFileMaker", 
	products: [.library(name: "PerfectFileMaker",targets: ["PerfectFileMaker"]),],
    dependencies: [
		.package(url: "$HUB/Perfect-XML", .branch("master")),
		.package(url: "$HUB/Perfect-CURL", .branch("master")),
	],
    targets: [
        .target(
            name: "PerfectFileMaker",
            dependencies: ["PerfectXML", "PerfectCURL"]),
    ])
EOF
reversion

mirror Perfect-Notifications
tee Package.swift << EOF >> /dev/null
import PackageDescription
let package = Package( name: "PerfectNotifications", dependencies:[
      .Package(url: "$HUB/Perfect-HTTPServer", majorVersion: 3)
    ])
// swift-tools-version:4.0
import PackageDescription
let package = Package(name: "PerfectNotifications", 
	products: [.library(name: "PerfectNotifications",targets: ["PerfectNotifications"]),],
    dependencies: [
		.package(url: "$HUB/Perfect-HTTPServer", .branch("master")),
	],
    targets: [
        .target(
            name: "PerfectNotifications",
            dependencies: ["PerfectHTTPServer"]),
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
		.Package(url: "$HUB/SwiftMoment", majorVersion: 1),
		.Package(url: "$HUB/SwiftString", majorVersion: 2),
	])
EOF
reversion

mirror_ex SQLite-StORM SwiftORM
repath SQLiteStORM
tee Package.swift << EOF >> /dev/null
// swift-tools-version:4.0
import PackageDescription
let package = Package( name: "SQLiteStORM", 
	products: [.library(name: "SQLiteStORM",targets: ["SQLiteStORM"]),],
	dependencies: [
		.package(url: "$HUB/StORM", .branch("master")),
		.package(url: "$HUB/Perfect-SQLite", .branch("master")),
		.package(url: "$HUB/Perfect-Logger", .branch("master")),
	],
	targets:[
        .target(
            name: "SQLiteStORM",
            dependencies: ["StORM", "PerfectSQLite", "PerfectLogger"]),
	])
EOF
reversion

mirror_ex MySQL-StORM SwiftORM
repath MySQLStORM
tee Package.swift << EOF >> /dev/null
// swift-tools-version:4.0
import PackageDescription
let package = Package( name: "MySQLStORM", 
	products: [.library(name: "MySQLStORM",targets: ["MySQLStORM"]),],
	dependencies: [
		.package(url: "$HUB/StORM", .branch("master")),
		.package(url: "$HUB/Perfect-MySQL", .branch("master")),
		.package(url: "$HUB/Perfect-Logger", .branch("master")),
	],
	targets:[
        .target(
            name: "MySQLStORM",
            dependencies: ["StORM", "PerfectMySQL", "PerfectLogger"]),
	])
EOF
reversion

mirror_ex MongoDB-StORM SwiftORM
repath MongoDBStORM
tee Package.swift << EOF >> /dev/null
// swift-tools-version:4.0
import PackageDescription
let package = Package( name: "MongoDBStORM", 
	products: [.library(name: "MongoDBStORM",targets: ["MongoDBStORM"]),],
	dependencies: [
		.package(url: "$HUB/StORM", .branch("master")),
		.package(url: "$HUB/Perfect-MongoDB", .branch("master")),
		.package(url: "$HUB/Perfect-Logger", .branch("master")),
		.package(url: "$HUB/SwiftRandom", .branch("master")),
	],
	targets:[
        .target(
            name: "MongoDBStORM",
            dependencies: ["StORM", "PerfectMongoDB", "PerfectLogger", "SwiftRandom"]),
	])
EOF
reversion

mirror_ex CouchDB-StORM SwiftORM
tee Package.swift << EOF >> /dev/null
// swift-tools-version:4.0
import PackageDescription
let package = Package( name: "CouchDBStORM", 
	products: [.library(name: "CouchDBStORM",targets: ["CouchDBStORM"]),],
	dependencies: [
		.package(url: "$HUB/StORM", .branch("master")),
		.package(url: "$HUB/Perfect-MongoDB", .branch("master")),
		.package(url: "$HUB/Perfect-Logger", .branch("master")),
		.package(url: "$HUB/SwiftRandom", .branch("master")),
	],
	targets:[
        .target(
            name: "CouchDBStORM",
            dependencies: ["StORM", "PerfectMongoDB", "PerfectLogger", "SwiftRandom"]),
	])
EOF
reversion

mirror_ex Postgres-StORM SwiftORM
repath PostgresStORM
tee Package.swift << EOF >> /dev/null
// swift-tools-version:4.0
import PackageDescription
let package = Package( name: "PostgresStORM", 
	products: [.library(name: "PostgresStORM",targets: ["PostgresStORM"]),],
	dependencies: [
		.package(url: "$HUB/StORM", .branch("master")),
		.package(url: "$HUB/Perfect-PostgreSQL", .branch("master")),
		.package(url: "$HUB/Perfect-Logger", .branch("master")),
	],
	targets:[
        .target(
            name: "PostgresStORM",
            dependencies: ["StORM", "PerfectPostgreSQL", "PerfectLogger"]),
	])
EOF
reversion

mirror Perfect-Session
tee Package.swift << EOF >> /dev/null
// swift-tools-version:4.0
import PackageDescription
let package = Package( name: "PerfectSession", 
	products: [.library(name: "PerfectSession",targets: ["PerfectSession"]),],
	dependencies: [
		.package(url: "$HUB/Perfect-Logger", .branch("master")),
	],
	targets:[
        .target(
            name: "PerfectSession",
            dependencies: ["PerfectLogger"]),
	])
EOF
reversion

mirror Perfect-Session-MySQL
repath PerfectSessionMySQL
tee Package.swift << EOF >> /dev/null
// swift-tools-version:4.0
import PackageDescription
let package = Package( name: "PerfectSessionMySQL", 
	products: [.library(name: "PerfectSessionMySQL",targets: ["PerfectSessionMySQL"]),],
	dependencies: [
		.package(url: "$HUB/Perfect-Session", .branch("master")),
		.package(url: "$HUB/Perfect-MySQL", .branch("master")),
	],
	targets:[
        .target(
            name: "PerfectSessionMySQL",
            dependencies: ["PerfectSession", "PerfectMySQL"]),
	])
EOF
reversion

mirror Perfect-Session-PostgreSQL
repath PerfectSessionPostgreSQL
tee Package.swift << EOF >> /dev/null
// swift-tools-version:4.0
import PackageDescription
let package = Package( name: "PerfectSessionPostgreSQL", 
	products: [.library(name: "PerfectSessionPostgreSQL",targets: ["PerfectSessionPostgreSQL"]),],
	dependencies: [
		.package(url: "$HUB/Perfect-Session", .branch("master")),
		.package(url: "$HUB/Perfect-PostgreSQL", .branch("master")),
	],
	targets:[
        .target(
            name: "PerfectSessionPostgreSQL",
            dependencies: ["PerfectSession", "PerfectMySQL"]),
	])
EOF
reversion

mirror Perfect-Session-Redis
repath PerfectSessionRedis
tee Package.swift << EOF >> /dev/null
// swift-tools-version:4.0
import PackageDescription
let package = Package( name: "PerfectSessionRedis", 
	products: [.library(name: "PerfectSessionRedis",targets: ["PerfectSessionRedis"]),],
	dependencies: [
		.package(url: "$HUB/Perfect-Session", .branch("master")),
		.package(url: "$HUB/Perfect-Redis", .branch("master")),
	],
	targets:[
        .target(
            name: "PerfectSessionRedis",
            dependencies: ["PerfectSession", "PerfectMySQL"]),
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
// swift-tools-version:4.0
import PackageDescription
let package = Package( name: "PerfectSessionMongoDB", 
	products: [.library(name: "PerfectSessionMongoDB",targets: ["PerfectSessionMongoDB"]),],
	dependencies: [
		.package(url: "$HUB/Perfect-Session", .branch("master")),
		.package(url: "$HUB/MongoDB-StORM", .branch("master")),
	],
	targets:[
        .target(
            name: "PerfectSessionMongoDB",
            dependencies: ["PerfectSession", "MongoDBStORM"]),
	])
EOF
reversion

mirror Perfect-Session-SQLite
repath PerfectSessionSQLite
tee Package.swift << EOF >> /dev/null
// swift-tools-version:4.0
import PackageDescription
let package = Package( name: "PerfectSessionSQLite", 
	products: [.library(name: "PerfectSessionSQLite",targets: ["PerfectSessionSQLite"]),],
	dependencies: [
		.package(url: "$HUB/Perfect-Session", .branch("master")),
		.package(url: "$HUB/SQLite-StORM", .branch("master")),
	],
	targets:[
        .target(
            name: "PerfectSessionSQLite",
            dependencies: ["PerfectSession", "SQLiteStORM"]),
	])
EOF
reversion

mirror Perfect-Session-CouchDB
repath PerfectSessionCouchDB
tee Package.swift << EOF >> /dev/null
// swift-tools-version:4.0
import PackageDescription
let package = Package( name: "PerfectSessionCouchDB", 
	products: [.library(name: "PerfectSessionCouchDB",targets: ["PerfectSessionCouchDB"]),],
	dependencies: [
		.package(url: "$HUB/Perfect-Session", .branch("master")),
		.package(url: "$HUB/CouchDB-StORM", .branch("master")),
	],
	targets:[
        .target(
            name: "PerfectSessionCouchDB",
            dependencies: ["PerfectSession", "CouchDBStORM"]),
	])
EOF
reversion

mirror Perfect-OAuth2
tee Package.swift << EOF >> /dev/null
// swift-tools-version:4.0
import PackageDescription
let package = Package( name: "OAuth2", 
	products: [.library(name: "OAuth2",targets: ["OAuth2"]),],
	dependencies: [
		.package(url: "$HUB/Perfect-Session", .branch("master")),
	],
	targets:[
        .target(
            name: "OAuth2",
            dependencies: ["PerfectSession"]),
	])
EOF
reversion

mirror Perfect-LocalAuthentication-PostgreSQL
tee Package.swift << EOF >> /dev/null
// swift-tools-version:4.0
import PackageDescription
let package = Package(name: "PerfectLocalAuthentication", 
	products: [.library(name: "PerfectLocalAuthentication",targets: ["PerfectLocalAuthentication"]),],
    dependencies: [
      .package(url: "$HUB/JSONConfig", .branch("master")),
      .package(url: "$HUB/Perfect-RequestLogger", .branch("master")),
      .package(url: "$HUB/Perfect-SMTP", .branch("master")),
      .package(url: "$HUB/lsStORM", .branch("master")),
      .package(url: "$HUB/Perfect-Session-PostgreSQL", .branch("master")),
      .package(url: "$HUB/Perfect-Mustache", .branch("master")),
    ],
    targets: [
        .target(
            name: "PerfectLocalAuthentication",
            dependencies: ["JSONConfig", "PerfectRequestLogger", "PerfectSMTP", "StORM", "PerfectSessionPostgreSQL", "PerfectMustache"]),
    ])
EOF
reversion

mirror Perfect-LocalAuthentication-MySQL
tee Package.swift << EOF >> /dev/null
// swift-tools-version:4.0
import PackageDescription
let package = Package(name: "PerfectLocalAuthentication", 
	products: [.library(name: "PerfectLocalAuthentication",targets: ["PerfectLocalAuthentication"]),],
    dependencies: [
      .package(url: "$HUB/JSONConfig", .branch("master")),
      .package(url: "$HUB/Perfect-RequestLogger", .branch("master")),
      .package(url: "$HUB/Perfect-SMTP", .branch("master")),
      .package(url: "$HUB/StORM", .branch("master")),
      .package(url: "$HUB/Perfect-Session-MySQL", .branch("master")),
      .package(url: "$HUB/Perfect-Mustache", .branch("master")),
    ],
    targets: [
        .target(
            name: "PerfectLocalAuthentication",
            dependencies: ["JSONConfig", "PerfectRequestLogger", "PerfectSMTP", "StORM", "PerfectSessionMySQL", "PerfectMustache"]),
    ])
EOF
reversion

mirror PerfectTemplate
repath PerfectTemplate
tee Package.swift << EOF >> /dev/null
// swift-tools-version:4.0
import PackageDescription
let package = Package(name: "PerfectTemplate", 
	products: [.library(name: "PerfectTemplate",targets: ["PerfectTemplate"]),],
    dependencies: [
      .package(url: "$HUB/Perfect-HTTPServer", .branch("master")),
    ],
    targets: [
        .target(
            name: "PerfectTemplate",
            dependencies: []),
    ])
EOF
reversion

# Clean up
popd

printf "\n\x1b[1mNow Perfect local mirros are ready: \n\n$HUB\x1b[0m\n\n"
