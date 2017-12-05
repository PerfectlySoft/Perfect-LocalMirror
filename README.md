# Perfect Local Mirror 本地编译缓存加速器

<p align="center">
    <a href="http://perfect.org/get-involved.html" target="_blank">
        <img src="http://perfect.org/assets/github/perfect_github_2_0_0.jpg" alt="Get Involed with Perfect!" width="854" />
    </a>
</p>

<p align="center">
    <a href="https://github.com/PerfectlySoft/Perfect" target="_blank">
        <img src="http://www.perfect.org/github/Perfect_GH_button_1_Star.jpg" alt="Star Perfect On Github" />
    </a>  
    <a href="http://stackoverflow.com/questions/tagged/perfect" target="_blank">
        <img src="http://www.perfect.org/github/perfect_gh_button_2_SO.jpg" alt="Stack Overflow" />
    </a>  
    <a href="https://twitter.com/perfectlysoft" target="_blank">
        <img src="http://www.perfect.org/github/Perfect_GH_button_3_twit.jpg" alt="Follow Perfect on Twitter" />
    </a>  
    <a href="http://perfect.ly" target="_blank">
        <img src="http://www.perfect.org/github/Perfect_GH_button_4_slack.jpg" alt="Join the Perfect Slack" />
    </a>
</p>

<p align="center">
    <a href="https://developer.apple.com/swift/" target="_blank">
        <img src="https://img.shields.io/badge/Swift-4.0-orange.svg?style=flat" alt="Swift 4.0">
    </a>
    <a href="https://developer.apple.com/swift/" target="_blank">
        <img src="https://img.shields.io/badge/Platforms-OS%20X-lightgray.svg?style=flat" alt="Platforms OS X">
    </a>
    <a href="http://perfect.org/licensing.html" target="_blank">
        <img src="https://img.shields.io/badge/License-Apache-lightgrey.svg?style=flat" alt="License Apache">
    </a>
    <a href="http://twitter.com/PerfectlySoft" target="_blank">
        <img src="https://img.shields.io/badge/Twitter-@PerfectlySoft-blue.svg?style=flat" alt="PerfectlySoft Twitter">
    </a>
    <a href="http://perfect.ly" target="_blank">
        <img src="http://perfect.ly/badge.svg" alt="Slack Status">
    </a>
</p>

We received many complaints about how slow Swift Package Manager version 4 was, so here is an example of cheating sheet - to accelerate your Perfect App by caching all heavy dependencies.

我们收到大量关于Swift 4 SPM 软件包管理器速度过慢的投诉，因此本项目用于Perfect编译加速

## Quick Start

### Install

Open a terminal then execute the following script to it.
打开终端执行下列命令：

```
git clone https://github.com/PerfectlySoft/Perfect-LocalMirror.git && \
./Perfect-LocalMirror/install.sh && rm -rf Perfect-LocalMirror/
```

⚠️ **NOTE** 注意 ⚠️ You may need `sudo` privilege to perform the installation.

您可能需要管理员权限以执行上述命令。

### Usage

You will find a localized version of PerfectTemplate, the starter web server, under the folder of `/private/var/perfect/PerfectTemplate`:

您会发现一个本地版本的模板服务器，结构已经发生了显著变化：

``` swift
import PackageDescription
let package = Package(
	name: "PerfectTemplate",
	targets: [],
	dependencies: [
		.Package(url: "/private/var/perfect/Perfect-HTTPServer", majorVersion: 3),
	]
)
```

Then the server building speed will be completely different now.

现在服务器编译速度肯定大不相同了，请尽情尝试！

## Local Cache Path

Now these components are available on local repo `/private/var/perfect` as the above fashion:
目前可以使用上述路径的本地模块包括：

(a full example can be found on `test.sh` script)
(完整的调用样例可以参考 `test.sh` 脚本)

