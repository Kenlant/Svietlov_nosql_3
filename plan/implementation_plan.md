# Implementation Plan: Svietlov_nosql_3 (MovieLens 1M in Neo4j)

Source requirements: `requirements/task.txt` (Ukrainian, authoritative).
`requirements/task_additional_requirements.txt` is empty and adds nothing.

Requirement IDs used below:

| ID | Requirement (task.txt) |
|----|------------------------|
| R-ENV | Variant A: local Neo4j via Docker, `docker-compose.yml` in root, `import/` folder |
| R1 | Part 1: describe graph schema, ASCII diagram, answer questions 1.1-1.3 |
| R2-CONV | Part 2: convert `.dat` (`::`, Latin-1) to CSV (`,`, UTF-8) with `convert.py` |
| R2-LOAD | Part 2: load nodes with MERGE, create indexes before edges, load edges via `apoc.periodic.iterate`, verify counts; all in `part2_load.cypher`; explain each query in README |
| R3 | Part 3: queries 3.1-3.6 in `queries/part3.cypher`; explain each; answer path-length questions; first 10 result rows of each query in README |
| R4 | Part 4: supernode queries in `queries/part4_supernodes.cypher`; explain each; answer questions 4.1-4.3 |
| R5 | Part 5 (GDS): marked "додаткова, не оцінюється" |
| R6 | Part 6: answers 6.1-6.3, at least one paragraph each, SQL example in 6.1 |
| R-README | README: schema diagram, answers to Parts 1, 3, 4, 6, Part 3 results |
| R-SUBMIT | LMS link, zip archive `[Surname]_nosql_3`, send for review |

## 1. Goals

1. Run Neo4j 5.18 locally (Docker) with APOC available (R-ENV).
2. Load the full MovieLens 1M dataset (6040 users, 3883 movies, 1 000 209 ratings, 18 genres)
   into a well-justified graph schema (R1, R2-CONV, R2-LOAD).
3. Write and run the required Cypher queries for Parts 2, 3, 4 (R2-LOAD, R3, R4).
4. Produce a Ukrainian `README.md` answering every required question (R-README, R1, R3, R4, R6).

## 2. Scope

In scope: R-ENV, R1, R2-CONV, R2-LOAD, R3, R4, R6, R-README.

Out of scope:
- R5 (Part 5, GDS) is SKIPPED: optional/not graded. No `part5_gds.cypher`, nothing in README.
- R-SUBMIT (LMS link, zip archive, sending for review) is a manual user action.
- Variant B (AuraDB) is not used.

## 3. Features

| Feature | Requirement |
|---------|-------------|
| `docker-compose.yml` starting `neo4j:5.18-community` with APOC (values exactly as given) | R-ENV |
| `convert.py` producing `import/movies.csv`, `import/ratings.csv`, `import/users.csv` | R2-CONV |
| `part2_load.cypher`: constraints/indexes, node load (MERGE), batched edge load, count checks | R2-LOAD |
| `queries/part3.cypher`: six queries 3.1-3.6 | R3 |
| `queries/part4_supernodes.cypher`: supernode detection queries | R4 |
| `README.md` (Ukrainian): diagram, explanations, answers, Part 3 result tables | R-README |

## 4. Data Model (graph schema)

Nodes:

| Label | Properties | Key | Source |
|-------|-----------|-----|--------|
| `User` | `userId` (int), `gender` (string), `age` (int), `occupation` (int) | `userId` unique | users.csv |
| `Movie` | `movieId` (int), `title` (string, as in file), `year` (int) | `movieId` unique | movies.csv |
| `Genre` | `name` (string) | `name` unique | movies.csv `genres` split on `|` |

