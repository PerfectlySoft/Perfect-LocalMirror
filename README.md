# Perfect Repo Local Mirror 本地编译加速器

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

We received many complaints about how Swift Package Manager version 4 slow down the building process, so here is an example of cheating sheet.

我们收到大量关于Swift 4 SPM 软件包管理器速度过慢的投诉，因此本项目用于Perfect编译加速

## Quick Start

### Note

This script requires `wget`, please do `brew install wget` or `sudo apt-get install -y wget` before using.


### Install

Open a terminal then execute the following script to it.
打开终端执行下列命令：

```
git clone https://github.com/RockfordWei/Perfect-Light.git && \
./Perfect-Light/install.sh
```

### Usage

You will find a localized version of PerfectTemplate, the starter web server, under the folder of `/tmp/perfect/PerfectTemplate`:

您会发现一个本地版本的模板服务器，结构已经发生了显著变化：

``` swift
import PackageDescription
let package = Package(
	name: "PerfectTemplate",
	targets: [],
	dependencies: [
		.Package(url: "/tmp/perfect/Perfect-HTTPServer", majorVersion: 3),
	]
)
```

Then the server building speed will be completely different now. Have fun!
现在服务器编译速度肯定大不相同了，请尽情尝试：

`cd /tmp/perfect/PerfectTemplate && swift run`

## Issues

We are transitioning to using JIRA for all bugs and support related issues, therefore the GitHub issues has been disabled.

If you find a mistake, bug, or any other helpful suggestion you'd like to make on the docs please head over to [http://jira.perfect.org:8080/servicedesk/customer/portal/1](http://jira.perfect.org:8080/servicedesk/customer/portal/1) and raise it.

A comprehensive list of open issues can be found at [http://jira.perfect.org:8080/projects/ISS/issues](http://jira.perfect.org:8080/projects/ISS/issues)

## Further Information
For more information on the Perfect project, please visit [perfect.org](http://perfect.org).


## 微信好友圈

<p align=center><img src="https://raw.githubusercontent.com/PerfectExamples/Perfect-Cloudinary-ImageUploader-Demo/master/qr.png"></p>
