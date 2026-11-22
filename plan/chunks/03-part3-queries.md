# Chunk 03: queries/part3.cypher

## Goal
Six statements 3.1-3.6 as in plan Step 5 (Thriller avg > 4.0; users with > 50 fives; movies
rated >= 4 by users 1 and 2; genres by avg rating and count; recommendation for user 1;
shortestPath between user 1 and user 2 via RATED*..10). Cypher 5.18 syntax. No comments.
Plan refs: Step 5, A5.

## Owns (create/edit)
- queries/part3.cypher

## May only read
- plan/implementation_plan.md, requirements/task.txt, part2_load.cypher

## Depends on
Graph schema from plan section 4 only. Parallel with 01, 02, 04.

## Acceptance checks
- Static: six `;`-terminated statements in order, labels/types match section 4.
- Optional, only if Docker with loaded data is available: each statement returns rows
  (if 3.3 returns zero rows, switch the pair and note it for the README chunk).

## Rules

```
CODE RULES (mandatory):
1. No comments in code.
2. No output (print, logging, progress bars, console writes) unless the requirement TEXT
   explicitly asks for it. If a code sample in the requirements contains output that the
   text does not ask for, drop it.
3. Temporary debug output is allowed only during implementation/testing and MUST carry the
   marker comment `TEMP-DEBUG` (e.g. `print(x)  # TEMP-DEBUG`). Remove both the output and
   the marker before finishing.
4. Follow the project structure suggested in the requirements, applying clean code practices.
5. Every file < 150 lines; no line longer than 100 chars.
6. Package manager: uv (Python default: uv - use `uv init`, `uv add`, `uv run`).
7. Secrets come only from environment variables / `.env`; never hard-code them.
8. Do not run the full build/test suite unless your task says so.
9. Simplicity of implementation is the top priority. Build only what the requirements ask
   for: no extra abstractions, wrappers, config modules, fallbacks, CLI options or helper
   modules used by a single file. Keep the layout as close to the requirements' suggested
   structure as possible; share code only when 2+ files need it.
10. Tasks/parts marked optional (e.g. "optional", "not graded", "додаткова",
    "необов'язкова", "не оцінюється") are SKIPPED entirely: not planned, not implemented,
    not mentioned in the README.
11. README answers ONLY questions explicitly asked in the requirements, plus sections the
    requirements explicitly demand (e.g. required run output). Answers are short and plain,
    no filler. No extra "decisions", "architecture" or explanatory sections unless asked.
```

Project notes: `password123` stays in docker-compose.yml as the requirements give it.
README.md (Ukrainian) is the only file allowed over 150 lines. `.cypher` files are code
(no comments). Source of truth: plan/implementation_plan.md and requirements/task.txt.
Project root: /Users/vladyslavsvietlov/Programming/Svietlov_nosql_3
