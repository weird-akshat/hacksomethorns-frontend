# Group Study API Documentation

**Base URL:** `http://localhost:8080`  
**API Version:** `v1`  
**Content-Type:** `application/json`

## 📊 Database Schema

### Primary Tables

#### `group_studies`
The main table storing group study session data with denormalized fields for performance.

| Column | Type | Description |
|--------|------|-------------|
| `group_code` | `bigint` | **Primary Key** - Randomly generated 9-digit group identifier |
| `goal_id` | `integer` | Foreign key reference to goal |
| `task_id` | `integer` | Foreign key reference to task |
| `user_id` | `integer` | User identifier |
| `goal_name` | `varchar(255)` | Denormalized goal name for quick access |
| `task_name` | `varchar(255)` | Denormalized task name for quick access |
| `user_name` | `varchar(255)` | Username for display purposes |
| `goal_completion` | `decimal(5,2)` | Progress percentage (0.00 - 100.00) |

#### `journal_api_goal` (Referenced)
Shared with Django journaling system.

| Column | Type | Description |
|--------|------|-------------|
| `id` | `integer` | **Primary Key** - Auto-incrementing goal ID |
| `name` | `varchar(255)` | Goal name/title |

#### `journal_api_task` (Referenced)
Shared with Django journaling system.

| Column | Type | Description |
|--------|------|-------------|
| `id` | `integer` | **Primary Key** - Auto-incrementing task ID |
| `name` | `varchar(255)` | Task name/title |
| `goal_id` | `integer` | Foreign key to goal table |

## 🔗 API Endpoints

### 1. Create New Group

Creates a new study group with initial goal and task.

**Endpoint:** `POST /api/v1/groups`

**Request Body:**
```json
{
  "goal_name": "Learn Go Programming",
  "task_name": "Complete Gin Tutorial",
  "user_id": 1,
  "user_name": "john_doe"
}
```

**Response:** `201 Created`
```json
{
  "group_code": 123456789,
  "message": "Group created successfully",
  "data": {
    "group_code": 123456789,
    "goal_id": 1,
    "task_id": 1,
    "user_id": 1,
    "goal_name": "Learn Go Programming",
    "task_name": "Complete Gin Tutorial",
    "user_name": "john_doe",
    "goal_completion": 0.0
  }
}
```

---

### 2. Join Existing Group

Allows a user to join an existing study group using the group code.

**Endpoint:** `POST /api/v1/groups/join`

**Request Body:**
```json
{
  "group_code": 123456789,
  "user_id": 2,
  "user_name": "jane_smith"
}
```

**Response:** `201 Created`
```json
{
  "message": "Successfully joined group",
  "data": {
    "group_code": 123456789,
    "goal_id": 1,
    "task_id": 1,
    "user_id": 2,
    "goal_name": "Learn Go Programming",
    "task_name": "Complete Gin Tutorial",
    "user_name": "jane_smith",
    "goal_completion": 0.0
  }
}
```


---

### 3. Leave Group

Removes a user from a study group.

**Endpoint:** `DELETE /api/v1/groups/{groupCode}/users/{userID}`

**Path Parameters:**
- `groupCode` (integer) - The group code
- `userID` (integer) - The user ID to remove

**Response:** `200 OK`
```json
{
  "message": "Successfully left group"
}
```


---

### 4. Get User Progress

Retrieves progress information for a specific user in a group.

**Endpoint:** `GET /api/v1/groups/{groupCode}/users/{userID}/progress`

**Path Parameters:**
- `groupCode` (integer) - The group code
- `userID` (integer) - The user ID

**Response:** `200 OK`
```json
{
  "data": {
    "group_code": 123456789,
    "goal_id": 1,
    "task_id": 1,
    "user_id": 1,
    "goal_name": "Learn Go Programming",
    "task_name": "Complete Gin Tutorial",
    "user_name": "john_doe",
    "goal_completion": 75.5
  }
}
```

**Error Responses:**
- `404 Not Found` - User progress not found

