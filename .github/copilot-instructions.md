# GitHub Copilot Instructions

## Shell Environment

**Important**: The user is using fish shell as their default shell. When generating terminal commands or shell scripts, always use fish shell syntax instead of bash/zsh. Do not assume bash compatibility.

## Planning and Task Management

**Important**: Before doing anything, ask me if it's necessary to create a detailed checklist markdown file that categorizes the upcoming work in the `.checklist` directory. Ask me all the questions that should be confirmed in advance when making plans.

## Project Context

This is an R development environment project using Docker containers with:
- R 4.5.0 with renv for package management
- Fish shell with Starship prompt
- Python + radian for enhanced R console
- LaTeX for RMarkdown PDF output
- Centralized dependency management system
