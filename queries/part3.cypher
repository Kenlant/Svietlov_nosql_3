MATCH (:Genre {name: 'Thriller'})<-[:HAS_GENRE]-(m:Movie)<-[r:RATED]-()
WITH m, avg(r.rating) AS avgRating, count(r) AS ratings
WHERE avgRating > 4.0
RETURN m.title AS title, avgRating, ratings
ORDER BY avgRating DESC;

MATCH (u:User)-[r:RATED]->(:Movie)
WHERE r.rating = 5
WITH u, count(r) AS fives
WHERE fives > 50
RETURN u.userId AS userId, fives
ORDER BY fives DESC;

MATCH (:User {userId: 1})-[r1:RATED]->(m:Movie)<-[r2:RATED]-(:User {userId: 2})
WHERE r1.rating >= 4 AND r2.rating >= 4
RETURN m.title AS title, r1.rating AS user1Rating, r2.rating AS user2Rating;

MATCH (g:Genre)<-[:HAS_GENRE]-(:Movie)<-[r:RATED]-()
RETURN g.name AS genre, avg(r.rating) AS avgRating, count(r) AS ratings
ORDER BY avgRating DESC;

MATCH (me:User {userId: 1})-[r1:RATED]->(:Movie)<-[r2:RATED]-(other:User)
WHERE r1.rating >= 4 AND r2.rating >= 4 AND other <> me
WITH me, other, count(*) AS shared
ORDER BY shared DESC
LIMIT 20
MATCH (other)-[r:RATED]->(rec:Movie)
WHERE r.rating >= 4 AND NOT EXISTS { (me)-[:RATED]->(rec) }
RETURN rec.title AS title, count(other) AS recommenders, avg(r.rating) AS avgRating
ORDER BY recommenders DESC, avgRating DESC
LIMIT 10;

MATCH p = shortestPath((a:User {userId: 1})-[:RATED*..10]-(b:User {userId: 2}))
RETURN [n IN nodes(p) | coalesce(n.title, n.userId)] AS chain, length(p) AS hops;
