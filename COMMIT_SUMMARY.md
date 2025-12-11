# AI Assistant Feature - Implementation Summary

## Commits

**Commit 1: 2c281299** - Add AI Assistant feature with OpenAI integration  
**Commit 2: 978b7c23** - Add cookies.txt to gitignore to prevent accidental commits of auth tokens

## Overview

This implementation adds a comprehensive AI-powered assistant to Open OnDemand that helps users manage HPC tasks through natural language conversations.

## Architecture

```
┌─────────────────────────────────────────┐
│           Frontend (Browser)             │
│  • Floating purple chat bubble           │
│  • Inline HTML/CSS/JavaScript            │
│  • Vanilla JS (no dependencies)          │
│  • CSRF token handling                   │
└─────────────────┬───────────────────────┘
                  │ POST /pun/sys/dashboard/assistant/chat
                  ▼
┌─────────────────────────────────────────┐
│      AssistantController (Rails)         │
│  • OpenAI API integration                │
│  • Function calling with 12 tools        │
│  • Conversation history management       │
│  • Error handling and logging            │
└─────────────────┬───────────────────────┘
                  │
        ┌─────────┴─────────┐
        ▼                   ▼
┌──────────────┐   ┌──────────────────┐
│  OpenAI API  │   │  OOD Core Libs   │
│  • GPT-4o    │   │  • Job adapters  │
│  • Tools     │   │  • File ops      │
└──────────────┘   │  • Clusters      │
                   └──────────────────┘
```

## Files Added/Modified

### New Files

1. **`apps/dashboard/app/controllers/assistant_controller.rb`** (465 lines)
   - Backend LLM agent with OpenAI function calling
   - 12 tools for HPC operations
   - Read tools: list_jobs, get_job_details, delete_job, list_files, read_file, get_file_info, get_cluster_status, list_interactive_sessions, get_available_apps
   - Write tools: create_file, submit_batch_job, create_and_submit_job

2. **`apps/dashboard/app/views/layouts/_assistant.html.erb`** (320 lines)
   - Complete inline widget implementation
   - Includes HTML structure, CSS styles, and JavaScript
   - Bypasses asset pipeline for easier deployment

3. **`apps/dashboard/app/javascript/assistant.js`** (295 lines)
   - Modular ES6 class-based widget
   - Full chat UI with history
   - Markdown formatting support
   - Auto-scroll and loading states

4. **`apps/dashboard/app/assets/stylesheets/assistant.css`** (360 lines)
   - Purple gradient theme
   - Responsive design (mobile-friendly)
   - Dark mode support
   - Smooth animations

5. **`DOCKER_SETUP.md`** (265 lines)
   - Complete Docker development guide
   - Step-by-step container setup
   - Basic Auth configuration
   - AI Assistant setup instructions

6. **`apps/dashboard/AI_ASSISTANT.md`** (370 lines)
   - Feature documentation
   - Usage examples
   - Customization guide
   - API reference
   - Troubleshooting

### Modified Files

1. **`apps/dashboard/config/routes.rb`**
   ```ruby
   # AI Assistant routes
   post 'assistant/chat', to: 'assistant#chat'
   get 'assistant/status', to: 'assistant#status'
   ```

2. **`apps/dashboard/app/assets/stylesheets/application.scss`**
   ```scss
   @import "assistant";
   ```

3. **`apps/dashboard/app/javascript/application.js`**
   ```javascript
   // Import AI Assistant widget
   import './assistant';
   ```

4. **`.gitignore`**
   ```
   # Authentication cookies and session files
   cookies.txt
   *.cookie
   *.session
   ```

## Features

### Core Capabilities

1. **Job Management**
   - List all jobs across clusters
   - Filter by state (running, pending, completed)
   - View detailed job information
   - Delete/cancel jobs (with user confirmation)

2. **File Operations**
   - Browse directories
   - List files with metadata
   - Read text file contents (first 100 lines)
   - Get file/directory information
   - Create new files with content
   - Submit batch job scripts

3. **Batch Job Submission**
   - Create job scripts on the fly
   - Submit existing scripts
   - Combined create-and-submit operation
   - Security: restricted to user's home directory

4. **Cluster Information**
   - View available clusters
   - Check cluster status
   - See job queue statistics

5. **Interactive Sessions**
   - List active sessions (Jupyter, Desktop, etc.)
   - View session status and time remaining
   - Discover available applications

### User Interface

