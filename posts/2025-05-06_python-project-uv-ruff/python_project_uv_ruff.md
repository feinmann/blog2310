# Setting Up a Python Project with uv and ruff
3atthias 3erger
2025-05-06

## Introduction

This tutorial walks you through setting up a Python project using
[`uv`](https://github.com/astral-sh/uv) for dependency management and
[`ruff`](https://docs.astral.sh/ruff/) for linting and formatting,
including integrating `ruff` with Git via a pre-commit hook.

By the end, you’ll have: - A minimal Python project - `uv` for fast,
modern package management - `ruff` configured for formatting, linting,
and as a pre-commit hook

------------------------------------------------------------------------

## Prerequisites

Make sure you have the following installed:

- Python (\>=3.8)
- Git
- [`uv`](https://github.com/astral-sh/uv): install with:

<div class="code-with-filename">

**Terminal**

``` bash
$ curl -LsSf https://astral.sh/uv/install.sh | sh
```

</div>

------------------------------------------------------------------------

## Project Structure

Let’s start by creating a new project:

<div class="code-with-filename">

**Terminal**

``` bash
$ uv init example-project
$ cd example-project
$ git init
$ tree -a -L1
.
├── .git
├── main.py
├── pyproject.toml
├── .python-version
└── README.md

2 directories, 4 files
```

</div>

------------------------------------------------------------------------

## Step 1: Initialize the project with `uv`

<div class="code-with-filename">

**Terminal**

``` bash
$ uv venv         # Create a virtual environment
Using CPython 3.13.3 interpreter at: /usr/bin/python3.13
Creating virtual environment at: .venv
Activate with: source .venv/bin/activate.fish
$ source .venv/bin/activate.fish # using fish shell
(example-project) $
```

</div>

Install some basic packages:

- [`pre-commit`](https://pre-commit.com/#install):

<div class="code-with-filename">

**Terminal**

``` bash
$ uv pip install pre-commit
```

</div>

<div class="code-with-filename">

**Terminal**

``` bash
$ uv pip install ruff
```

</div>

------------------------------------------------------------------------

## Step 2: Adjust pyproject.toml

Here’s an example `pyproject.toml`:

``` toml
[project]
name = "example-project"
version = "0.1.0"
description = "An example project using uv and ruff"
readme = "README.md"
requires-python = ">=3.13"
dependencies = []

[tool.ruff]
line-length = 88
target-version = "py311"
lint.select = ["E", "F", "I"]
lint.ignore = ["E501"]
```

------------------------------------------------------------------------

## Step 3: Add a sample script

Adjust `main.py`:

``` python
def greet(name: str) -> str:
    return f"Hello, {name}!"

def foo():
    x = 1
    y = 2
    return x

if __name__ == "__main__":
    print(greet("World"))
```

Run `ruff` to check the file:

<div class="code-with-filename">

**Terminal**

``` bash
$ ruff check .
main.py:6:5: F841 Local variable `y` is assigned to but never used
  |
4 | def foo():
5 |     x = 1
6 |     y = 2
  |     ^ F841
7 |     return x
  |
  = help: Remove assignment to unused variable `y`

Found 1 error.
No fixes available (1 hidden fix can be enabled with the `--unsafe-fixes` option).
```

</div>

Or automatically fix issues:

<div class="code-with-filename">

**Terminal**

``` bash
$ ruff check . --unsafe-fixes
main.py:6:5: F841 [*] Local variable `y` is assigned to but never used
  |
4 | def foo():
5 |     x = 1
6 |     y = 2
  |     ^ F841
7 |     return x
  |
  = help: Remove assignment to unused variable `y`

Found 1 error.
[*] 1 fixable with the --fix option.
```

</div>

<div class="code-with-filename">

**Terminal**

``` bash
$ ruff check . --unsafe-fixes --fix
Found 1 error (1 fixed, 0 remaining).
```

</div>

``` python
def greet(name: str) -> str:
    return f"Hello, {name}!"

def foo():
    x = 1
    return x

if __name__ == "__main__":
    print(greet("World"))
```

------------------------------------------------------------------------

## Step 4: Set up pre-commit hook for `ruff`

Create a `.pre-commit-config.yaml`:

``` yaml
repos:
  - repo: https://github.com/astral-sh/ruff-pre-commit
    rev: v0.4.0  # Replace with latest tag
    hooks:
      - id: ruff
```

Install the hook:

<div class="code-with-filename">

**Terminal**

``` bash
pre-commit install
```

</div>

Now `ruff` will run before every commit.

You can also test it manually:

<div class="code-with-filename">

**Terminal**

``` bash
$ pre-commit run --all-files
[INFO] Initializing environment for https://github.com/astral-sh/ruff-pre-commit.
[INFO] Installing environment for https://github.com/astral-sh/ruff-pre-commit.
[INFO] Once installed this environment will be reused.
[INFO] This may take a few minutes...
ruff.....................................................................Passed
```

</div>

------------------------------------------------------------------------

## Best Practices

- **Use `pyproject.toml`** as the single config file for tools.
- **Keep dependencies pinned** with `uv` (via `requirements.txt` or
  `.lock` files).
- **Use `ruff` for linting and formatting** — it’s fast and all-in-one.
- **Automate checks** via `pre-commit` and CI.

------------------------------------------------------------------------

## Summary

We covered how to:

- Set up a Python project using `uv`
- Install and configure `ruff`
- Automate linting with pre-commit hooks

This gives you a solid base for any Python project with modern tooling.

Happy coding!
