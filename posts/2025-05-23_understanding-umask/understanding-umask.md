# Understanding the `umask` Command in Linux
3atthias 3erger
2025-05-23

# Introduction

The `umask` command in Unix-like operating systems controls the default
permission settings for newly created files and directories.
Understanding `umask` is crucial for managing security and ensuring
proper access control on a multi-user system.

# What is `umask`?

`umask`, short for *user file-creation mode mask*, sets default
permissions by masking out permission bits that should not be set for
new files and directories.

When a new file or directory is created, the system starts with a
default permission set (typically `666` for files and `777` for
directories), and the `umask` subtracts permissions from that default.

- Files: `666` (read & write for everyone)

- Directories: `777` (read, write & execute for everyone)

# Syntax

<div class="code-with-filename">

**Terminal**

``` bash
$ umask [options] [mask]
```

</div>

- Without arguments, it displays the current mask.
- With a mask, it sets a new default mask.

# Displaying the Current `umask`

To check your current umask value:

<div class="code-with-filename">

**Terminal**

``` bash
$ umask
```

</div>

This might return something like:

<div class="code-with-filename">

**Terminal**

``` bash
0022
```

</div>

This means new files will have default permissions of `644` (666 - 022)
and directories `755` (777 - 022).

# Setting a New `umask`

You can set a new `umask` value using:

<div class="code-with-filename">

**Terminal**

``` bash
$ umask 0027
```

</div>

This changes default permissions to:

- Files: 640 (666 - 027)
- Directories: 750 (777 - 027)

# Using Symbolic Notation

Instead of octal, you can also use symbolic notation:

<div class="code-with-filename">

**Terminal**

``` bash
$ umask u=rwx,g=rx,o=
```

</div>

This sets:

- User: read, write, execute
- Group: read, execute
- Others: no permissions

# Temporary vs Permanent Changes

## Temporary Change

Setting `umask` on the command line changes it for the current session
only.

## Permanent Change

To make it permanent, add the command to your shell configuration file.

For Bash:

<div class="code-with-filename">

**~/.bashrc**

``` bash
umask 0027
```

</div>

# Best Practices

- Use `077` for maximum privacy (only user has access).
- Use `002` when working in collaborative environments (user and group
  have access).

# Troubleshooting

- Remember that `umask` affects only default permissions. Users can
  still manually set more restrictive or permissive settings.
- Use `ls -l` to inspect actual permissions after file creation.

# Interesting Fact

The concept of `umask` dates back to early versions of Unix. It’s a
simple yet powerful tool that highlights Unix’s foundational philosophy:
“Everything is a file,” and files deserve thoughtful default
permissions.

------------------------------------------------------------------------
