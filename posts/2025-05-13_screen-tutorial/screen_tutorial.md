# Mastering the `screen` Command in Linux
3atthias 3erger
2025-05-13

## Introduction

The `screen` command is a terminal multiplexer that allows users to run
multiple shell sessions from a single SSH connection or terminal. With
`screen`, you can create detachable terminal sessions that continue to
run in the background, even after you disconnect.

## Installing `screen`

On most Linux distributions, `screen` is not installed by default.
Here’s how you can install it:

**Arch Linux:**

<div class="code-with-filename">

**Terminal**

``` bash
$ sudo pacman -S screen
```

</div>

## Basic Usage

### Starting a New Session

<div class="code-with-filename">

**Terminal**

``` bash
$ screen
```

</div>

This creates a new session. You’ll be placed in a new terminal
environment.

### Naming a Session

<div class="code-with-filename">

**Terminal**

``` bash
$ screen -S session_name
```

</div>

Naming sessions helps identify them later when reconnecting.

### Detaching from a Session

<div class="code-with-filename">

**Terminal**

``` bash
Ctrl-a d
```

</div>

This detaches your session and keeps it running in the background.

### Listing Sessions

<div class="code-with-filename">

**Terminal**

``` bash
$ screen -ls
```

</div>

Shows all active and detached sessions.

### Identifying a Session

Each screen session is assigned a unique identifier in the format:

    PID.session_name

This will print out the name of the actual session:

<div class="code-with-filename">

**Terminal**

``` bash
$ echo $STY
```

</div>

For example:

    12345.my_session

If no name is provided when creating the session, only the PID will be
shown (e.g., `67890.pts-0.hostname`). Use the session name or PID when
reattaching:

<div class="code-with-filename">

**Terminal**

``` bash
$ screen -r 12345
```

</div>

Or:

<div class="code-with-filename">

**Terminal**

``` bash
$ screen -r my_session
```

</div>

### Reattaching to a Session

<div class="code-with-filename">

**Terminal**

``` bash
$ screen -r session_name
```

</div>

This resumes the session you previously detached from.

## Advanced Usage

### Splitting the Screen

To split the terminal horizontally:

<div class="code-with-filename">

**Terminal**

``` bash
Ctrl-a S
```

</div>

To switch between regions:

<div class="code-with-filename">

**Terminal**

``` bash
Ctrl-a Tab
```

</div>

To create a new shell in the region:

<div class="code-with-filename">

**Terminal**

``` bash
Ctrl-a c
```

</div>

### Logging Output

You can log all output of a screen session:

<div class="code-with-filename">

**Terminal**

``` bash
Ctrl-a H
```

</div>

This will start logging to a file named `screenlog.0`.

### Locking the Screen

<div class="code-with-filename">

**Terminal**

``` bash
Ctrl-a x
```

</div>

Locks the session. You’ll need your user password to unlock.

### Scroll Mode

Enter scroll mode to navigate output:

<div class="code-with-filename">

**Terminal**

``` bash
Ctrl-a [
```

</div>

Use arrow keys or `PgUp/PgDn` to scroll.

## Useful Command-line Options

- `-d -m`: Start a session in detached mode

  <div class="code-with-filename">

  **Terminal**
  ``` bash
  $ screen -d -m -S mysession myscript.sh
  ```

  </div>

- `-X`: Send commands to a running session

  <div class="code-with-filename">

  **Terminal**
  ``` bash
  $ screen -S mysession -X quit
  ```

  </div>

## Interesting Fact

The `screen` command was first released in 1987 and is still actively
maintained. Its stability and simplicity have made it a favorite tool
for sysadmins and developers working with remote servers, long-running
scripts, or unstable connections.

## Conclusion

The `screen` command is a powerful utility for managing terminal
sessions, enabling persistent workflows across disconnections and
multi-tasking within one terminal. While newer tools like `tmux` offer
advanced features, `screen` remains a reliable and widely-used solution.

Whether you’re using Bash or Fish, understanding how `screen` operates
is a must-have skill for any Linux power user.
