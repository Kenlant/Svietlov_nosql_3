# Chunk 05: README.md (Ukrainian)

## Goal
Write README.md per plan Step 7 (sections: title; Part 1; Part 2; Part 3; Part 4; Part 6;
nothing else; no Part 5, no run-instructions/architecture sections). Plan refs: Step 7,
A7-A12.

## Owns (create/edit)
- README.md

## May only read
- plan/implementation_plan.md, requirements/task.txt, docker-compose.yml, convert.py,
  part2_load.cypher, queries/part3.cypher, queries/part4_supernodes.cypher

## Depends on
Chunks 01, 02, 03, 04 (all files must exist; real numbers need a loaded DB).

## Real numbers
README needs real counts (Part 2), the first 10 rows of each Part 3 result, and real degree
numbers (Part 4, answer 4.1).
- If Docker is available: `docker compose up -d`, wait for Neo4j, `uv run convert.py` if CSVs
  are missing, load with
  `docker compose exec -T neo4j cypher-shell -u neo4j -p password123 < part2_load.cypher`,
  run queries via
  `docker compose exec -T neo4j cypher-shell -u neo4j -p password123 --format plain`
  with `< queries/part3.cypher` (and part4_supernodes.cypher), and paste the real
  first-10-row text tables and degree numbers.
- If Docker is unavailable: write the whole README, but put a clearly marked placeholder
  `TODO-RESULTS` wherever a real number or result table belongs (verification counts, each
  Part 3 table, Part 4 degree numbers). NEVER invent or guess numbers. Report in the final
  message that placeholders remain and where.

## Acceptance checks
- Present, in Ukrainian and concise: answers 1.1-1.3, path-length answers (2, 4, 6),
  4.1-4.3, 6.1-6.3 (each >= one paragraph, 6.1 with SQL example), ASCII diagram.
- Each statement of part2/part3/part4 explained (what + why).
- `grep -n TODO-RESULTS README.md` is empty if Docker data was used; otherwise it lists all
  placeholders. Lines <= 100 chars where practical.

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
