# GitHub Configuration

This directory contains GitHub-specific configuration files.

## 📁 Contents

### Workflows (`workflows/`)
- **release.yml** - Automated release workflow
  - Triggers on git tags (v*.*.*)
  - Creates ZIP archive
  - Generates checksums
  - Creates GitHub releases
  - Uploads release assets

### Issue Templates (`ISSUE_TEMPLATE/`)
- **bug_report.md** - Bug report template
- **feature_request.md** - Feature request template

### PR Templates (`PULL_REQUEST_TEMPLATE/`)
- **pull_request_template.md** - Pull request template

## 🚀 Usage

### Creating a Release

```bash
# Bump version
./scripts/bump-version.sh patch  # or minor, major

# Commit and tag
git add .
git commit -m "chore: bump version to vX.Y.Z"
git tag -a vX.Y.Z -m "Release vX.Y.Z"

# Push (triggers GitHub Actions)
git push && git push --tags
```

### Filing an Issue

1. Go to repository **Issues** tab
2. Click **New issue**
3. Choose template (Bug Report or Feature Request)
4. Fill out all sections
5. Submit

### Creating a Pull Request

1. Fork the repository
2. Create feature branch
3. Make changes
4. Push to your fork
5. Open PR (template auto-fills)
6. Complete all checklist items

## 🔧 Workflow Configuration

### Enable/Disable Auto-Publishing to Chrome Web Store

Edit `.github/workflows/release.yml`:

```yaml
# Line ~80
if: false  # Change to true to enable
```

Add required secrets to repository settings.

## 📚 More Information

- **GitHub Setup**: See [GITHUB_SETUP.md](../GITHUB_SETUP.md)
- **Release Guide**: See [RELEASE_GUIDE.md](../RELEASE_GUIDE.md)
- **Contributing**: See [CONTRIBUTING.md](../CONTRIBUTING.md)
