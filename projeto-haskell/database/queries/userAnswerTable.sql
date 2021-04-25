CREATE TABLE IF NOT EXISTS user_answer (
    id INTEGER PRIMARY KEY,
    user_id INTEGER NOT NULL,
    quiz_id TEXT NOT NULL,
    rating INTEGER,
    suggestion TEXT,
    score REAL NOT NULL,
    FOREIGN KEY (user_id) REFERENCES user (id),
    FOREIGN KEY (quiz_id) REFERENCES quiz (quiz_id)
);