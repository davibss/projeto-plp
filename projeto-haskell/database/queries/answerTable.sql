CREATE TABLE IF NOT EXISTS answer (
    answer_id INTEGER PRIMARY KEY AUTOINCREMENT,
    text TEXT NOT NULL,
    question_id TEXT NOT NULL,
    FOREIGN KEY (question_id) REFERENCES question (question_id) ON DELETE CASCADE
);

ALTER TABLE answer RENAME COLUMN id TO answer_id;