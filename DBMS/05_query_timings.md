# SkillForge Query Execution Timings

Database: `skillforge`

Each query was executed three times using `EXPLAIN (ANALYZE, BUFFERS)`.
Every execution was wrapped in `BEGIN` and `ROLLBACK`.
Execution times are in milliseconds.

| Query | Type | What it does | Run 1 (ms) | Run 2 (ms) | Run 3 (ms) | Average (ms) | Scan type |
|---|---|---|---:|---:|---:|---:|---|
| R1 | READ | Find a user during login | 0.164 | 0.015 | 0.011 | 0.063 | Index Scan |
| R2 | READ | Get user profile details | 0.031 | 0.012 | 0.012 | 0.018 | Index Scan |
| W1 | WRITE | Create a new user account | 0.188 | 0.027 | 0.021 | 0.079 | Insert |
| W2 | WRITE | Update a user's name | 0.678 | 0.069 | 0.047 | 0.265 | Update, Index Scan |
| R3 | READ | Get all questions | 0.552 | 0.534 | 0.395 | 0.494 | Index Scan |
| R4 | READ | Find questions by category | 0.453 | 0.787 | 0.870 | 0.703 | Seq Scan |
| R5 | READ | Find questions by difficulty | 0.936 | 0.507 | 0.876 | 0.773 | Seq Scan |
| R6 | READ | Get one question by ID | 0.015 | 0.008 | 0.007 | 0.010 | Index Scan |
| R7 | READ | Get correct answer and explanation | 0.006 | 0.007 | 0.006 | 0.006 | Index Scan |
| W3 | WRITE | Add a new question | 0.415 | 0.058 | 0.045 | 0.173 | Insert |
| W4 | WRITE | Update a question | 0.082 | 0.063 | 0.062 | 0.069 | Update, Index Scan |
| W5 | WRITE | Delete a question | 0.585 | 0.083 | 0.075 | 0.248 | Delete, Index Scan |
| R8 | READ | Get the correct answer for checking a submission | 0.014 | 0.007 | 0.007 | 0.009 | Index Scan |
| W6 | WRITE | Save a user's answer | 0.403 | 0.111 | 0.079 | 0.198 | Insert |
| R9 | READ | Get the latest 50 submissions of a user | 0.797 | 0.469 | 0.518 | 0.595 | Seq Scan, Index Scan, Bitmap Heap Scan, Bitmap Index Scan |
| R10 | READ | Get all attempts for one question | 0.018 | 0.016 | 0.015 | 0.016 | Index Scan, Bitmap Heap Scan, Bitmap Index Scan |
| R11 | READ | Count correct and incorrect attempts | 0.031 | 0.019 | 0.017 | 0.022 | Index Scan, Bitmap Heap Scan, Bitmap Index Scan |
| R12 | READ | Count different questions solved correctly | 0.027 | 0.022 | 0.032 | 0.027 | Index Scan, Bitmap Heap Scan, Bitmap Index Scan |
| R13 | READ | Show all contests with registration counts | 3.360 | 2.182 | 2.516 | 2.686 | Seq Scan |
| R14 | READ | Get details of one contest | 0.008 | 0.008 | 0.005 | 0.007 | Seq Scan |
| W7 | WRITE | Register a user for a contest | 0.249 | 0.042 | 0.036 | 0.109 | Insert |
| W8 | WRITE | Register a user without duplicate registrations | 0.012 | 0.007 | 0.005 | 0.008 | Insert |
| R15 | READ | Get all contests registered by a user | 0.030 | 0.029 | 0.022 | 0.027 | Seq Scan, Index Scan, Bitmap Heap Scan, Bitmap Index Scan |
| R16 | READ | Check whether a user is registered | 0.057 | 0.006 | 0.004 | 0.022 | Index Only Scan |
| R17 | READ | Get saved progress of a user | 0.013 | 0.005 | 0.004 | 0.007 | Index Scan |
| R18 | READ | Calculate a user's performance | 0.068 | 0.038 | 0.031 | 0.046 | Index Only Scan, Index Scan, Bitmap Heap Scan, Bitmap Index Scan |
| R19 | READ | Find the most attempted questions | 6.464 | 4.927 | 4.984 | 5.458 | Seq Scan |
| R20 | READ | Find questions with the most correct answers | 2.579 | 2.432 | 2.565 | 2.525 | Seq Scan |
| R21 | READ | Count registrations for each contest | 1.894 | 1.787 | 1.714 | 1.798 | Seq Scan |
| R22 | READ | Get overall performance of all users | 6.881 | 5.686 | 5.567 | 6.045 | Index Scan, Bitmap Heap Scan, Bitmap Index Scan |

Detailed execution plans for all three runs are in `DBMS/plans/`.