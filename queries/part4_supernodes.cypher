MATCH (n)
RETURN labels(n)[0] AS label,
       coalesce(n.title, n.name, toString(n.userId)) AS node,
       COUNT { (n)--() } AS degree
ORDER BY degree DESC
LIMIT 20;

MATCH (n)
WITH labels(n)[0] AS label, COUNT { (n)--() } AS degree
RETURN label,
       count(*) AS nodes,
       avg(degree) AS avgDegree,
       max(degree) AS maxDegree
ORDER BY maxDegree DESC;

MATCH (g:Genre)
RETURN g.name AS genre, COUNT { (g)<-[:HAS_GENRE]-() } AS movies
ORDER BY movies DESC;
