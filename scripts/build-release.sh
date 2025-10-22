#!/bin/bash

# Build Release Script for Chrome Extension
# Creates a production-ready .zip file for Chrome Web Store submission

set -e  # Exit on error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
BUILD_DIR="$PROJECT_ROOT/build"
RELEASES_DIR="$PROJECT_ROOT/releases"

echo -e "${BLUE}╔═══════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║   Chrome Extension Release Builder               ║${NC}"
echo -e "${BLUE}║   Mermaid Markdown Renderer for Confluence       ║${NC}"
echo -e "${BLUE}╚═══════════════════════════════════════════════════╝${NC}\n"

# Read version from manifest.json
VERSION=$(grep '"version"' "$PROJECT_ROOT/manifest.json" | sed 's/.*"version": "\(.*\)".*/\1/')
echo -e "${GREEN}✓${NC} Detected version: ${YELLOW}v$VERSION${NC}"

# Create directories
mkdir -p "$BUILD_DIR"
mkdir -p "$RELEASES_DIR"
echo -e "${GREEN}✓${NC} Created build directories"

# Clean previous build
if [ -d "$BUILD_DIR" ]; then
    rm -rf "$BUILD_DIR"/*
    echo -e "${GREEN}✓${NC} Cleaned previous build"
fi

# Files to include in release
INCLUDE_FILES=(
    "manifest.json"
    "content.js"
    "popup.html"
    "popup.js"
    "icon16.png"
    "icon48.png"
    "icon128.png"
    "README.md"
    "LICENSE"
)

# Copy files to build directory
echo -e "\n${BLUE}Copying files to build directory...${NC}"
for file in "${INCLUDE_FILES[@]}"; do
    if [ -f "$PROJECT_ROOT/$file" ]; then
        cp "$PROJECT_ROOT/$file" "$BUILD_DIR/"
        echo -e "  ${GREEN}✓${NC} $file"
    else
        echo -e "  ${RED}✗${NC} $file (not found)"
        exit 1
    fi
done

# Validate manifest.json
echo -e "\n${BLUE}Validating manifest.json...${NC}"
if command -v python3 &> /dev/null; then
    if python3 -c "import json; json.load(open('$BUILD_DIR/manifest.json'))" 2>/dev/null; then
        echo -e "${GREEN}✓${NC} manifest.json is valid JSON"
    else
        echo -e "${RED}✗${NC} manifest.json is invalid"
        exit 1
    fi
else
    echo -e "${YELLOW}⚠${NC} Python3 not found, skipping JSON validation"
fi

# Create ZIP archive
RELEASE_NAME="mermaid-confluence-renderer-v$VERSION.zip"
RELEASE_PATH="$RELEASES_DIR/$RELEASE_NAME"

echo -e "\n${BLUE}Creating release archive...${NC}"
cd "$BUILD_DIR"
zip -r "$RELEASE_PATH" . -q
cd "$PROJECT_ROOT"

# Verify ZIP was created
if [ -f "$RELEASE_PATH" ]; then
    FILE_SIZE=$(du -h "$RELEASE_PATH" | cut -f1)
    echo -e "${GREEN}✓${NC} Created: ${YELLOW}$RELEASE_NAME${NC} (${FILE_SIZE})"
else
    echo -e "${RED}✗${NC} Failed to create ZIP archive"
    exit 1
fi

# List contents of ZIP
echo -e "\n${BLUE}Archive contents:${NC}"
unzip -l "$RELEASE_PATH" | tail -n +4 | head -n -2 | awk '{print "  " $4}'

# Calculate checksums
echo -e "\n${BLUE}Generating checksums...${NC}"
if command -v shasum &> /dev/null; then
    SHA256=$(shasum -a 256 "$RELEASE_PATH" | cut -d' ' -f1)
    echo "$SHA256  $RELEASE_NAME" > "$RELEASES_DIR/$RELEASE_NAME.sha256"
    echo -e "${GREEN}✓${NC} SHA256: ${SHA256:0:16}..."
fi

# Create release notes template
NOTES_FILE="$RELEASES_DIR/release-notes-v$VERSION.md"
if [ ! -f "$NOTES_FILE" ]; then
    cat > "$NOTES_FILE" << EOF
# Release Notes - v$VERSION

## What's New

<!-- Add new features here -->

## Bug Fixes

<!-- Add bug fixes here -->

## Improvements

<!-- Add improvements here -->

## Installation

1. Download \`$RELEASE_NAME\`
2. Go to \`chrome://extensions/\`
3. Enable "Developer mode"
4. Drag and drop the ZIP file

Or install from Chrome Web Store: [Link to be added]

## Checksums

- **SHA256**: \`$SHA256\`

---

**Full Changelog**: https://github.com/your-username/mermaid-markdown-confluence/compare/v$(echo $VERSION | awk -F. '{print $1"."$2"."$3-1}')...v$VERSION
EOF
    echo -e "${GREEN}✓${NC} Created release notes template: $NOTES_FILE"
fi

# Summary
echo -e "\n${BLUE}╔═══════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║   Release Build Complete!                        ║${NC}"
echo -e "${BLUE}╚═══════════════════════════════════════════════════╝${NC}\n"

echo -e "  ${GREEN}Version:${NC}     v$VERSION"
echo -e "  ${GREEN}Archive:${NC}     $RELEASE_PATH"
echo -e "  ${GREEN}Size:${NC}        $FILE_SIZE"
echo -e "  ${GREEN}Checksum:${NC}    $RELEASES_DIR/$RELEASE_NAME.sha256"
echo -e "  ${GREEN}Notes:${NC}       $NOTES_FILE"

echo -e "\n${YELLOW}Next Steps:${NC}"
echo -e "  1. Review the release notes in: ${BLUE}$NOTES_FILE${NC}"
echo -e "  2. Test the extension from: ${BLUE}$RELEASE_PATH${NC}"
echo -e "  3. Upload to Chrome Web Store: ${BLUE}https://chrome.google.com/webstore/devconsole${NC}"
echo -e "  4. Create GitHub release with the archive\n"

# Clean up build directory (optional)
# rm -rf "$BUILD_DIR"
echo -e "${GREEN}✓${NC} Build directory preserved at: $BUILD_DIR"