---

### 5. Update User Progress

Updates the completion percentage for a user's goal progress.

**Endpoint:** `PUT /api/v1/groups/{groupCode}/users/{userID}/progress`

**Path Parameters:**
- `groupCode` (integer) - The group code
- `userID` (integer) - The user ID

**Request Body:**
```json
{
  "goal_completion": 85.5
}
```

**Validation:**
- `goal_completion` must be between 0.0 and 100.0

**Response:** `200 OK`
```json
{
  "message": "Progress updated successfully"
}
```

**Error Responses:**
- `400 Bad Request` - Invalid completion value (outside 0-100 range)
- `404 Not Found` - User not found in group
- `500 Internal Server Error` - Database error

---

### 6. Get Group Progress

Retrieves progress for all members in a study group.

**Endpoint:** `GET /api/v1/groups/{groupCode}/progress`

**Path Parameters:**
- `groupCode` (integer) - The group code

**Response:** `200 OK`
```json
{
  "group_code": "123456789",
  "members": [
    {
      "group_code": 123456789,
      "goal_id": 1,
      "task_id": 1,
      "user_id": 1,
      "goal_name": "Learn Go Programming",
      "task_name": "Complete Gin Tutorial",
      "user_name": "john_doe",
      "goal_completion": 85.5
    },
    {
      "group_code": 123456789,
      "goal_id": 1,
      "task_id": 1,
      "user_id": 2,
      "goal_name": "Learn Go Programming",
      "task_name": "Complete Gin Tutorial",
      "user_name": "jane_smith",
      "goal_completion": 60.0
    }
  ],
  "total_members": 2
}
```

**Error Responses:**
- `500 Internal Server Error` - Database error

---

### 7. Add Task to Group

Adds a new task to an existing group. The task is automatically assigned to all current group members.

**Endpoint:** `POST /api/v1/groups/{groupCode}/tasks`

**Path Parameters:**
- `groupCode` (integer) - The group code

**Request Body:**
```json
{
  "task_name": "Write Unit Tests"
}
```

**Response:** `201 Created`
```json
{
  "message": "Task added to group successfully",
  "task": {
    "id": 2,
    "name": "Write Unit Tests",
    "goal_id": 1
  }
}
```

---


### Validation Rules

1. **Group Code**: 9-digit integer (auto-generated)
2. **User ID**: Positive integer
3. **Goal Completion**: Decimal between 0.00 and 100.00
4. **Required Fields**: All fields marked as `binding:"required"` must be provided
5. **String Fields**: Goal names, task names, and usernames should be non-empty strings

## 🔄 Typical Workflow

1. **Create Group**: User creates a new study group with initial goal/task
2. **Share Code**: Group creator shares the 9-digit group code with others
3. **Join Group**: Other users join using the group code
4. **Track Progress**: Users update their individual progress
5. **Monitor Group**: All members can view group-wide progress
6. **Add Tasks**: Group members can add new tasks to the shared goal
7. **Leave Group**: Users can leave the group when needed

## 📋 Data Relationships

```
Group Study Session
├── group_code (Primary Key)
├── References goal (journal_api_goal.id)
├── References task (journal_api_task.id)
├── Contains user_id, user_name
└── Tracks goal_completion percentage

Multiple users can share:
├── Same group_code
├── Same goal_id
└── Different task_id (when tasks are added)
```

## 🚨 Important Notes

1. **No Authentication**: This API currently has no authentication layer
2. **Data Persistence**: All data is stored in PostgreSQL database
3. **Group Codes**: Are cryptographically secure 9-digit numbers
4. **Shared Database**: Uses the same PostgreSQL instance as the Django journaling API
5. **Denormalized Data**: User names and goal/task names are stored redundantly for performance

### Change this for Backend:
```go

func ConnectDatabase() {
	dsn := "host=localhost user=username123 password=pass123 dbname=journal_db port=5432 sslmode=disable"
```
Change this to the configured database.