- **Floating Chat Bubble**: Always accessible from bottom-right corner
- **Chat Window**: 380px width, 520px height, responsive on mobile
- **Message History**: Maintains conversation context (last 10 messages)
- **Loading States**: Animated typing indicator during API calls
- **Error Handling**: User-friendly error messages
- **Markdown Support**: Code blocks, bold, italic, links

### Security

- **Authentication**: Runs in user's authenticated session
- **Authorization**: Uses user's permissions (no privilege escalation)
- **Path Validation**: File operations restricted to home directory
- **CSRF Protection**: Rails CSRF token validation
- **No Persistence**: Conversation history client-side only

## Configuration

### Environment Variables

```bash
# Required
OPENAI_API_KEY=your-api-key-here

# Optional
OPENAI_MODEL=gpt-4o-mini  # Default: gpt-4o-mini
```

### Setup (Production)

```bash
# 1. Set API key
echo "OPENAI_API_KEY=your-api-key-here" >> /etc/ood/config/apps/dashboard/env

# 2. Restart web server
sudo systemctl restart httpd

# 3. Verify
curl http://localhost/pun/sys/dashboard/assistant/status
```

### Setup (Docker Development)

```bash
# 1. Add to container environment
docker exec ood-dev-container bash -c \
  'echo "OPENAI_API_KEY=your-api-key-here" >> /etc/ood/config/apps/dashboard/env'

# 2. Restart app
docker exec ood-dev-container touch /var/www/ood/apps/sys/dashboard/tmp/restart.txt

# 3. Test
curl -u username:password http://localhost:8080/pun/sys/dashboard/assistant/chat \
  -H "Content-Type: application/json" \
  -d '{"message": "Hello"}'
```

## Technical Decisions

### Why Inline Partial Instead of Asset Pipeline?

The initial implementation attempted to use Rails asset pipeline (Sprockets), but encountered challenges:

1. **Precompiled Assets**: Production mode uses precompiled assets with fingerprints
2. **Manifest Complexity**: Sprockets manifest requires exact file matching
3. **Deployment Friction**: Live changes require full asset recompilation
4. **Container Constraints**: Rebuilding assets in running container is complex

**Solution**: Inline partial (`_assistant.html.erb`) with complete HTML/CSS/JS
- ✅ Works immediately without asset pipeline
- ✅ Easy to update (just copy file and restart)
- ✅ No build step required
- ✅ Single file to maintain
- ⚠️ Trade-off: Slightly larger HTML payload (acceptable for feature)

### Why Basic Auth Instead of Dex OIDC?

For development simplicity:
- Dex requires SSL, proper DNS, complex configuration
- Basic Auth with htpasswd works immediately
- Easier to test and debug
- Production deployments typically use existing SSO

### Why 12 Tools?

Started with 9 read-only tools, added 3 write tools based on user request:
- `create_file` - Write any file content
- `submit_batch_job` - Submit existing script to scheduler
- `create_and_submit_job` - Create script + submit in one step

This gives full CRUD capability while maintaining safety through:
- Path validation (home directory only)
- User permission checks
- Confirmation prompts for destructive actions

## Usage Examples

### Example 1: Check Running Jobs

```
User: Show me my running jobs
Assistant: You have 3 running jobs:

| Job ID | Name | Cluster | Queue | Nodes |
|--------|------|---------|-------|-------|
| 12345 | simulation_v2 | pitzer | batch | 4 |
| 12346 | data_process | owens | serial | 1 |
| 12347 | ml_training | pitzer | gpu | 2 |
```

### Example 2: Create and Submit Job

```
User: Create a simple hello world job script and submit it to the cluster
Assistant: I'll create a job script for you and submit it.

[Creates file ~/hello_job.sh with SLURM headers]

✅ Job script created at /home/user/hello_job.sh and submitted as job 12348 to pitzer cluster.
```

### Example 3: Browse Files

```
User: What's in my home directory?
Assistant: Here are the contents of /home/user:

📁 projects/
📁 data/
📁 scratch/
📄 hello_job.sh (245 bytes)
📄 .bashrc (3.2 KB)

Would you like me to look inside any of these directories?
```

## API Endpoints

### POST /pun/sys/dashboard/assistant/chat

Send a message to the assistant.

**Request:**
```json
{
  "message": "Show me my jobs",
  "history": [
    {"role": "user", "content": "Hello"},
    {"role": "assistant", "content": "Hi! How can I help?"}
  ]
}
```

