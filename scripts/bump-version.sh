#!/bin/bash

# Version Bump Script
# Automatically increments version in manifest.json and creates git tag

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Get current directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
MANIFEST="$PROJECT_ROOT/manifest.json"

# Usage
usage() {
    echo -e "${BLUE}Usage:${NC} $0 [major|minor|patch]"
    echo -e "\nBumps the version number in manifest.json"
    echo -e "\nExamples:"
    echo -e "  $0 patch   # 1.0.1 → 1.0.2"
    echo -e "  $0 minor   # 1.0.2 → 1.1.0"
    echo -e "  $0 major   # 1.1.0 → 2.0.0"
    exit 1
}

# Check arguments
if [ $# -ne 1 ]; then
    usage
fi

BUMP_TYPE=$1

if [[ ! "$BUMP_TYPE" =~ ^(major|minor|patch)$ ]]; then
    echo -e "${RED}Error:${NC} Invalid bump type '$BUMP_TYPE'"
    usage
fi

# Read current version
CURRENT_VERSION=$(grep '"version"' "$MANIFEST" | sed 's/.*"version": "\(.*\)".*/\1/')
echo -e "${BLUE}Current version:${NC} $CURRENT_VERSION"

# Parse version
IFS='.' read -r -a VERSION_PARTS <<< "$CURRENT_VERSION"
MAJOR="${VERSION_PARTS[0]}"
MINOR="${VERSION_PARTS[1]}"
PATCH="${VERSION_PARTS[2]}"

# Bump version based on type
case $BUMP_TYPE in
    major)
        MAJOR=$((MAJOR + 1))
        MINOR=0
        PATCH=0
        ;;
    minor)
        MINOR=$((MINOR + 1))
        PATCH=0
        ;;
    patch)
        PATCH=$((PATCH + 1))
        ;;
esac

NEW_VERSION="$MAJOR.$MINOR.$PATCH"
echo -e "${BLUE}New version:${NC}     ${GREEN}$NEW_VERSION${NC}"

# Confirm
read -p "$(echo -e ${YELLOW}Continue with version bump? [y/N]:${NC} )" -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo -e "${RED}Aborted${NC}"
    exit 1
fi

# Update manifest.json
if command -v python3 &> /dev/null; then
    python3 << EOF
import json
with open('$MANIFEST', 'r') as f:
    data = json.load(f)
data['version'] = '$NEW_VERSION'
with open('$MANIFEST', 'w') as f:
    json.dump(data, f, indent=2)
    f.write('\n')
EOF
    echo -e "${GREEN}✓${NC} Updated manifest.json"
else
    # Fallback to sed
    sed -i.bak "s/\"version\": \"$CURRENT_VERSION\"/\"version\": \"$NEW_VERSION\"/" "$MANIFEST"
    rm -f "$MANIFEST.bak"
    echo -e "${GREEN}✓${NC} Updated manifest.json (using sed)"
fi

# Update CHANGELOG if it exists
CHANGELOG="$PROJECT_ROOT/CHANGELOG.md"
if [ -f "$CHANGELOG" ]; then
    DATE=$(date +%Y-%m-%d)
    TEMP_FILE=$(mktemp)

    # Add new version header
    {
        head -n 2 "$CHANGELOG"
        echo ""
        echo "## [v$NEW_VERSION] - $DATE"
        echo ""
        echo "### Added"
        echo "- "
        echo ""
        echo "### Changed"
        echo "- "
        echo ""
        echo "### Fixed"
        echo "- "
        echo ""
        tail -n +3 "$CHANGELOG"
    } > "$TEMP_FILE"

    mv "$TEMP_FILE" "$CHANGELOG"
    echo -e "${GREEN}✓${NC} Updated CHANGELOG.md"
fi

# Show summary
echo -e "\n${BLUE}╔═══════════════════════════════════════╗${NC}"
echo -e "${BLUE}║   Version Bump Complete!             ║${NC}"
echo -e "${BLUE}╚═══════════════════════════════════════╝${NC}\n"

echo -e "  ${GREEN}Version:${NC} $CURRENT_VERSION → ${GREEN}$NEW_VERSION${NC}"
echo -e "  ${GREEN}Type:${NC}    $BUMP_TYPE"

echo -e "\n${YELLOW}Next Steps:${NC}"
echo -e "  1. Review changes: ${BLUE}git diff${NC}"
echo -e "  2. Commit changes: ${BLUE}git add . && git commit -m \"chore: bump version to v$NEW_VERSION\"${NC}"
echo -e "  3. Create tag:     ${BLUE}git tag -a v$NEW_VERSION -m \"Release v$NEW_VERSION\"${NC}"
echo -e "  4. Build release:  ${BLUE}./scripts/build-release.sh${NC}"
echo -e "  5. Push changes:   ${BLUE}git push && git push --tags${NC}\n"
