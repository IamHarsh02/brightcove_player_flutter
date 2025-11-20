# Steps to Publish to pub.dev

This guide will walk you through the process of publishing your `brightcove_player_flutter` plugin to pub.dev.

## Prerequisites

1. **pub.dev Account**: Create an account at [pub.dev](https://pub.dev) if you don't have one
2. **Google Account**: You'll need a Google account to sign in to pub.dev
3. **Flutter SDK**: Ensure Flutter is installed and up to date
4. **Dart SDK**: Ensure Dart is installed (comes with Flutter)

## Step 1: Prepare Your Package

### 1.1 Update `pubspec.yaml`

- ✅ Remove or comment out `publish_to: 'none'`
- ✅ Update `description` with a meaningful description
- ✅ Add `homepage`, `repository`, and `issue_tracker` URLs (if available)
- ✅ Ensure `version` follows semantic versioning (e.g., `1.0.0+1`)

### 1.2 Verify Package Structure

Ensure your package has:
- ✅ `lib/` directory with your Dart code
- ✅ `README.md` with documentation
- ✅ `CHANGELOG.md` with version history
- ✅ `LICENSE` file (MIT License)
- ✅ `example/` directory with example code (optional but recommended)

## Step 2: Run Pre-Publish Checks

### 2.1 Analyze Your Code

```bash
flutter analyze
```

Fix any issues reported by the analyzer.

### 2.2 Run Tests

```bash
flutter test
```

Ensure all tests pass.

### 2.3 Check Package Format

```bash
flutter pub publish --dry-run
```

This will:
- Check for common issues
- Validate your `pubspec.yaml`
- Verify all required files are present
- Show what files will be published

**Fix any errors or warnings before proceeding!**

## Step 3: Create/Update Documentation

### 3.1 README.md

Ensure your README includes:
- Package description
- Installation instructions
- Usage examples
- API documentation
- Platform-specific setup instructions

### 3.2 CHANGELOG.md

Document all changes in your CHANGELOG:
- Version numbers
- New features
- Bug fixes
- Breaking changes

## Step 4: Verify License

Ensure you have a `LICENSE` file in the root directory. MIT License is recommended for open-source packages.

## Step 5: Final Checks

### 5.1 Check File Size

Ensure no unnecessary files are included:
- Remove `build/` directories
- Remove `.dart_tool/` directories
- Remove IDE-specific files (`.idea/`, `.vscode/`, etc.)
- Ensure `.gitignore` is properly configured

### 5.2 Verify Dependencies

Check that all dependencies in `pubspec.yaml` are:
- Available on pub.dev
- Using stable versions
- Not using `path:` or `git:` dependencies (unless necessary)

## Step 6: Publish to pub.dev

### 6.1 Login to pub.dev

```bash
dart pub login
```

You'll be prompted to:
1. Open a browser
2. Sign in with your Google account
3. Authorize the CLI tool

### 6.2 Publish Your Package

```bash
flutter pub publish
```

**Note**: Publishing is **permanent**. Once published, you cannot delete or unpublish a package. You can only publish new versions.

### 6.3 Verify Publication

After publishing:
1. Visit `https://pub.dev/packages/brightcove_player_flutter`
2. Verify your package appears correctly
3. Check that all files are included
4. Test the installation instructions

## Step 7: Post-Publication

### 7.1 Update Version

After publishing, update the version in `pubspec.yaml` for future releases:
```yaml
version: 1.0.1+1  # Increment as needed
```

### 7.2 Create Git Tag

Tag your release in Git:
```bash
git tag v1.0.0
git push origin v1.0.0
```

### 7.3 Announce (Optional)

- Share on social media
- Update your project's main repository
- Announce in relevant communities

## Common Issues and Solutions

### Issue: "Package validation failed"

**Solution**: Run `flutter pub publish --dry-run` and fix all warnings/errors.

### Issue: "Package name already taken"

**Solution**: Choose a different package name in `pubspec.yaml`.

### Issue: "Missing required files"

**Solution**: Ensure you have:
- `README.md`
- `CHANGELOG.md`
- `LICENSE`

### Issue: "Dependency not found"

**Solution**: Check that all dependencies are published on pub.dev and use stable versions.

## Versioning Guidelines

Follow [Semantic Versioning](https://semver.org/):

- **MAJOR** (1.0.0): Breaking changes
- **MINOR** (0.1.0): New features, backward compatible
- **PATCH** (0.0.1): Bug fixes, backward compatible

## Updating Your Package

To publish a new version:

1. Update `version` in `pubspec.yaml`
2. Update `CHANGELOG.md`
3. Run `flutter pub publish --dry-run`
4. Fix any issues
5. Run `flutter pub publish`
6. Create a new Git tag

## Resources

- [pub.dev Publishing Guide](https://dart.dev/tools/pub/publishing)
- [Flutter Package Publishing](https://docs.flutter.dev/development/packages-and-plugins/developing-packages#publishing)
- [Semantic Versioning](https://semver.org/)
- [pub.dev Package Policy](https://pub.dev/policy)

## Checklist Before Publishing

- [ ] `publish_to: 'none'` removed from `pubspec.yaml`
- [ ] `description` is meaningful and clear
- [ ] `version` follows semantic versioning
- [ ] `README.md` is comprehensive
- [ ] `CHANGELOG.md` is up to date
- [ ] `LICENSE` file exists
- [ ] `flutter analyze` passes
- [ ] `flutter test` passes
- [ ] `flutter pub publish --dry-run` passes
- [ ] All unnecessary files are excluded
- [ ] Dependencies are stable and available
- [ ] Example code works (if included)
- [ ] Documentation is complete

Good luck with your publication! 🚀

