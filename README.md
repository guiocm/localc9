localc9
=======

Scripts for installing and running the Cloud9 IDE locally.

This repository contains a set of scripts and patches to download, install and 
fix and improve a few things in Cloud9 IDE so that it can run on your machine
as a local IDE. You can even run more than one instance with different users 
and share the IDE through your local network!

This is just a tool to make it easier to deploy the Cloud9 IDE. It's based on 
the amazing work by [Cloud9](https://c9.io/) and uses the 
[open source code](https://github.com/ajaxorg/cloud9/) for their IDE available 
in GitHub.


# How to use

This script has been tested only on Ubuntu 12.04.

Install the dependency, clone this repository and run the install script:
```sh
$ sudo apt-get install libxml2-dev build-essential git
$ git clone https://github.com/alnvdl/localc9.git
$ cd localc9
$ ./install.sh
```

This script will take care of downloading everything, configuring and applying 
the patches. It will change your `~/.bashrc` file to include a command in your 
command path. After it's done running (it might take a while depending on your
connection), open a new shell session (so that the executable path is updated) 
and start using the Cloud9 IDE:

```sh
$ cloud9 path/to/my_project
```

> If you see errors involving session IDs or a 403 (HTTP forbidden code), just
> refresh the page. These errors should go away and not come back again.

It will ask a few questions:
* **A project path**: if you don't specify a path as in the example above, it 
will ask for a project path. Leaving it empty will default to the current 
directory.
* If you want to leave the **server open**. This means that it will listen at 
`0.0.0.0` so that everyone that can access your machine can access the Cloud9 
IDE. If you run it this way, several plugins will be disable to avoid giving 
others console access to your machine. Since I don't know all the parts in 
Cloud9, some things that shouldn't be enabled might be. Use an open server at 
your own risk, and beware that traffic won't be encrypted.
* **A port number**. By default it will look for open ports starting at 
`10000`.
* **A username and password** to restrict access to the IDE. The default for
both is the Linux username.

You can also skip all these questions by passing arguments to the `cloud9` 
command with values corresponding to the questions it asks you.


# Example
You can run two instances of the IDE for the same project: one for your and 
another for someone else that's working with you.

To start a local instance for you, with full privileges, run;
```
$ cloud9 /path/to/my_project no 10000 myself myself
```
And then go to `http://localhost:10000` in your browser.

To start an open instance for your friend, with limited privileges, run;
```
$ cloud9 /path/to/my_project yes 10001 myfriend myfriend
```
And then tell your friend to go to `http://[YOUR IP]:10001` in their browser.


# Patches
Currently, these are the installed patches:
* Fix an issue with settings not being properly overwritten 
(see https://github.com/ajaxorg/cloud9/pull/2058). Also enables multiple users.
* Create a configuration file for open servers removing the plugins that 
provide access to the server shell.
* Remove the `Ctrl`+`T` binding to enable the same binding in the browser
* Replace `Ctrl`+`Alt`+`Left` and `Ctrl`+`Alt`+`Right` bindings for adding more
occurrences to the current selection with `Ctrl`+`Alt`+`,` and `Ctrl`+`Alt`+`.`
to avoid conflicting with typical Linux desktop environment bindings for 
switching virtual desktops.
* Work around an issue caused by writing headers to the client after the 
response had already been sent in the filelist plugin. It just catches the 
exception and ignores it.

To change the patch file, use:
```sh
$ ./install.sh nopatch && mv cloud9 a && cp -R a b && \
  patch -d b -p1 < cloud9.patch
[... Change what you want and run ...]
$ diff -rupN a b > cloud9.patch
```
