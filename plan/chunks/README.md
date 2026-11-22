# Chunks

| # | Chunk | Owns |
|---|-------|------|
| 01 | env-data | docker-compose.yml, .gitignore, import/.gitkeep, pyproject.toml, uv.lock, convert.py |
| 02 | part2-load | part2_load.cypher |
| 03 | part3-queries | queries/part3.cypher |
| 04 | part4-queries | queries/part4_supernodes.cypher |
| 05 | readme | README.md |

## Dependency graph

```
01 --> 05
02 --> 05
03 --> 05
04 --> 05
```

02, 03, 04 depend on 01 only for reading CSV headers/schema (the plan fixes both), so they
can be written in parallel with 01. 05 depends on all of 01-04.

## Parallel groups

- Group A: 01, 02, 03, 04 (disjoint files; no ordering needed for writing).
- Group B (after A): 05. Needs Docker + loaded data for real numbers; otherwise uses
  `TODO-RESULTS` placeholders and reports it.

Optional Docker verification of 02-04 belongs to the later end-to-end test.