**Response:**
```json
{
  "success": true,
  "response": "You have 3 running jobs..."
}
```

### GET /pun/sys/dashboard/assistant/status

Check if the assistant is enabled.

**Response:**
```json
{
  "enabled": true,
  "features": {
    "jobs": true,
    "files": true,
    "batch_connect": true,
    "system_status": true
  }
}
```

## Testing

### Manual Testing

```bash
# 1. Test status endpoint
curl http://localhost:8080/pun/sys/dashboard/assistant/status

# 2. Test chat endpoint
curl -u saki:password http://localhost:8080/pun/sys/dashboard/assistant/chat \
  -H "Content-Type: application/json" \
  -d '{"message": "What jobs are running?"}'

# 3. Test in browser
# - Open http://localhost:8080/
# - Login (username / password)
# - Click purple bubble in bottom-right
# - Type "Show me my running jobs"
```

### Verification Checklist

- [x] Purple bubble appears on all pages
- [x] Clicking bubble opens chat window
- [x] Can send messages and receive responses
- [x] Messages appear in correct order
- [x] Loading indicator shows during API calls
- [x] Error messages display properly
- [x] Clear button resets conversation
- [x] Close button hides chat window
- [x] Responsive on mobile screens
- [x] OpenAI API key configured correctly
- [x] All 12 tools functional
- [x] CSRF token validation working
- [x] Markdown formatting displays correctly

## Known Issues & Limitations

1. **No Conversation Persistence**: History is client-side only (refreshing page loses context)
2. **Rate Limiting**: No built-in rate limiting (consider adding for production)
3. **Cost**: OpenAI API calls have usage costs (monitor with OpenAI dashboard)
4. **Large Files**: File reading limited to 100KB (prevents memory issues)
5. **Binary Files**: Cannot read binary files (only text)
6. **No Streaming**: Responses are not streamed (full response at once)

## Future Enhancements

1. **Conversation Persistence**: Store history in database or session
2. **Streaming Responses**: Use OpenAI streaming API for faster feedback
3. **Rate Limiting**: Add per-user rate limits
4. **Custom Tools**: Make tool system more extensible/pluggable
5. **Multi-Cluster Jobs**: Better support for multi-cluster environments
6. **Job Templates**: Pre-built job script templates
7. **Batch Operations**: Bulk job management (cancel multiple, etc.)
8. **Notifications**: Proactive notifications for job completions
9. **Analytics**: Track usage patterns and popular queries
10. **Alternative LLMs**: Support for Anthropic Claude, local models, etc.

## Maintenance

### Updating the Assistant

1. **Modify Controller** (`apps/dashboard/app/controllers/assistant_controller.rb`)
   - Add new tools to `build_tools` method
   - Implement tool handler in `execute_tool`
   - Update system prompt if needed

2. **Modify Frontend** (`apps/dashboard/app/views/layouts/_assistant.html.erb`)
   - Update CSS styles
   - Change JavaScript behavior
   - Modify UI elements

3. **Deploy Changes**
   ```bash
   # Copy to container
   docker cp apps/dashboard/app/controllers/assistant_controller.rb \
     ood-dev-container:/var/www/ood/apps/sys/dashboard/app/controllers/
   
   docker cp apps/dashboard/app/views/layouts/_assistant.html.erb \
     ood-dev-container:/var/www/ood/apps/sys/dashboard/app/views/layouts/
   
   # Restart app
   docker exec ood-dev-container touch \
     /var/www/ood/apps/sys/dashboard/tmp/restart.txt
   ```

### Monitoring

```bash
# Check Rails logs
docker exec ood-dev-container tail -f /var/log/ondemand-nginx/username/error.log

# Check for errors
docker exec ood-dev-container grep "Assistant error" \
  /var/log/ondemand-nginx/username/error.log
```

## Documentation

- **`DOCKER_SETUP.md`**: Complete Docker development environment setup
- **`apps/dashboard/AI_ASSISTANT.md`**: Feature documentation and usage guide
- **Controller comments**: Inline documentation of tool methods
- **JavaScript comments**: Widget architecture and behavior

## Credits

- **Architecture**: Tool-based LLM agent with OpenAI function calling
- **UI Design**: Inspired by modern chat interfaces (Discord, Slack)
- **Icon Theme**: Purple gradient (#667eea → #764ba2)
- **Framework**: Rails 7.1.6, Vanilla JavaScript, OpenAI API

## License

This feature is part of Open OnDemand and is released under the MIT License.
