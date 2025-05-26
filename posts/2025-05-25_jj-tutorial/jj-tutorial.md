# JJ Version Control Tutorial
3atthias 3erger
2025-05-25

# Introduction to JJ Version Control

JJ is a Git-compatible version control system that aims to be more
user-friendly and powerful than Git. In this tutorial, we’ll explore the
basic commands and workflows of JJ.

## Installation

JJ can be installed using Cargo (Rust’s package manager). First, make
sure you have Rust installed on your system. Then run:

<div class="code-with-filename">

**Terminal**

``` bash
```{.bash}
cargo install jj-cli
```

</div>

If you don’t have Rust installed, you can install it from
[rustup.rs](https://rustup.rs/).

After installation, you might need to restart your terminal or add the
Cargo binary directory to your PATH. The binary is typically installed
at `~/.cargo/bin/jj`.

## Getting Started

Let’s first check if JJ is installed and its version:

<div class="code-with-filename">

**Terminal**

``` bash
jj --version
```

</div>

## Basic Commands

Let’s explore some basic JJ commands:

### Initializing a Repository

<div class="code-with-filename">

**Terminal**

``` bash
$ jj git init jj-tutorial
Initialized repo in "jj-tutorial"
```

</div>

### Checking Repository Status

<div class="code-with-filename">

**Terminal**

``` bash
$ cd jj-tutorial
$ jj status # or jj st
The working copy has no changes.
Working copy  (@) : wswnkktq 6725dc6b (empty) (no description set)
Parent commit (@-): zzzzzzzz 00000000 (empty) (no description set)
```

</div>

### Making Changes

Let’s create a simple file and commit it:

<div class="code-with-filename">

**Terminal**

``` bash
echo "Hello, JJ!" > hello.txt
jj add hello.txt
jj commit -m "Add hello.txt"
```

</div>

### Viewing History

<div class="code-with-filename">

**Terminal**

``` bash
jj log
```

</div>

## Working with Branches

Let’s try some branch operations:

<div class="code-with-filename">

**Terminal**

``` bash
jj branch create feature-branch
jj branch list
```

</div>

## Conclusion

This tutorial covered the basics of JJ version control. Stay tuned for
more advanced topics!