PerfectLib|PerfectHTTP|PerfectHTTPServer|PerfectThread
----------|-----------|-----------------|--------------
PerfectLogger|PerfectRequestLogger|PerfectNet|LinuxBridge
PerfectXML|PerfectCrypto|PerfectCURL|PerfectSMTP
PerfectMustache|PerfectPostgreSQL|PerfectSQLite|PerfectMySQL
PerfectRedis|PerfectMongoDB|PerfectRepeater|PerfectNotifications
PerfectCouchDB|PerfectFileMaker|PerfectHadoop|PerfectWebSockets
PerfectWebRedirects|PerfectPython|PerfectMarkdown|PerfectLDAP
PerfectKafka|PerfectMosquitto|PerfectSession|PerfectSessionMySQL
PerfectSessionPostgreSQL|PerfectSessionRedis|PerfectSessionMongoDB|PerfectSessionSQLite
PerfectSessionCouchDB|PerfectTurnstileSQLite|PerfectTurnstileMySQL|PerfectTurnstilePostgreSQL
PerfectTurnstileMongoDB|PerfectTurnstileCouchDB|PerfectLocalAuthentication|PerfectZip
OAuth2|MariaDB|SwiftMoment|SwiftRandom|
SwiftString|JSONConfig|StORM|SQLiteStORM
CouchDBStORM|PostgresStORM|MySQLStORM|MongoDBStORM
PerfectLocalAuthentication|&nbsp;|&nbsp;|&nbsp;

** NOTE ** If any Server Side Swift component has little dependencies and free of incompressible large files such as binaries in git history, then it could be unnecessary to cache it as the above.
⚠️注意⚠️ 如果Swift服务器组件没有特别的依存关系，而且在历史版本中也没有无法压缩的大文件（比如二进制文件），那么可能就根本没有必要使用这个本地缓存

## Magic Behind

The actual bottleneck is Swift Package Manager version 4 is using a [`--mirror`](https://github.com/apple/swift-package-manager/commit/58e3844c3e505dcaf295be02dc01698b488dd63c) flag of `git clone`, which has a good reason but may cause 8x+ slower than Swift 3 in a certain situation.

我们发现瓶颈存在于上述链接，即 2017年2月27日 之后在git clone 命令中增加了`--mirror`标志。这个想法是好的，但是极端情况下会导致编译速度慢八倍。

The solution is simple: build a local cache of each repo recursively and truncate unnecessary backlog history resulted by `--mirror` prior to `swift package resolve`.

解决思路其实很简单，就是在SPM解析之前，首先把经过截取不必要版本历史的简化镜像置于本地硬盘。

Only three steps it actually takes.

实际这个过程就三步：

- `mirror_ex RepoName VenderName` which will grab the latest version from github. 首先是从 github 上取得目标最新版本。
- Patch Package.swift to allow local mirrors. 然后修改本地下载的Package.swift 文件以应用本地镜像。
- `git tag` the latest online version to the offline updates. 在修改基础上增加一个和在线版本一致的离线版本。

Take OAuth2 for example, the installation will patch all dependencies to offline versions. By default, the installation path is HUB=`/private/var/perfect`.
以 OAuth2 为例，安装脚本会将所有依存关系指向本地离线版本，默认安装路径是 HUB=`/private/var/perfect`：

``` swift
mirror Perfect-OAuth2
tee Package.swift << EOF >> /dev/null
import PackageDescription
let package = Package(name: "OAuth2",	targets: [],
	dependencies: [
		.Package(url: "$HUB/Perfect-HTTP", majorVersion: 3),
		.Package(url: "$HUB/Perfect-Logger", majorVersion: 3),
		.Package(url: "$HUB/SwiftString", majorVersion: 2),
		.Package(url: "$HUB/Perfect-Session", majorVersion: 3),
	])
EOF
reversion
```

You can add as many components as possible to the script. Have fun!

您可以尽情按照上述风格自行向脚本追加需要的 Swift 组件，慢用！

## Issues

We are transitioning to using JIRA for all bugs and support related issues, therefore the GitHub issues has been disabled.

If you find a mistake, bug, or any other helpful suggestion you'd like to make on the docs please head over to [http://jira.perfect.org:8080/servicedesk/customer/portal/1](http://jira.perfect.org:8080/servicedesk/customer/portal/1) and raise it.

A comprehensive list of open issues can be found at [http://jira.perfect.org:8080/projects/ISS/issues](http://jira.perfect.org:8080/projects/ISS/issues)

## Further Information
For more information on the Perfect project, please visit [perfect.org](http://perfect.org).


## 微信好友圈

<p align=center><img src="https://raw.githubusercontent.com/PerfectExamples/Perfect-Cloudinary-ImageUploader-Demo/master/qr.png"></p>