`year` = `toInteger(substring(title, size(title) - 5, 4))` (titles end with `(YYYY)`).
Zip code is dropped (as in the requirements' converter sample).

Relationships:

| Type | Direction | Properties | Source |
|------|-----------|-----------|--------|
| `RATED` | `(User)-[:RATED]->(Movie)` | `rating` (int 1-5), `timestamp` (int) | ratings.csv |
| `HAS_GENRE` | `(Movie)-[:HAS_GENRE]->(Genre)` | none | movies.csv |

ASCII diagram (goes into README, R1):

```
            RATED {rating, timestamp}              HAS_GENRE
 (:User) ---------------------------> (:Movie) ---------------> (:Genre)
 {userId, gender, age, occupation}    {movieId, title, year}    {name}
```

Rationale for R1 answers (README, Ukrainian, short):
- 1.1: users, movies, genres are entities with identity and are shared/reused -> nodes;
  "user rated movie" and "movie belongs to genre" are connections -> edges.
- 1.2: rating as an edge `RATED {rating, timestamp}`. Trade-off: edge = fewer nodes, one-hop
  traversal, natural for recommendations; a `Rating` node would allow linking ratings to other
  entities (tags, sessions), multiple ratings per pair, and indexing ratings as nodes, at the
  cost of 1M extra nodes and twice the hops. MovieLens has one rating per pair and nothing
  else attaches to it, so the edge wins.
- 1.3: `Genre` nodes: genre is a shared entity; traversal `(:Genre)<-[:HAS_GENRE]-()` uses
  relationships instead of scanning every Movie and parsing a list; avoids duplicated
  strings; enables genre-level aggregation and similarity paths through genres.

## 5. Project Structure

```
Svietlov_nosql_3/
├── docker-compose.yml               R-ENV
├── pyproject.toml                   rule 6 (uv init --bare), needed for `uv run`
├── uv.lock                          created by `uv run`, committed
├── convert.py                       R2-CONV
├── part2_load.cypher                R2-LOAD (name and location from requirements)
├── queries/
│   ├── part3.cypher                 R3
│   └── part4_supernodes.cypher      R4
├── import/
│   └── .gitkeep                     R-ENV: folder must exist for convert.py and the mount
├── .gitignore                       keeps large raw/derived data out of git
├── README.md                        R-README (Ukrainian)
└── plan/implementation_plan.md      this file
```

Not committed (`.gitignore`): `*.dat`, `*.zip`, `import/*.csv`, `.venv/`.
Reason: data is large (~24 MB ratings) and fully reproducible from the public download plus
`convert.py`. Raw `.dat` files are placed in the project root, because the requirements'
`convert.py` sample opens `movies.dat` etc. relative to the root.

No other files. No `.env`: the only credential is the local dev password defined by the
requirements inside `docker-compose.yml` (accepted as given).

## 6. Step-by-Step Implementation

### Step 1. Environment (R-ENV)
1. Create `docker-compose.yml` with the requirements' values, fixing the broken YAML
   (indentation, `- "7474:7474"`, `KEY: "value"` spacing):
   ```yaml
   services:
     neo4j:
       image: neo4j:5.18-community
       container_name: neo4j_movielens
       ports:
         - "7474:7474"
         - "7687:7687"
       environment:
         NEO4J_AUTH: neo4j/password123
         NEO4J_PLUGINS: '["apoc", "graph-data-science"]'
         NEO4J_dbms_security_procedures_unrestricted: "apoc.*,gds.*"
         NEO4J_dbms_security_procedures_allowlist: "apoc.*,gds.*"
         NEO4J_dbms_memory_heap_initial__size: "512m"
         NEO4J_dbms_memory_heap_max__size: "2G"
       volumes:
         - neo4j_data:/data
         - neo4j_logs:/logs
         - ./import:/var/lib/neo4j/import

   volumes:
     neo4j_data:
     neo4j_logs:
   ```
   GDS stays in the plugin list only because the values are kept verbatim; it is not used.
2. Create `import/.gitkeep` and `.gitignore` (entries from section 5).
3. Start: `docker compose up -d` (equivalent of the requirements' `docker-compose up -d`).
   Wait until `docker compose exec neo4j cypher-shell -u neo4j -p password123 "RETURN 1"`
   succeeds. Check APOC: `RETURN apoc.version()`.

### Step 2. Dataset download (R2-CONV prerequisite)
```
curl -L -o ml-1m.zip https://files.grouplens.org/datasets/movielens/ml-1m.zip
unzip -j ml-1m.zip 'ml-1m/movies.dat' 'ml-1m/ratings.dat' 'ml-1m/users.dat' -d .
rm ml-1m.zip
```

### Step 3. `convert.py` (R2-CONV)
1. `uv init --bare` (creates only `pyproject.toml`, does not touch README). No dependencies
   (`csv` is stdlib).
2. Write `convert.py` following the requirements' sample, cleaned up:
   - no comments, no output (rules 1, 2);
   - the three copy-pasted blocks become one function `convert(src, dst, header)` that reads
     Latin-1, splits on `::`, writes UTF-8 CSV with the header and `parts[:len(header)]`
     (this drops zip for users, as in the sample); called three times at module level
     (or under `if __name__ == "__main__":`);
   - remove the `\\` copy-paste artifacts (use one `with` with parenthesized context managers).
3. Run `uv run convert.py`. Check `import/` has three CSVs; ratings.csv has 1 000 210 lines.

### Step 4. `part2_load.cypher` (R2-LOAD)
Statement order (no comments in the file; README refers to statements by number):
1. `CREATE CONSTRAINT ... IF NOT EXISTS FOR (u:User) REQUIRE u.userId IS UNIQUE;`
2. Same for `Movie.movieId`.
3. Same for `Genre.name`.
   Uniqueness constraints create backing range indexes, so they satisfy "create indexes
   before loading edges" and also speed up the node MERGEs; they are placed first for that
   reason (still before the edges, as required).
4. Users: `LOAD CSV WITH HEADERS FROM 'file:///users.csv' AS row`
   `MERGE (u:User {userId: toInteger(row.userId)})`
   `SET u.gender = row.gender, u.age = toInteger(row.age), u.occupation = toInteger(row.occupation);`
5. Movies + genres: `LOAD CSV ... 'file:///movies.csv' AS row`
   `MERGE (m:Movie {movieId: toInteger(row.movieId)}) SET m.title = row.title, m.year = ...`
   `WITH m, row UNWIND split(row.genres, '|') AS name`
   `MERGE (g:Genre {name: name}) MERGE (m)-[:HAS_GENRE]->(g);`
6. Ratings via `CALL apoc.periodic.iterate(`
   outer: `"LOAD CSV WITH HEADERS FROM 'file:///ratings.csv' AS row RETURN row"`,
   inner: `"MATCH (u:User {userId: toInteger(row.userId)})
   MATCH (m:Movie {movieId: toInteger(row.movieId)})
   MERGE (u)-[r:RATED]->(m)
   SET r.rating = toInteger(row.rating), r.timestamp = toInteger(row.timestamp)"`,
   `{batchSize: 10000, parallel: false})`. MERGE keeps re-runs idempotent; `parallel: false`
   because the body uses MERGE (the requirements allow `parallel: true` only for MATCH-only
   bodies), and parallel batches locking the same User/Movie nodes can deadlock.
7. Verification queries exactly as in the requirements (users, movies, ratings counts), plus
   none other.
Run: `docker compose exec -T neo4j cypher-shell -u neo4j -p password123 < part2_load.cypher`.
Expected: users 6040, movies 3883, ratings 1000209 (and 18 Genre nodes). Re-running must not
change counts (MERGE idempotence).

### Step 5. `queries/part3.cypher` (R3)
Six statements in order. Planned shape (implementer may refine, keep simple):
1. Thriller avg > 4.0: `MATCH (:Genre {name:'Thriller'})<-[:HAS_GENRE]-(m:Movie)<-[r:RATED]-()`
   `WITH m, avg(r.rating) AS avgRating, count(r) AS ratings WHERE avgRating > 4.0`
   `RETURN m.title, avgRating, ratings ORDER BY avgRating DESC`.
2. Users with > 50 fives: `MATCH (u:User)-[r:RATED]->() WHERE r.rating = 5`
   `WITH u, count(r) AS fives WHERE fives > 50 RETURN u.userId, fives ORDER BY fives DESC`.
3. Movies rated >= 4 by both user 1 and user 2:
   `MATCH (:User {userId:1})-[r1:RATED]->(m:Movie)<-[r2:RATED]-(:User {userId:2})`
   `WHERE r1.rating >= 4 AND r2.rating >= 4 RETURN m.title, r1.rating, r2.rating`.
   Keep userId 1 and 2 (the requirements' example). Only if this returns zero rows, switch to
   another pair with results and say so in one README sentence.
4. Genres by avg rating and number of ratings:
   `MATCH (g:Genre)<-[:HAS_GENRE]-(:Movie)<-[r:RATED]-()`
   `RETURN g.name, avg(r.rating) AS avgRating, count(r) AS ratings ORDER BY avgRating DESC`.
5. Recommendation for user 1 ("similar users also watched"):
   `MATCH (me:User {userId:1})-[r1:RATED]->(:Movie)<-[r2:RATED]-(other:User)`
   `WHERE r1.rating >= 4 AND r2.rating >= 4`
   `WITH me, other, count(*) AS shared ORDER BY shared DESC LIMIT 20`
   `MATCH (other)-[r:RATED]->(rec:Movie)`
   `WHERE r.rating >= 4 AND NOT EXISTS { (me)-[:RATED]->(rec) }`
   `RETURN rec.title, count(other) AS recommenders, avg(r.rating) AS avgRating`
   `ORDER BY recommenders DESC, avgRating DESC LIMIT 10`.
6. Shortest chain between two users through movies:
   `MATCH p = shortestPath((a:User {userId:1})-[:RATED*..10]-(b:User {userId:2}))`
   `RETURN [n IN nodes(p) | coalesce(n.title, n.userId)] AS chain, length(p) AS hops`.
   Undirected pattern because RATED always points User -> Movie.
Run each statement via cypher-shell (`--format plain`) and record the first 10 rows of each
result for the README.

### Step 6. `queries/part4_supernodes.cypher` (R4)
1. Top 20 nodes by degree over all labels:
   `MATCH (n) RETURN labels(n)[0] AS label, coalesce(n.title, n.name, n.userId) AS node,`
   `COUNT { (n)--() } AS degree ORDER BY degree DESC LIMIT 20`.
2. Average and maximum degree per label (`COUNT { (n)--() }` grouped by `labels(n)[0]`), to
   show what is "anomalous" relative to the norm.
3. Genre degrees (`COUNT { (g)<-[:HAS_GENRE]-() }` per genre), needed for question 4.3.
Cypher 5.18 syntax only: `COUNT { }` / `EXISTS { }` subqueries (no `size()` of a pattern),
no `id()` (use key properties), `shortestPath(...)` (the `SHORTEST k` syntax is newer than
5.18). Run all three; record the real numbers (expected roughly: American Beauty ~3428 ratings,
most active user ~2314 ratings, Drama ~1603 movies) for README answers.

### Step 7. `README.md` in Ukrainian (R-README)
Sections, in this order, nothing else:
1. Title.
2. Частина 1: ASCII diagram (section 4), node/edge description with properties and
   direction, answers 1.1, 1.2, 1.3.
3. Частина 2: short explanation of every statement in `part2_load.cypher` (what it does,
   why written this way: MERGE, constraints first, toInteger, split genres, periodic.iterate,
   batchSize, parallel false) and the actual verification counts.
4. Частина 3: for each query 3.1-3.6: explanation (what + why) and the first 10 result rows
   as a text table captured from cypher-shell. One sentence noting that text tables replace
   screenshots (same content: first 10 rows). Then answers on path length: what path length
   means here (number of RATED hops; users and movies alternate, so user-to-user paths are
   even and length/2 - 1 = number of intermediate users); length 2 = two
   users rated the same movie; length 4 = connected via an intermediate user (u1-m1-u-m2-u2);
   length 6 = two intermediate users; longer = weaker connection.
5. Частина 4: explanation of each query, answers 4.1 (real node names and degree counts),
   4.2 (traversal/expansion cost grows with degree: indexes only find the start node, all
   its relationships must still be expanded and filtered, more memory and db hits), 4.3
   (strategy from lectures, e.g. avoid expanding through `Genre`/blockbuster nodes, filter
   early, precomputed aggregates on Movie/Genre, genre as an extra label on Movie, specialized
   relationship types such as `RATED_5`; state that Genre nodes are supernodes in effect,
   because traversing Genre -> Movie -> RATED touches hundreds of thousands of edges).
6. Частина 6: 6.1 (SQL hard for 3.5 and 3.6: self-joins on ratings and recursive CTE with
   unknown depth; include a concrete SQL example over tables
   `users, movies, ratings(user_id, movie_id, rating, ts), movie_genres`), 6.2 (full-table
   aggregations, reports, export, time-based statistics favor SQL/columnar), 6.3 (at least
   two Part 3 queries: precomputed `avgRating`/`ratingCount` on Movie for 3.1/3.4; range
   index on `RATED.rating` or a `RATED_HIGH` type for 3.2/3.3/3.5). Each at least a paragraph.
No run-instructions, architecture or decision sections (rule 11). No Part 5 content.
README is exempt from the 150-line limit only if the required answers need it; keep it concise.

### Step 8. Final check
- Remove all `TEMP-DEBUG` lines; `grep -rn "TEMP-DEBUG" .` returns nothing.
- Every code file < 150 lines, no line > 100 chars (README exempt from the line-count limit).
- No comments in `convert.py` or `.cypher` files.

## 7. Verification Commands

```
docker compose up -d
docker compose exec neo4j cypher-shell -u neo4j -p password123 "RETURN apoc.version()"
uv run convert.py
docker compose exec -T neo4j cypher-shell -u neo4j -p password123 < part2_load.cypher
docker compose exec -T neo4j cypher-shell -u neo4j -p password123 --format plain \
  < queries/part3.cypher
docker compose exec -T neo4j cypher-shell -u neo4j -p password123 --format plain \
  < queries/part4_supernodes.cypher
```
APOC is required for `apoc.periodic.iterate`; it is installed by `NEO4J_PLUGINS`.

## 8. Acceptance Criteria

| # | Criterion | Req |
|---|-----------|-----|
| A1 | `docker compose up -d` starts Neo4j 5.18; Browser at http://localhost:7474, login neo4j/password123; APOC available | R-ENV |
| A2 | `uv run convert.py` creates three UTF-8, comma-separated CSVs in `import/` with headers `movieId,title,genres` / `userId,movieId,rating,timestamp` / `userId,gender,age,occupation`; no output | R2-CONV |
| A3 | `part2_load.cypher` runs without errors; counts: 6040 users, 3883 movies, 1000209 RATED, 18 Genre; second run leaves counts unchanged | R2-LOAD |
| A4 | Nodes loaded with MERGE; constraints/indexes created before edges; edges loaded via `apoc.periodic.iterate` with `parallel: false` | R2-LOAD |
| A5 | `queries/part3.cypher` contains six queries matching 3.1-3.6 and each returns a result | R3 |
| A6 | `queries/part4_supernodes.cypher` lists highest-degree nodes and genre degrees | R4 |
| A7 | README (Ukrainian) has ASCII diagram and answers 1.1-1.3 | R1, R-README |
| A8 | README explains every statement of part2, part3, part4 (what + why) | R2-LOAD, R3, R4 |
| A9 | README has first 10 rows of each Part 3 result (text tables) and path-length answers (2, 4, 6) | R3, R-README |
| A10 | README answers 4.1-4.3 with real degree numbers from the loaded data | R4 |
| A11 | README answers 6.1-6.3, each at least a paragraph, 6.1 includes SQL | R6 |
| A12 | No Part 5 file or README content | R5 |
| A13 | Code rules hold: no comments, no output, no TEMP-DEBUG, files < 150 lines (README exempt), lines <= 100 chars | Rules |
| A14 | Large data (`*.dat`, `import/*.csv`, zip) not committed | Section 5 |

## 9. Traceability

| Requirement | Plan sections |
|-------------|---------------|
| R-ENV | 3, 5, 6 Step 1, 7, A1 |
| R1 (1.1-1.3, diagram) | 4, 6 Step 7.2, A7 |
| R2-CONV | 6 Steps 2-3, A2 |
| R2-LOAD | 6 Step 4, 6 Step 7.3, A3, A4, A8 |
| R3 (3.1-3.6, path length, results) | 6 Step 5, 6 Step 7.4, A5, A9 |
| R4 (step 1, 4.1-4.3) | 6 Step 6, 6 Step 7.5, A6, A10 |
| R5 | 2 (skipped), A12 |
| R6 (6.1-6.3) | 6 Step 7.6, A11 |
| R-README | 6 Step 7, A7-A11 |
| R-SUBMIT | 2 (manual, out of scope) |

## 10. Rules

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

Project-specific notes on the rules:
- `.cypher` files are code: no comments (the requirements' `// 1. ...` markers are dropped);
  README refers to statements by their order in the file.
- Rule 7: `password123` is the local dev credential prescribed by the requirements'
  `docker-compose.yml`; it stays there as given, and README may mention the login as the
  requirements do. No other secrets exist.
- Rule 5: `README.md` is the only file exempt from the 150-line limit, and only because Parts
  2/3/4 explanations, Part 3 result tables and paragraph-length Part 6 answers require it.
  Lines still <= 100 chars where practical (result tables included); keep it concise.
- Rule 2: `convert.py` has no output (the sample has none either). Cypher result output from
  cypher-shell is not program output and is needed for the README.
- Part 3 screenshots are replaced by text tables of the first 10 rows captured from real
  cypher-shell runs (screenshots cannot be generated); README notes this in one sentence.
