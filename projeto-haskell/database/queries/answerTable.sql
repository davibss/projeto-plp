CREATE TABLE IF NOT EXISTS answer (
    id INTEGER PRIMARY KEY,
    texto TEXT NOT NULL,
    question_id INTEGER NOT NULL,
    FOREIGN KEY (question_id) REFERENCES question (id)
);