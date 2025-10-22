# Contributing to Mermaid Markdown Renderer for Confluence

Thank you for considering contributing to this project! 🎉

## Table of Contents

- [Code of Conduct](#code-of-conduct)
- [How Can I Contribute?](#how-can-i-contribute)
- [Development Setup](#development-setup)
- [Pull Request Process](#pull-request-process)
- [Coding Standards](#coding-standards)
- [Testing Guidelines](#testing-guidelines)
- [Release Process](#release-process)

---

## Code of Conduct

This project follows a simple code of conduct:

- Be respectful and inclusive
- Provide constructive feedback
- Focus on the issue, not the person
- Help create a welcoming environment

---

## How Can I Contribute?

### Reporting Bugs

Before creating a bug report:
1. Check existing issues to avoid duplicates
2. Collect information about the bug (browser version, extension version, console errors)
3. Create a detailed bug report using the [bug report template](.github/ISSUE_TEMPLATE/bug_report.md)

Include:
- Clear description of the bug
- Steps to reproduce
- Expected vs actual behavior
- Screenshots (if applicable)
- Console errors
- Environment details

### Suggesting Features

Feature requests are welcome! Use the [feature request template](.github/ISSUE_TEMPLATE/feature_request.md).

Include:
- Clear description of the feature
- Problem it solves
- Proposed solution
- Use case examples
- Alternative solutions considered

### Contributing Code

1. **Fork the repository**
2. **Create a feature branch**: `git checkout -b feature/amazing-feature`
3. **Make your changes**
4. **Test thoroughly** on a live Confluence page
5. **Commit with clear messages**: `git commit -m "feat: add amazing feature"`
6. **Push to your fork**: `git push origin feature/amazing-feature`
7. **Open a Pull Request**

---

## Development Setup

### Prerequisites

- Google Chrome (latest version)
- Git
- Text editor (VSCode recommended)
- Access to a Confluence instance for testing

### Local Setup

```bash
# Clone the repository
git clone https://github.com/your-username/mermaid-markdown-confluence.git
cd mermaid-markdown-confluence

# Load extension in Chrome
# 1. Open chrome://extensions/
# 2. Enable "Developer mode"
# 3. Click "Load unpacked"
# 4. Select the project directory
```

### Project Structure

```
mermaid-markdown-confluence/
├── manifest.json          # Extension configuration
├── content.js            # Main rendering logic
├── popup.html            # Extension popup UI
├── popup.js              # Popup functionality
├── icon*.png             # Extension icons
├── scripts/              # Build and automation scripts
├── .github/              # GitHub templates and workflows
└── docs/                 # Documentation
```

### Making Changes

1. **Modify files** as needed
2. **Reload extension**: Go to `chrome://extensions/` → Click reload icon
3. **Test changes**: Visit Confluence page and verify functionality
4. **Check console**: Press F12 → Console tab for errors

---

## Pull Request Process

### Before Submitting

- [ ] Code follows the project's coding standards
- [ ] All tests pass (manual testing on Confluence)
- [ ] No console errors or warnings
- [ ] Documentation updated (if applicable)
- [ ] CHANGELOG.md updated (if applicable)
- [ ] Version bumped (if applicable)

### PR Guidelines

1. **Use the PR template**: Fill out all sections
2. **Link related issues**: Reference issue numbers
3. **Describe changes**: Explain what and why
4. **Add screenshots**: For UI changes
5. **Keep it focused**: One feature/fix per PR
6. **Update tests**: Add or modify tests as needed

### PR Review Process

1. Automated checks run (if configured)
2. Maintainer reviews code
3. Feedback provided (if needed)
4. Approve and merge (or request changes)

### Commit Message Format

We follow [Conventional Commits](https://www.conventionalcommits.org/):

```
<type>(<scope>): <subject>

<body>

<footer>
```

**Types**:
- `feat`: New feature
- `fix`: Bug fix
- `docs`: Documentation changes
- `style`: Code style changes (formatting)
- `refactor`: Code refactoring
- `test`: Adding or updating tests
- `chore`: Maintenance tasks

**Examples**:
```
feat(rendering): add support for new diagram type
fix(csp): resolve script loading issue
docs(readme): update installation instructions
chore(deps): update mermaid.js to v10.6.0
```

---

## Coding Standards

### JavaScript

- Use ES6+ features
- Prefer `const` over `let`, avoid `var`
- Use meaningful variable names
- Add comments for complex logic
- Handle errors gracefully

**Example**:
```javascript
// Good
const renderDiagram = async (block) => {
  try {
    const { container, code } = block;
    await mermaid.render(code);
  } catch (error) {
    console.error('Rendering failed:', error);
    showErrorMessage(error);
  }
};

// Avoid
var x = function(y) {
  mermaid.render(y.code);
};
```

### HTML/CSS

- Use semantic HTML
- Follow BEM naming for CSS classes
- Keep inline styles minimal
- Ensure accessibility (ARIA labels)

### Code Organization

- Keep functions small and focused
- Use descriptive names
- Avoid deep nesting
- Group related functionality

---

## Testing Guidelines

### Manual Testing Checklist

Before submitting a PR, test:

- [ ] Extension loads without errors
- [ ] Diagrams render on Confluence pages
- [ ] Toggle button works (Show/Hide Code)
- [ ] Extension popup functions correctly
- [ ] No console errors
- [ ] Works with multiple diagram types
- [ ] Performance is acceptable
- [ ] Dynamic content loads properly

### Test on Multiple Scenarios

- Different diagram types (flowchart, sequence, etc.)
- Multiple diagrams on one page
- Dynamically loaded content
- Different Confluence page types
- Edge cases (malformed syntax, large diagrams)

### Browser Testing

Test on:
- Latest Chrome version
- Chrome Beta (if significant changes)
- Different operating systems (if possible)

---

## Release Process

### Version Bumping

Use the version bump script:

```bash
# Bump patch version (1.0.1 → 1.0.2)
./scripts/bump-version.sh patch

# Bump minor version (1.0.2 → 1.1.0)
./scripts/bump-version.sh minor

# Bump major version (1.1.0 → 2.0.0)
./scripts/bump-version.sh major
```

### Creating a Release

1. **Update CHANGELOG.md** with release notes
2. **Bump version**: `./scripts/bump-version.sh [type]`
3. **Commit changes**: `git commit -m "chore: bump version to vX.Y.Z"`
4. **Create tag**: `git tag -a vX.Y.Z -m "Release vX.Y.Z"`
5. **Build release**: `./scripts/build-release.sh`
6. **Test the release**: Load ZIP in Chrome
7. **Push changes**: `git push && git push --tags`
8. **Create GitHub release** with the generated ZIP file

GitHub Actions will automatically create the release when a tag is pushed.

---

## Documentation

When adding features:

- Update README.md
- Add to CHANGELOG.md
- Update relevant documentation files
- Include code comments for complex logic

---

## Questions?

- Open an issue for questions
- Check existing documentation
- Review closed issues and PRs

---

## Recognition

Contributors will be:
- Listed in CONTRIBUTORS.md (if applicable)
- Mentioned in release notes
- Credited in the repository

---

Thank you for contributing! 🚀

Every contribution, no matter how small, helps make this extension better for everyone.
