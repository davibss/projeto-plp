CREATE TABLE IF NOT EXISTS question (
    question_id TEXT PRIMARY KEY,
    formulation TEXT NOT NULL,
    difficulty INTEGER NOT NULL,
    time INTEGER NOT NULL,
    right_answer TEXT,
    quiz_id TEXT NOT NULL,
    type_question INTEGER NOT NULL,
    FOREIGN KEY (quiz_id) REFERENCES quiz (quiz_id) ON DELETE CASCADE
);