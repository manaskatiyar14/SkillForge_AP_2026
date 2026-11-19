
-- A1. Find a user during login
SELECT id, full_name, email, password_hash, created_at
FROM users
WHERE email = $1;

-- A2. Get user profile details
SELECT id, full_name, email, created_at
FROM users
WHERE id = $1;

-- A3. Create a new user account
INSERT INTO users (full_name, email, password_hash)
VALUES ($1, $2, $3)
RETURNING id, full_name, email, created_at;

-- A4. Update a user's name
UPDATE users
SET full_name = $1
WHERE id = $2
RETURNING id, full_name, email, created_at;


-- ============================================================
-- B. QUESTIONS
-- ============================================================

-- B1. Get all questions
SELECT id, title, description, option_a, option_b,
       option_c, option_d, category, difficulty, created_at
FROM questions
ORDER BY id;

-- B2. Find questions by category
SELECT id, title, description, option_a, option_b,
       option_c, option_d, category, difficulty, created_at
FROM questions
WHERE LOWER(category) = LOWER($1)
ORDER BY id;

-- B3. Find questions by difficulty
SELECT id, title, description, option_a, option_b,
       option_c, option_d, category, difficulty, created_at
FROM questions
WHERE LOWER(difficulty) = LOWER($1)
ORDER BY id;

-- B4. Get one question by ID
SELECT id, title, description, option_a, option_b,
       option_c, option_d, category, difficulty, created_at
FROM questions
WHERE id = $1;

-- B5. Get correct answer and explanation (Admin only)
SELECT *
FROM questions
WHERE id = $1;

-- B6. Add a new question (Admin only)
INSERT INTO questions (
    title, description, option_a, option_b,
    option_c, option_d, correct_option,
    explanation, category, difficulty
)
VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10)
RETURNING id, title, description, option_a, option_b,
          option_c, option_d, category, difficulty, created_at;

-- B7. Update a question (Admin only)
UPDATE questions
SET title = $1,
    description = $2,
    option_a = $3,
    option_b = $4,
    option_c = $5,
    option_d = $6,
    correct_option = $7,
    explanation = $8,
    category = $9,
    difficulty = $10
WHERE id = $11
RETURNING id, title, description, option_a, option_b,
          option_c, option_d, category, difficulty, created_at;

-- B8. Delete a question (Admin only)
DELETE FROM questions
WHERE id = $1;


-- ============================================================
-- C. SUBMISSIONS
-- ============================================================

-- C1. Get the correct answer for checking a submission
SELECT correct_option, explanation
FROM questions
WHERE id = $1;

-- C2. Save a user's answer
INSERT INTO submissions (
    user_id, question_id, selected_option,
    is_correct, attempt_id
)
VALUES ($1, $2, $3, $4, $5)
RETURNING *;

-- C3. Get the latest 50 submissions of a user
SELECT s.id, s.question_id, q.title, q.category,
       q.difficulty, s.selected_option,
       s.is_correct, s.submitted_at
FROM submissions AS s
JOIN questions AS q ON q.id = s.question_id
WHERE s.user_id = $1
ORDER BY s.submitted_at DESC
LIMIT 50;

-- C4. Get all attempts for one question
SELECT id, user_id, selected_option, is_correct, submitted_at
FROM submissions
WHERE question_id = $1
ORDER BY submitted_at DESC;

-- C5. Count correct and incorrect attempts
SELECT
    COUNT(*) FILTER (WHERE is_correct)::integer AS correct_attempts,
    COUNT(*) FILTER (WHERE NOT is_correct)::integer AS incorrect_attempts
FROM submissions
WHERE user_id = $1;

-- C6. Count different questions solved correctly
SELECT COUNT(DISTINCT question_id)::integer AS total_solved
FROM submissions
WHERE user_id = $1
  AND is_correct = TRUE;


-- ============================================================
-- D. CONTESTS
-- ============================================================

-- D1. Show all contests with registration counts
SELECT c.*, COUNT(r.id)::integer AS registration_count
FROM contests AS c
LEFT JOIN contest_registrations AS r
    ON r.contest_id = c.id
