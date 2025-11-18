# Commands

This directory contains reusable chat commands for common development workflows. Commands are triggered with a `/` prefix in Cursor's chat interface.

## Core Commands

### code-review-checklist

Comprehensive checklist for conducting thorough code reviews to ensure quality, security, and maintainability. Covers functionality, code quality, and security aspects.

**Example usage:** Use `/code-review-checklist` before merging a pull request to ensure all review criteria are met.

### security-audit

Comprehensive security review to identify and fix vulnerabilities in the codebase. Includes dependency audits, code security reviews, and infrastructure security checks.

**Example usage:** Run `/security-audit` when adding new dependencies or before a production deployment to catch security issues early.

### create-pr

Create a well-structured pull request with proper description, labels, and reviewers. Guides through branch preparation, PR description writing, and setup.

**Example usage:** Use `/create-pr` after completing a feature to generate a properly formatted pull request with all necessary information.

### run-all-tests-and-fix

Execute the full test suite and systematically fix any failures. Analyzes failures by type and prioritizes fixes based on impact.

**Example usage:** Run `/run-all-tests-and-fix` after making code changes to ensure all tests pass and fix any failures systematically.

### address-github-pr-comments

Systematically address and resolve all comments on a GitHub pull request. Reviews comments, makes necessary changes, and updates the PR.

**Example usage:** Use `/address-github-pr-comments` when responding to review feedback to ensure all comments are properly addressed.

### light-review-existing-diffs

Perform a quick review of existing git diffs to catch obvious issues before deeper review. Focuses on identifying changes and flagging concerns.

**Example usage:** Run `/light-review-existing-diffs` before a detailed code review to catch obvious issues quickly.

### accessibility-audit

Review codebase for accessibility issues and ensure WCAG compliance. Checks semantic HTML, ARIA attributes, keyboard navigation, and visual accessibility.

**Example usage:** Use `/accessibility-audit` when building new UI components or before releasing a feature to ensure it's accessible to all users.

### write-unit-tests

Create comprehensive unit tests for code changes. Identifies test targets, writes tests for happy paths and edge cases, and verifies coverage.

**Example usage:** Run `/write-unit-tests` after implementing a new feature to ensure good test coverage and maintainable test code.

### add-pr-description

Generate or enhance a pull request description with context, changes, and testing information. Analyzes changes and creates a well-structured description.

**Example usage:** Use `/add-pr-description` to automatically generate a comprehensive PR description based on your code changes.
