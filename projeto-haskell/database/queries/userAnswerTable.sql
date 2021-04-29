CREATE TABLE IF NOT EXISTS user_answer (
    user_answer_id TEXT PRIMARY KEY,
    user_id TEXT NOT NULL,
    quiz_id TEXT NOT NULL,
    rating INTEGER,
    suggestion TEXT,
    score REAL NOT NULL,
    FOREIGN KEY (user_id) REFERENCES user (user_id),
    FOREIGN KEY (quiz_id) REFERENCES quiz (quiz_id)
);

ALTER TABLE user_answer ADD COLUMN created_at TEXT;