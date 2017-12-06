export PA_DEP=~/Library/Perfect/PerfectAssistant/dependencies
export PA_HUB=/private/var/perfect
function apply() {
	VEND=$1
	REPO=$2
	LOCAL=$3
	REMOTE=https://github.com/$VEND/$REPO.git
	FILE=$(grep -l $REMOTE *.json)
	if [[ -z $LOCAL ]]; then
		LOCAL=$REPO
	fi
	if [[ -n $FILE ]]; then
		CONTENT=$(cat $FILE | sed "s/https:\/\/github\.com\/$VEND\/$REPO\.git/\/private\/var\/perfect\/$REPO/g")
		echo $CONTENT > $FILE
	fi
}

pushd . >> /dev/null
echo "backup Perfect Assistant setting first ..."
if [ -d $PA_DEP ]; then
	cd $PA_DEP
	tar czf $PA_HUB/pa.json *.json
	apply PerfectlySoft Perfect
	apply PerfectlySoft Perfect-Thread
	apply PerfectlySoft Perfect-Crypto
	apply PerfectlySoft Perfect-Net
	apply PerfectlySoft Perfect-HTTP
	apply PerfectlySoft Perfect-HTTPServer
	apply PerfectlySoft Perfect-WebSockets
	apply PerfectlySoft Perfect-Zip
	apply PerfectlySoft Perfect-CURL
	apply PerfectlySoft Perfect-RequestLogger
	apply PerfectlySoft Perfect-Mustache
	apply PerfectlySoft Perfect-SMTP
	apply PerfectlySoft Perfect-PostgreSQL
	apply PerfectlySoft Perfect-MySQL
	apply PerfectlySoft Perfect-MariaDB
	apply PerfectlySoft Perfect-Redis
	apply PerfectlySoft Perfect-MongoDB
	apply PerfectlySoft Perfect-CouchDB
	apply PerfectlySoft Perfect-Hadoop
	apply PerfectlySoft Perfect-WebRedirects
	apply PerfectlySoft Perfect-Repeater
	apply PerfectlySoft Perfect-XML
	apply PerfectlySoft Perfect-FileMaker
	apply PerfectlySoft Perfect-Notifications
	apply PerfectlySoft Perfect-LDAP
	apply PerfectlySoft Perfect-Markdown
	apply PerfectlySoft Perfect-Python
	apply PerfectlySoft Perfect-Kafka
	apply PerfectlySoft Perfect-Mosquitto
	apply PerfectlySoft Perfect-Session
	apply PerfectlySoft Perfect-Session-MySQL
	apply PerfectlySoft Perfect-Session-PostgreSQL
	apply PerfectlySoft Perfect-Session-Redis
	apply PerfectlySoft Perfect-Session-MongoDB
	apply PerfectlySoft Perfect-Session-SQLite
	apply PerfectlySoft Perfect-Session-CouchDB
	apply StORM SwiftORM
	apply StORM SQLite-StORM
	apply StORM MySQL-StORM
	apply StORM MongoDB-StORM
	apply StORM CouchDB-SwiftORM
	apply StORM Postgres-SwiftORM
	apply Turnstile stormpath
	apply Turnstile Perfect-Turnstile-SQLite
	apply Turnstile Perfect-Turnstile-MySQL
	apply Turnstile Perfect-Turnstile-PostgreSQL
	apply Turnstile Perfect-Turnstile-MongoDB
	apply Turnstile Perfect-Turnstile-CouchDB
	apply Turnstile Perfect-Turnstile-OAuth2
	apply Turnstile Perfect-LocalAuthentication-PostgreSQL
	apply Turnstile Perfect-LocalAuthentication-MySQL
	apply iamjono SwiftRandom
	apply iamjono SwiftMoment
	apply iamjono SwiftString
	apply iamjono JSONConfig
	popd
else
	echo "Dependencies path $PA_DEP does not exist."
	popd
	exit
fi
