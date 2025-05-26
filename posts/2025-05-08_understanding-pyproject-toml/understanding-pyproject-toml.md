# Understanding `pyproject.toml` in Python Projects
3atthias 3erger
2025-05-08

# Introduction

Python packaging has long been fragmented and confusing. The
introduction of `pyproject.toml` aims to bring consistency and clarity.
This file is now a cornerstone of modern Python projects, especially
when using tools like Poetry, Flit, uv, or even pip itself.

This tutorial explores `pyproject.toml`, its structure, why it matters,
and how it fits into Python’s evolving packaging ecosystem.

------------------------------------------------------------------------

# What is `pyproject.toml`?

At its core, `pyproject.toml` is a configuration file defined by [PEP
518](https://peps.python.org/pep-0518/) and extended in [PEP
621](https://peps.python.org/pep-0621/). It standardizes the way
projects declare build systems and metadata.

### Goals:

- Declare build system requirements.
- Serve as a central place for tool-specific configuration.
- Make Python packaging more interoperable and tool-agnostic.

------------------------------------------------------------------------

# Basic Structure

Here’s a minimal example:

``` toml
[build-system]
requires = ["setuptools", "wheel"]
build-backend = "setuptools.build_meta"
```

### Explained:

- `requires`: Dependencies needed to build the project.
- `build-backend`: The build tool to use (e.g., setuptools, flit,
  poetry).

------------------------------------------------------------------------

# Tool Configuration

One of the strengths of `pyproject.toml` is that it allows multiple
tools to store config in the same file.

Example with **Black** and **isort**:

``` toml
[tool.black]
line-length = 88
target-version = ["py310"]

[tool.isort]
profile = "black"
```

This avoids cluttering the root directory with many `*.cfg` or `*.ini`
files.

### Tipp: Configuring flake8

While `flake8` traditionally uses a `setup.cfg` or `.flake8` file, it
can also be configured in `pyproject.toml` via the
[flake8-pyproject](https://github.com/john-hen/Flake8-pyproject) plugin.

Example configuration:

``` toml
[tool.flake8]
max-line-length = 88
extend-ignore = ["E203", "W503"]
exclude = [".git", "__pycache__", "build", "dist"]
```

### Notes:

- You must install `flake8-pyproject` for `flake8` to recognize this
  configuration.
- This approach keeps all tool configuration centralized.

------------------------------------------------------------------------

# Specifying Project Metadata

With [PEP 621](https://peps.python.org/pep-0621/), you can define your
project metadata directly in `pyproject.toml`:

``` toml
[project]
name = "my-awesome-package"
version = "0.1.0"
description = "An example Python package"
authors = [
  { name="Your Name", email="you@example.com" }
]
license = { text = "MIT" }
dependencies = [
  "requests >=2.25",
  "pandas"
]
```

This eliminates the need for `setup.py` in many cases.

------------------------------------------------------------------------

# Real-World Example with Poetry

Poetry uses `pyproject.toml` as its single source of truth.

``` toml
[tool.poetry]
name = "example-project"
version = "0.1.0"
description = "A sample project using Poetry"
authors = ["Jane Doe <jane@example.com>"]

[tool.poetry.dependencies]
python = "^3.10"
requests = "^2.25.1"

[tool.poetry.dev-dependencies]
pytest = "^7.0"

[build-system]
requires = ["poetry-core"]
build-backend = "poetry.core.masonry.api"
```

------------------------------------------------------------------------

# Using `pyproject.toml` with `uv`

[`uv`](https://github.com/astral-sh/uv) is a modern, fast Python package
manager developed by Astral. It is designed as a drop-in replacement for
pip, pip-tools, and virtualenv, offering significantly faster resolution
and installation speeds.

`uv` uses `pyproject.toml` as a primary source of dependency
information. When present, `uv` will read dependencies from the
`[project]` table, similar to what Poetry uses.

### Example:

``` toml
[project]
name = "uv-sample"
version = "0.1.0"
dependencies = [
  "httpx",
  "rich"
]
```

You can then run:

<div class="code-with-filename">

**Terminal**

``` bash
$ uv pip install
```

</div>

This command will install dependencies defined in the `pyproject.toml`
file, using `uv`’s fast resolver and installer. `uv` also supports lock
files (`uv.lock`) for reproducible installs.

### Benefits of using `uv`:

- Ultra-fast dependency resolution and installation.
- Unified handling of environments, installs, and lockfiles.
- Compatibility with `pyproject.toml`-based workflows.

`uv` represents a significant step forward in Python tooling,
particularly for developers who want performance and simplicity.

------------------------------------------------------------------------

# Why It Matters

- **Cleaner Repos**: One file for all configuration.
- **Tool Interoperability**: Works with setuptools, flit, poetry, uv,
  and more.
- **Build Isolation**: Ensures builds use correct dependencies.
- **Forward-Compatible**: Future tools and standards will likely rely on
  it.

------------------------------------------------------------------------

# Common Gotchas

- Not all tools support `pyproject.toml` yet. Sometimes there are
  workarounds.
- Some older versions of pip (\<19) ignore `pyproject.toml`. (#TODO: is
  this true?)
- Incorrect `build-backend` paths can break builds.

------------------------------------------------------------------------

# Conclusion

`pyproject.toml` is more than just a config file—it’s a pivotal part of
modern Python development. Understanding how to use it effectively will
help you write cleaner, more maintainable, and tool-friendly code.

Feel free to copy parts of this file into your own projects and start
benefiting from the simplicity and power it provides.

------------------------------------------------------------------------

# Resources

- [PEP 518](https://peps.python.org/pep-0518/)
- [PEP 621](https://peps.python.org/pep-0621/)
- [Python Packaging Guide](https://packaging.python.org/)
- [Poetry Documentation](https://python-poetry.org/docs/)
- [uv on GitHub](https://github.com/astral-sh/uv)
