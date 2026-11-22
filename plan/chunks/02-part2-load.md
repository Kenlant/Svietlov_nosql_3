# Chunk 02: part2_load.cypher

## Goal
Write `part2_load.cypher` per plan Step 4: 3 uniqueness constraints (User.userId,
Movie.movieId, Genre.name) first, users MERGE load, movies+genres MERGE load, ratings via
`apoc.periodic.iterate` (batchSize 10000, parallel false, MERGE RATED with rating/timestamp),
then the three count verification queries. No comments. Statements are numbered by order
(README refers to them by number). Plan refs: Step 4, A3, A4.

## Owns (create/edit)
- part2_load.cypher

## May only read
- plan/implementation_plan.md, requirements/task.txt, import/*.csv, docker-compose.yml

## Depends on
Chunk 01 only for CSV headers (fixed by plan A2), so it can be written in parallel.

## Acceptance checks
- Static: statement order correct, `;` terminated, no comments, lines <= 100 chars.
- Optional, only if Docker is available: run
  `docker compose exec -T neo4j cypher-shell -u neo4j -p password123 < part2_load.cypher`;
  counts 6040 users, 3883 movies, 1000209 RATED, 18 Genre; re-run leaves counts unchanged.

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
