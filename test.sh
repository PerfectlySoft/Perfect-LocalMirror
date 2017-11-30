function buildTest() {
	pushd .
	cd /tmp/perfect/$1
	pwd
	echo "============== $1 ==============="
	time swift build -c release
	echo "-------------- $1 ---------------"
	rm -rf .build*
	rm -rf *.resolved
	rm -rf *.pins
	popd
}
buildTest $1

