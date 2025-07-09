# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is a **Quarto blog** project that generates a static website containing technical tutorials and guides. The blog focuses on data engineering, machine learning, and system administration topics.

## Key Commands

### Building and Rendering
- `quarto render` - Renders the entire site to the `docs/` directory
- `quarto preview` - Starts a local development server with live reload
- `quarto render <file.qmd>` - Renders a specific Quarto markdown file

### Working with Posts
- Posts are located in `posts/` directory with date-prefixed folder names (e.g., `2025-04-16_dbt-python-duckdb/`)
- Each post contains a `.qmd` file and any supporting assets
- Posts use YAML frontmatter with title, description, author, date, categories, and format specifications

## Project Structure

### Core Configuration
- `_quarto.yml` - Main project configuration file defining:
  - Website settings (title, navigation, theming)
  - Output directory (`docs/`)
  - HTML format with light/dark themes using custom SCSS
  - Repository integration with GitHub

### Content Organization
- `index.qmd` - Homepage with automatic post listing
- `about.qmd` - About page with author information
- `posts/` - Blog posts organized by date-prefixed folders
- `posts/_metadata.yml` - Global post settings (freeze: true, banner titles, Giscus comments)

### Assets and Styling
- `_assets/` - Custom SCSS files for theming:
  - `styles-elm-light.scss` / `styles-elm-dark.scss` - Theme-specific styles
  - `styles-elm-base.scss` - Base styles
  - `colors.scss` - Color definitions
  - `syntax-elm-light.theme` / `syntax-elm-dark.theme` - Code syntax highlighting

### Output
- `docs/` - Generated static site (GitHub Pages ready)
- `_site/` - Alternative output directory (not used in current config)

## Development Workflow

1. Create new posts in `posts/YYYY-MM-DD_post-name/` format
2. Write content in `.qmd` files using Quarto markdown syntax
3. Use `quarto preview` during development
4. Run `quarto render` to generate the final site
5. The `docs/` directory contains the deployable static site

## Special Features

- **Dual themes**: Light and dark mode with custom Elm-inspired styling
- **Code execution**: Posts support executable code blocks (frozen by default)
- **Comments**: Giscus integration for GitHub-based comments
- **Extensions**: Uses `gadenbuie/now` extension for dynamic date formatting

## Content Guidelines

- Posts should include comprehensive YAML frontmatter with categories and descriptions
- Use `code-fold: true` for collapsible code blocks
- Include table of contents with `toc: true` for longer posts
- Categories typically include: tutorial, data engineering, python, dbt, system administration