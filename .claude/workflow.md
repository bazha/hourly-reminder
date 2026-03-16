# Development Workflow

## Core Principle

**Never make changes to files without explicit confirmation or request to implement.**

## Change Process

Don’t touch what is inside `.github` folder without explicit request from use to update files specifically in the claude folder.

### For Architectural changes

1. **Document the decision first**
   - Create an ADR: `docs/00_adr/######-<descriptive-title>.md`
   - Include:
     - Context and problem statement
     - Considered alternatives
     - Decision and rationale
     - Consequences (positive and negative)
     - Trade-offs and assumptions
     - Steps to implement (later those steps will be become change plans), one line, per step, no more

### For Significant Changes

1. **Analyze the issue/request**
   - Investigate the problem
   - Check affected files
   - Identify dependencies

2. **Create a change plan**
   - Location: `docs/01_change_plans/######-<short-descriptive-title>.md`
   - Format: Use existing change plans as template
   - Include:
     - Background and issue description
     - Affected files
     - Implementation steps
     - Testing checklist
     - Add minimal necessary unit and integration tests to cover added functionality
     - Rollback plan
     - Benefits and estimated time

3. **Wait for explicit confirmation**
   - User must say: "implement", "apply", "do it", or similar
   - Do NOT implement based on questions like "how to fix this?"
   - Show the solution first, then ask for confirmation

4. **Implement the changes**
   - Follow the change plan
   - Test as you go
   - Handle errors gracefully
   - Implement unit- and integration-tests

4. **Run all unit-tests and integration-tests**
   - Run all the unit-tests and integration-tests, that you created for as a part of this change plan
   - Run all the unit-tests and integration-tests in the project
   - If any test (any test existing in the repository!) would fail at any stage, fix the code, but DON'T touch tests, untill all tests pass
   - Update the change plan if changes made during running tests in this stage isn't described in it


### For Simple Changes

Small, obvious fixes can be done directly if explicitly requested:
- Typo fixes
- Import adjustments
- Simple formatting

But still ask for confirmation if there's any ambiguity.


## Question Handling

### When User Asks "How to fix X?"

**Do NOT implement automatically.**

Instead:
1. Analyze the issue
2. Explain the problem
3. Show the solution
4. Ask: "Would you like me to implement this?”
5. If user agrees - create a change plan

### When User Says "Implement ######-<short-descriptive-title>"

**Proceed with implementation immediately.**

This is explicit permission.

### When User Asks for a Plan

Create the plan, but don't implement it.

## Documentation Requirements

### Always Update

- Change plans when planning changes
- Completion reports after implementing
- README if functionality changes
- Architecture docs if structure changes
- This workflow doc if process changes

### Never Update Without Asking

- Don't modify user's code without permission
- Don't change config files unless requested
- Don't add dependencies without discussion

## Testing Workflow

1. **Before changes:**
   - Understand current behavior
   - Identify test requirements

2. **During changes:**
   - Test incrementally
   - Verify each step works

3. **After changes:**
   - Run verification scripts
   - Run pytest suite
   - Test manually if needed
   - Document testing in completion report

## File Management

### Documentation Files

- Create in appropriate `docs/` subdirectories
- Use clear, descriptive names
- Follow markdown formatting

## Common Workflows

### Adding a New Feature

1. Discuss requirements with user
2. Create change plan
3. Get approval
4. Implement with tests
2. Update change plan (to mark it as applied)
6. Create completion report as docs/01_change_plans/######-<short-descriptive-title>-report.md, starting with the same number as its change plan

### Fixing a Bug

1. Reproduce the issue
2. Identify root cause
3. Propose solution (ask for confirmation)
4. Implement fix
5. Verify fix works
6. Document if needed

### Refactoring Code

1. Explain why refactoring is needed
2. Show before/after structure
3. Create change plan for significant refactors
4. Get explicit approval
5. Refactor incrementally
6. Test thoroughly

## Communication Style

- Be concise but complete
- Ask clarifying questions when needed
- Explain technical decisions clearly
- Provide examples when helpful
- Respect the user's time and expertise