GROUP BY c.id
ORDER BY c.start_time ASC;

-- D2. Get details of one contest
SELECT *
FROM contests
WHERE id = $1;

-- D3. Register a user for a contest
INSERT INTO contest_registrations (user_id, contest_id)
VALUES ($1, $2)
RETURNING *;

-- D4. Register a user without creating duplicate registrations
INSERT INTO contest_registrations (user_id, contest_id)
VALUES ($1, $2)
ON CONFLICT (user_id, contest_id) DO NOTHING
RETURNING *;

-- D5. Get all contests registered by a user
SELECT c.*, r.registered_at
FROM contests AS c
JOIN contest_registrations AS r
    ON r.contest_id = c.id
WHERE r.user_id = $1
ORDER BY c.start_time;

-- D6. Check whether a user is registered
SELECT EXISTS (
    SELECT 1
    FROM contest_registrations
    WHERE user_id = $1
      AND contest_id = $2
) AS is_registered;


-- ============================================================
-- E. USER PROGRESS
-- ============================================================

-- E1. Get saved progress of a user
SELECT user_id, total_solved, overall_rating, updated_at
FROM user_progress
WHERE user_id = $1;

-- E2. Calculate a user's performance
SELECT
    COUNT(s.id)::integer AS total_attempted,

    COUNT(s.id) FILTER (
        WHERE s.is_correct
    )::integer AS correct_attempts,

    COUNT(s.id) FILTER (
        WHERE NOT s.is_correct
    )::integer AS incorrect_answers,

    COALESCE(up.total_solved, 0)::integer AS total_solved,

    COALESCE(up.overall_rating, 0)::integer AS overall_rating,

    CASE
        WHEN COUNT(s.id) = 0 THEN 0
        ELSE ROUND(
            100.0 * COUNT(s.id) FILTER (WHERE s.is_correct)
            / COUNT(s.id), 1
        )
    END AS accuracy_percentage

FROM users AS u
LEFT JOIN user_progress AS up
    ON up.user_id = u.id
LEFT JOIN submissions AS s
    ON s.user_id = u.id
WHERE u.id = $1
GROUP BY up.total_solved, up.overall_rating;


-- ============================================================
-- F. REPORTS
-- ============================================================

-- F1. Find the most attempted questions
SELECT q.id, q.title,
       COUNT(s.id)::integer AS attempt_count
FROM questions AS q
JOIN submissions AS s
    ON s.question_id = q.id
GROUP BY q.id, q.title
ORDER BY attempt_count DESC, q.id
LIMIT 10;

-- F2. Find questions with the most correct answers
SELECT q.id, q.title,
       COUNT(s.id)::integer AS correct_count
FROM questions AS q
JOIN submissions AS s
    ON s.question_id = q.id
WHERE s.is_correct = TRUE
GROUP BY q.id, q.title
ORDER BY correct_count DESC, q.id
LIMIT 10;

-- F3. Count registrations for each contest
SELECT c.id, c.title,
       COUNT(r.id)::integer AS registration_count
FROM contests AS c
LEFT JOIN contest_registrations AS r
    ON r.contest_id = c.id
GROUP BY c.id, c.title
ORDER BY c.start_time;

-- F4. Get overall performance of all users
SELECT
    u.id,
    u.full_name,

    COALESCE(p.total_attempted, 0)::integer AS total_attempted,

    COALESCE(p.correct_attempts, 0)::integer AS correct_attempts,

    COALESCE(up.total_solved, 0)::integer AS total_solved,

    COALESCE(up.overall_rating, 0)::integer AS overall_rating

FROM users AS u

LEFT JOIN user_progress AS up
    ON up.user_id = u.id

LEFT JOIN LATERAL (
    SELECT
        COUNT(*) AS total_attempted,
        COUNT(*) FILTER (WHERE is_correct) AS correct_attempts
    FROM submissions
    WHERE user_id = u.id
) AS p ON TRUE

ORDER BY u.id;


-- ============================================================
-- END OF SKILLFORGE SQL QUERIES
-- ============================================================
