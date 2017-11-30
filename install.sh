clear
HUB=/tmp/perfect
pushd .
rm -rf $HUB
mkdir -p $HUB

function mirror() {
	cd /tmp/perfect
	PERFECT="https://github.com/PerfectlySoft/"
	VERSION=$1
	REPONAME=$2
	REPO="$PERFECT/$REPONAME/archive/$VERSION.tar.gz"
	wget -O /tmp/a.tgz "$REPO"
	tar xzf /tmp/a.tgz
	rm -rf /tmp/a.tgz
	mv $REPONAME-$VERSION $REPONAME
	cd $REPONAME
}

function reversion() {
	VERSION=$1
	rm -rf .git
	git init
	git add *
	git commit -m "slim"
	latest=$(git log|awk '$1=="commit" {print $2}')
	git tag $VERSION $latest
}

# LinuxBridge
VER=3.0.0
mirror $VER Perfect-LinuxBridge
reversion $VER

# PerfectLib
VER=3.0.2
mirror $VER Perfect
tee Package.swift << EOF
import PackageDescription
var urls = [String]()
#if os(Linux)
urls += ["$HUB/Perfect-LinuxBridge"]
#endif
let package = Package(
	name: "PerfectLib",	targets: [],
	dependencies: urls.map { .Package(url: \$0, majorVersion: 3) }
)
EOF
reversion $VER

# Perfect-COpenSSL
VER=3.1.2
mirror $VER Perfect-COpenSSL
reversion $VER

# Perfect-COpenSSL-Linux
VER=3.0.1
mirror $VER Perfect-COpenSSL-Linux
reversion $VER

# Perfect-Perfect-Thread
VER=3.0.2
mirror $VER Perfect-Thread
tee Package.swift << EOF
import PackageDescription
var urls = [String]()
#if os(Linux)
urls += ["$HUB/Perfect-LinuxBridge"]
#endif
let package = Package(
	name: "PerfectThread",	targets: [],
	dependencies: urls.map { .Package(url: \$0, majorVersion: 3) }
)
EOF
reversion $VER

# Perfect-Crypto
VER=3.0.2
mirror $VER Perfect-Crypto
reversion $VER
tee Package.swift << EOF
import PackageDescription
#if os(Linux)
	let cOpenSSLRepo = "$HUB/Perfect-COpenSSL-Linux"
#else
	let cOpenSSLRepo = "$HUB/Perfect-COpenSSL"
#endif
let package = Package( name: "PerfectCrypto", targets: [],
    dependencies: [
		.Package(url: "$HUB/Perfect", majorVersion: 3),
		.Package(url: "$HUB/Perfect-Thread", majorVersion: 3),
		.Package(url: cOpenSSLRepo, majorVersion: 3)
	]
)
EOF
reversion $VER

# Perfect-Net
VER=3.0.0
mirror $VER Perfect-Net
reversion $VER
tee Package.swift << EOF
import PackageDescription
var urls: [String] = ["$HUB/Perfect-Crypto", "$HUB/Perfect-Thread"]
#if os(Linux)
	urls += ["$HUB/Perfect-LinuxBridge"]
#endif
let package = Package(
    name: "PerfectNet", targets: [],
    dependencies:  urls.map { .Package(url: \$0, majorVersion: 3) }
)
EOF
reversion $VER

# Perfect-HTTP
VER=3.0.1
mirror $VER Perfect-HTTP
reversion $VER
tee Package.swift << EOF
import PackageDescription
var urls: [String] = ["$HUB/Perfect", "$HUB/Perfect-Net"]
#if os(Linux)
	urls += ["$HUB/Perfect-LinuxBridge"]
#endif
let package = Package(
    name: "PerfectHTTP", targets: [],
    dependencies:  urls.map { .Package(url: \$0, majorVersion: 3) }
)
EOF
reversion $VER

# Perfect-CZlib-src
VER=0.0.3
mirror $VER Perfect-CZlib-src
cd PerfectCZlib
rm -rf amiga contrib doc examples msdoc nintendods old os400 qnx test watcom win32
cd ..
tee Package.swift << EOF
import PackageDescription
let package = Package(
    name: "PerfectCZlib", targets: [],
    dependencies:  [],
 		exclude: ["contrib", "test", "examples"]
)
EOF
reversion $VER


# Perfect-HTTPServer
VER=3.0.3
mirror $VER Perfect-HTTPServer
tee Package.swift << EOF
import PackageDescription
let package = Package(
	name: "PerfectHTTPServer",
	targets: [
		Target(name: "PerfectCHTTPParser", dependencies: []),
		Target(name: "PerfectHTTPServer", dependencies: ["PerfectCHTTPParser"]),
	],
	dependencies: [
		.Package(url: "$HUB/Perfect-Net", majorVersion: 3),
		.Package(url: "$HUB/Perfect-HTTP", majorVersion: 3),
		.Package(url: "$HUB/Perfect-CZlib-src", majorVersion: 0)
	]
)
EOF
reversion $VER

# PerfectTemplate
VER=3.0.0
mirror $VER PerfectTemplate
tee Package.swift << EOF
import PackageDescription
let package = Package(
	name: "PerfectTemplate",
	targets: [],
	dependencies: [
		.Package(url: "$HUB/Perfect-HTTPServer", majorVersion: 3),
	]
)
EOF
reversion $VER

# Clean up
popd


