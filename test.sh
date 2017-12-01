function buildTest() {
	pushd .
	echo "++++++++++++ L I N U X ++++++++++"
	docker pull rockywei/swift:4.0
	time docker run -it -v /tmp:/tmp -w /tmp/perfect/$1 rockywei/swift:4.0 /bin/bash -c \
	"swift package resolve"
	echo "++++++++++++ M A C O S ++++++++++"
	cd /tmp/perfect/$1
	rm -rf .build*
	rm -rf *.resolved
	rm -rf *.pins
	echo "============== $1 ==============="
	time swift package resolve
	echo "-------------- $1 ---------------"
	rm -rf .build*
	rm -rf *.resolved
	rm -rf *.pins
	popd
}
buildTest $1

