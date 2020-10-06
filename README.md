# nicstat.sh

## Introduction

nicstat.sh is a quick Bash script for Linux hosts that gathers network transfer data over a time interval. It's like [nicstat](https://docs.oracle.com/cd/E86824_01/html/E54763/nicstat-1.html) but doesn't require compilation or installation--just run it. Great for those situations when you don't want to install or compile anything, don't have root access, don't feel like dealing with nicstat's integer overflows :^) or just want some NIC stats, sheesh.

## Usage

    nicstat.sh <interface> <interval>

Works with any interface for which the kernel is collecting statistics and has entries in `/proc/net/dev`.
