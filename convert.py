import csv


def convert(src, dst, header):
    with (
        open(src, encoding="latin-1") as fin,
        open(dst, "w", encoding="utf-8", newline="") as fout,
    ):
        writer = csv.writer(fout)
        writer.writerow(header)
        for line in fin:
            parts = line.rstrip("\n").split("::")
            writer.writerow(parts[: len(header)])


convert("movies.dat", "import/movies.csv", ["movieId", "title", "genres"])
convert(
    "ratings.dat",
    "import/ratings.csv",
    ["userId", "movieId", "rating", "timestamp"],
)
convert(
    "users.dat",
    "import/users.csv",
    ["userId", "gender", "age", "occupation"],
)
