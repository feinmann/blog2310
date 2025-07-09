# blog2310

A technical blog built with [Quarto](https://quarto.org/) focusing on data engineering, machine learning, and system administration tutorials.

## 🚀 Quick Start

### Prerequisites

- [Quarto](https://quarto.org/docs/get-started/) (latest version)
- R or RStudio (optional, for R-based content)

### Development

```bash
# Preview the site locally with live reload
quarto preview

# Render the entire site
quarto render

# Check project for issues
quarto check
```

The rendered site will be available in the `docs/` directory.

## 📁 Project Structure

```
├── _quarto.yml          # Main configuration
├── _assets/             # Custom themes and styles
├── posts/               # Blog posts organized by date
│   ├── _metadata.yml    # Global post settings
│   └── YYYY-MM-DD_*/    # Individual post directories
├── index.qmd            # Homepage with post listing
├── about.qmd            # About page
└── docs/                # Generated static site
```

## ✍️ Writing Posts

1. Create a new directory in `posts/` with format: `YYYY-MM-DD_post-title/`
2. Add a `.qmd` file with YAML frontmatter:

```yaml
---
title: "Your Post Title"
description: "Brief description of the post"
author: "3atthias 3erger"
date: "2025-01-01"
categories: [category1, category2]
format:
  html:
    toc: true
    code-fold: true
---
```

3. Write your content using Quarto markdown syntax
4. Preview with `quarto preview`
5. Render with `quarto render`

## 🎨 Features

- **Dual themes**: Light and dark mode with custom Elm-inspired styling
- **Code execution**: Executable code blocks with syntax highlighting
- **GitHub integration**: Repository links and issue tracking
- **Comments**: Giscus-powered comments system
- **Responsive design**: Mobile-friendly layout

## 🛠️ Development

### Available Commands

```bash
# Start development server
quarto preview

# Build the site
quarto render

# Clean build artifacts
rm -rf docs/ _site/ .quarto/

# Check for issues
quarto check
```

### Customization

- **Themes**: Edit files in `_assets/` for styling
- **Navigation**: Modify `_quarto.yml` for site structure
- **Post defaults**: Update `posts/_metadata.yml` for global settings

## 📝 Content Guidelines

- Use descriptive categories for better organization
- Include table of contents (`toc: true`) for longer posts
- Use code folding (`code-fold: true`) for better readability
- Add comprehensive descriptions for SEO

## 🚀 Deployment

The site is automatically deployed to GitHub Pages when changes are pushed to the `main` branch. The generated site is served from the `docs/` directory.

## 📄 License

This project is open source and available under the [MIT License](LICENSE).