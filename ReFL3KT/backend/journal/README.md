## Database Schema

### Tables

#### 1. Goals (`journal_api_goal`)
| Field | Type | Description |
|-------|------|-------------|
| `id` | Integer | Primary key (externally provided) |
| `name` | VARCHAR(255) | Goal name |
| `user_id` | Integer | Foreign key to Django User |

#### 2. Tasks (`journal_api_task`) 
| Field | Type | Description |
|-------|------|-------------|
| `id` | Integer | Primary key (externally provided) |
| `name` | VARCHAR(255) | Task name |
| `goal_id` | Integer | Foreign key to Goal |

#### 3. Journal Entries (`journal_api_journalentry`)
| Field | Type | Description |
|-------|------|-------------|
| `user_id` | Integer | Foreign key to Django User |
| `goal_id` | Integer | Foreign key to Goal |
| `task_id` | Integer | Foreign key to Task |
| `entry_date` | Date | Date of journal entry |
| `content` | RichTextField | Rich text journal content |

**Composite Primary Key:** (`user_id`, `goal_id`, `task_id`, `entry_date`)

# API Endpoints

### Goals API

#### List Goals
**Endpoint:** `GET /api/goals/`

**Headers:**
```
Authorization: Token <your_token>
```

**Response:**
```json
[
  {
    "id": 1,
    "name": "Learn Django"
  },
  {
    "id": 2,
    "name": "Build Portfolio"
  }
]
```

#### Create Goal
**Endpoint:** `POST /api/goals/`

**Headers:**
```
Authorization: Token <your_token>
Content-Type: application/json
```

**Request:**
```json
{
  "id": 3,
  "name": "Master React"
}
```

**Response:**
```json
{
  "id": 3,
  "name": "Master React"
}
```

### Tasks API

#### List Tasks
**Endpoint:** `GET /api/tasks/`

**Headers:**
```
Authorization: Token <your_token>
```

**Response:**
```json
[
  {
    "id": 1,
    "name": "Setup Django Project",
    "goal": 1,
    "goal_name": "Learn Django"
  },
  {
    "id": 2,
    "name": "Create REST APIs",
    "goal": 1,
    "goal_name": "Learn Django"
  }
]
```

#### Create Task
**Endpoint:** `POST /api/tasks/`

**Headers:**
```
Authorization: Token <your_token>
Content-Type: application/json
```

**Request:**
```json
{
  "id": 3,
  "name": "Write Documentation",
  "goal": 1
}
```

**Response:**
```json
{
  "id": 3,
  "name": "Write Documentation",
  "goal": 1,
  "goal_name": "Learn Django"
}
```
### Journal Entries API
#### List All Journal Entries
**Endpoint:** `GET /api/journal-entries/`

**Headers:**
```
Authorization: Token <your_token>
```

**Response:**
```json
[
  {
    "user": 1,
    "goal": 1,
    "task": 1,
    "entry_date": "2025-06-22",
    "content": "<p>Today I completed the Django setup</p>",
    "goal_name": "Learn Django",
    "task_name": "Setup Django Project",
    "username": "john_doe"
  }
]
```

#### Create Journal Entry
**Endpoint:** `POST /api/journal-entries/`

**Headers:**
```
Authorization: Token <your_token>
Content-Type: application/json
```

**Request:**
```json
{
  "goal": 1,
  "task": 1,
  "entry_date": "2025-06-22",
  "content": "<p>Today I worked on the API documentation. <strong>Key achievements:</strong></p><ul><li>Created README file</li><li>Documented all endpoints</li></ul>"
}
```

**Response:**
```json
{
  "user": 1,
  "goal": 1,
  "task": 1,
  "entry_date": "2025-06-22",
  "content": "<p>Today I worked on the API documentation. <strong>Key achievements:</strong></p><ul><li>Created README file</li><li>Documented all endpoints</li></ul>",
  "goal_name": "Learn Django",
  "task_name": "Setup Django Project",
  "username": "john_doe"
}
```

#### Get Journal Entries by Date
**Endpoint:** `GET /api/journal-entries/by_date/`

**Query Parameters:**
- `date` (required): Date in YYYY-MM-DD format

**Example:** `GET /api/journal-entries/by_date/?date=2025-06-22`

**Headers:**
```
Authorization: Token <your_token>
```

**Response:**
```json
[
  {
    "user": 1,
    "goal": 1,
    "task": 1,
    "entry_date": "2025-06-22",
    "content": "<p>First entry for today</p>",
    "goal_name": "Learn Django",
    "task_name": "Setup Django Project",
    "username": "john_doe"
  },
  {
    "user": 1,
    "goal": 1,
    "task": 2,
    "entry_date": "2025-06-22",
    "content": "<p>Second entry for today</p>",
    "goal_name": "Learn Django",
    "task_name": "Create REST APIs",
    "username": "john_doe"
  }
]
```

#### Get Journal Entries by Task
**Endpoint:** `GET /api/journal-entries/by_task/`

**Query Parameters:**
- `task_id` (required): Task ID

**Example:** `GET /api/journal-entries/by_task/?task_id=1`

**Headers:**
```
Authorization: Token <your_token>
```

**Response:**
```json
[
  {
    "user": 1,
    "goal": 1,
    "task": 1,
    "entry_date": "2025-06-21",
    "content": "<p>Started working on this task</p>",
    "goal_name": "Learn Django",
    "task_name": "Setup Django Project",
    "username": "john_doe"
  },
  {
    "user": 1,
    "goal": 1,
    "task": 1,
    "entry_date": "2025-06-22",
    "content": "<p>Continued progress on the task</p>",
    "goal_name": "Learn Django",
    "task_name": "Setup Django Project",
    "username": "john_doe"
  }
]
```
## Content Format

### Rich Text Content
The `content` field in journal entries supports HTML formatting:

```html
<p>Basic paragraph text</p>
<p><strong>Bold text</strong> and <em>italic text</em></p>
<ul>
  <li>Bullet point 1</li>
  <li>Bullet point 2</li>
</ul>
<ol>
  <li>Numbered item 1</li>
  <li>Numbered item 2</li>
</ol>
```

## Notes:

1. **Always include trailing slashes** in URLs (e.g., `/api/goals/` not `/api/goals`)
2. **IDs are externally provided** - you must provide the `id` field when creating goals and tasks
3. **Date format** must be YYYY-MM-DD for all date fields
4. **Rich text content** can include HTML tags for formatting
5. **Authentication token** must be included in all requests to protected endpoints
6. **Composite primary key** for journal entries means you can only have one entry per user, goal, task, and date combination

## Do NOt FORGET:
- Make sure to change the settings.py to include this:
    ```
    'rest_framework',
    'journal_api',
    'djrichtextfield',
    ```
    For `INSTALLED APPS`
- Add these into the main urls.py:
    ```
    from django.contrib import admin
from django.urls import path, include
from rest_framework.authtoken.views import obtain_auth_token

urlpatterns = [
    path('admin/', admin.site.urls),
    path('api/', include('journal_api.urls')),
    path('djrichtextfield/', include('djrichtextfield.urls')),
]