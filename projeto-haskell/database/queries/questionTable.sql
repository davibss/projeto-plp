CREATE TABLE IF NOT EXISTS question (
    id INTEGER PRIMARY KEY,
    formulation TEXT NOT NULL,
    time INTEGER NOT NULL,
    right_answer INTEGER NOT NULL,
    quiz_id INTEGER NOT NULL,
    FOREIGN KEY (quiz_id) REFERENCES quiz (id)
);