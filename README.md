# javinla

[![Build Status](https://travis-ci.org/nerro/javinla.svg?branch=master)](https://travis-ci.org/nerro/javinla)

Javinla is a command-line tool to make an Java installation on your server very
easy. You don't need to set ppa repositories (ubuntu/debian) or use aur packages
(archlinux) and get latest java version. Just select the Java version you want
to install and that's all.


## Why Use This?

The main goal is space-saving if you build docker images with Java. When I used
PPA java repositories my docker images became over 600 MB with unnecessary data
like fonts, x11 libs etc. Java Server JRE 7 is "only" 154 MB and I want keep my
docker images as small as possible.


## Installation

1. Download the [javinla script](https://github.com/nerro/javinla/releases/download/v1.0.0/javinla) from latest release.
2. Place it somewhere on your PATH (make sure it is executable).
3. That's it.


## Usage

Once you're installed then you can used `javinla install <java-version>` to
install selected JRE on you machine, e.g:

```bash
$ javinla install 8u92
... this will install selected 8u92 version under /opt/java...
```

To list all available Java versions to install, use `javinla list` command:

```bash
$ javinla list
VERSION NUMBER      URL
...
8u77                http://download.oracle.com/otn/java/jdk/8u77-b03/server-jre-8u77-linux-x64.tar.gz
8u91                http://download.oracle.com/otn-pub/java/jdk/8u91-b14/server-jre-8u91-linux-x64.tar.gz
8u92                http://download.oracle.com/otn-pub/java/jdk/8u92-b14/server-jre-8u92-linux-x64.tar.gz
...
```

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new pull request


## License

See the [LICENSE](LICENSE) file for license rights and limitations (MIT).
