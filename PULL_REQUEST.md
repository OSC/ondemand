## Summary

This PR adds a comprehensive AI-powered assistant to the Open OnDemand dashboard that helps users manage HPC tasks through natural language conversations. The assistant appears as a floating chat bubble in the bottom-right corner of all dashboard pages.

## Motivation

New HPC users often face a steep learning curve when learning to manage jobs, navigate file systems, and understand cluster resources. This AI assistant provides:
- Natural language interface that reduces friction for new users
- Instant help without context-switching to documentation  
- Faster workflows for power users performing common tasks
- Improved overall user experience and accessibility

## Features

### Core Capabilities

- **Job Management**: List, view details, and delete jobs across clusters
- **File Operations**: Browse directories, read files, create files, and submit batch jobs
- **Cluster Information**: View cluster status and job queue statistics
- **Interactive Sessions**: Monitor active sessions (Jupyter, Desktop, etc.)
- **Batch Job Submission**: Create and submit job scripts through natural language

### User Interface

- Floating purple chat bubble (always accessible)
- Clean, modern chat interface (380px × 520px)
- Conversation history with context awareness
- Markdown formatting support (code blocks, bold, italic, links)
- Responsive design (mobile-friendly)
- Dark mode support
- Loading indicators and error handling

### Technical Implementation

- **Backend**: Rails controller with OpenAI function calling (12 tools)
- **Frontend**: Vanilla JavaScript widget (no dependencies)
- **Integration**: Inline partial to bypass asset pipeline complexity
- **Security**: CSRF protection, user permission checks, path validation

## Architecture

```
┌─────────────────────────────────────────┐
│           Frontend (Browser)             │
│  • Floating chat bubble                  │
│  • Inline HTML/CSS/JavaScript            │
│  • CSRF token handling                   │
└─────────────────┬───────────────────────┘
                  │ POST /pun/sys/dashboard/assistant/chat
                  ▼
┌─────────────────────────────────────────┐
│      AssistantController (Rails)         │
│  • OpenAI API integration                │
│  • 12 tools (9 read + 3 write)          │
│  • Conversation history management       │
└─────────────────┬───────────────────────┘
                  │
        ┌─────────┴─────────┐
        ▼                   ▼
┌──────────────┐   ┌──────────────────┐
│  OpenAI API  │   │  OOD Core Libs   │
│  • GPT-4o    │   │  • Job adapters  │
│  • Tools     │   │  • File ops      │
└──────────────┘   └──────────────────┘
```

## Configuration

### Requirements

- OpenAI API key (required)
- Rails 7.1.6+ (already in OOD)
- No additional gems or JavaScript dependencies

### Setup

```bash
# Set API key in environment
echo "OPENAI_API_KEY=your-api-key-here" >> /etc/ood/config/apps/dashboard/env

# Restart web server
sudo systemctl restart httpd
```

### Optional Configuration

```bash
# Change OpenAI model (default: gpt-4o-mini)
OPENAI_MODEL=gpt-4o
```

## Tools Available

The assistant has access to 12 tools for HPC operations:

**Read Operations:**
1. `list_jobs` - List all jobs across clusters
2. `get_job_details` - Get detailed job information
3. `delete_job` - Delete/cancel jobs (with user confirmation)
4. `list_files` - Browse directories
5. `read_file` - Read text file contents (first 100 lines)
6. `get_file_info` - Get file metadata
7. `get_cluster_status` - View cluster information
8. `list_interactive_sessions` - List active sessions
9. `get_available_apps` - List launchable apps

**Write Operations:**
10. `create_file` - Create files with content
11. `submit_batch_job` - Submit existing job scripts
12. `create_and_submit_job` - Create script + submit in one step

## Usage Examples

### Example 1: Check Running Jobs
```
User: Show me my running jobs
Assistant: You have 3 running jobs:

| Job ID | Name | Cluster | Queue | Nodes |
|--------|------|---------|-------|-------|
| 12345 | simulation | pitzer | batch | 4 |
```

### Example 2: Create and Submit Job
```
User: Create a simple hello world job script and submit it
Assistant: I'll create a job script for you and submit it.

Job script created at /home/user/hello_job.sh and 
submitted as job 12348 to pitzer cluster.
```

### Example 3: Browse Files
```
User: What's in my home directory?
Assistant: Here are the contents of /home/user:

projects/ (directory)
data/ (directory)
config.yaml (1.2 KB)
```

## Files Changed

### New Files

- `apps/dashboard/app/controllers/assistant_controller.rb` (465 lines) - Backend LLM agent with OpenAI integration
- `apps/dashboard/app/views/layouts/_assistant.html.erb` (320 lines) - Inline widget with HTML/CSS/JS
- `apps/dashboard/app/javascript/assistant.js` (295 lines) - Modular JavaScript widget (for asset pipeline builds)
- `apps/dashboard/app/assets/stylesheets/assistant.css` (360 lines) - Widget styles with dark mode support
- `DOCKER_SETUP.md` (265 lines) - Docker development environment guide
- `apps/dashboard/AI_ASSISTANT.md` (370 lines) - Complete feature documentation
- `COMMIT_SUMMARY.md` (437 lines) - Detailed implementation notes

### Modified Files

- `apps/dashboard/config/routes.rb` - Added assistant routes (`POST /assistant/chat`, `GET /assistant/status`)
- `apps/dashboard/app/assets/stylesheets/application.scss` - Import assistant styles
- `apps/dashboard/app/javascript/application.js` - Import assistant module
- `.gitignore` - Exclude cookies and session files

## Security Considerations

1. **Authentication**: Runs in user's authenticated session (no separate auth)
2. **Authorization**: Uses user's existing permissions (no privilege escalation)
3. **Path Validation**: File operations restricted to user's home directory
4. **CSRF Protection**: Rails CSRF token validation on all requests
5. **No Persistence**: Conversation history is client-side only (privacy)
6. **Input Validation**: All tool arguments validated before execution
7. **Read-Only by Default**: Most tools are read-only; write operations clearly separated

## Testing

All testing was performed manually in a Docker development environment.

### Test Coverage
- ✅ Purple bubble appears on all dashboard pages
- ✅ Chat window opens/closes correctly
- ✅ Messages display in correct order with proper formatting
- ✅ All 12 tools execute successfully
- ✅ Error handling displays user-friendly messages
- ✅ Responsive design works on mobile viewports
- ✅ CSRF token validation prevents unauthorized requests
- ✅ Markdown formatting (code blocks, lists, links) renders correctly
- ✅ Graceful degradation when API key not configured

### Test Scenarios Verified
1. **Job Management**: List jobs, view details, delete jobs across multiple clusters
2. **File Operations**: Browse directories, read files, create new files
3. **Batch Jobs**: Create and submit job scripts via natural language
4. **Error Handling**: Invalid paths, missing permissions, API failures
5. **Security**: Path traversal attempts blocked, user permissions enforced
6. **UI/UX**: Loading states, conversation history, markdown rendering

### Manual Test Commands

```bash
# 1. Test status endpoint
curl http://localhost/pun/sys/dashboard/assistant/status

# 2. Test chat endpoint
curl -u username:password http://localhost/pun/sys/dashboard/assistant/chat \
  -H "Content-Type: application/json" \
  -d '{"message": "What jobs are running?"}'

# 3. Browser testing
# - Login to dashboard
# - Click purple bubble in bottom-right corner
# - Send messages: "Show me my jobs", "List files in my home directory"
# - Verify responses are accurate and well-formatted
```

## Documentation

- **apps/dashboard/AI_ASSISTANT.md**: Complete feature documentation with usage examples, customization guide, troubleshooting, and API reference
- **DOCKER_SETUP.md**: Docker development environment setup including AI assistant configuration
- **COMMIT_SUMMARY.md**: Detailed implementation notes and architectural decisions

## Known Limitations

1. **No Conversation Persistence**: History is client-side only (refreshing page loses context)
2. **Rate Limiting**: No built-in rate limiting (consider adding for production use)
3. **Cost**: OpenAI API calls have usage costs (recommend monitoring)
4. **File Size**: File reading limited to 100KB (prevents memory issues)
5. **No Streaming**: Responses sent in full (not streamed token-by-token)

## Future Enhancements

Potential improvements for future PRs:
- Conversation persistence in database/session
- Streaming responses for faster perceived performance
- Per-user rate limiting
- Pluggable tool system for custom site-specific tools
- Support for alternative LLM providers (Anthropic, local models)
- Pre-built job template library
- Batch operations (e.g., cancel multiple jobs at once)
- Proactive notifications for job status changes

## Breaking Changes

**None.** This is a new optional feature that:
- Does not modify existing functionality
- Requires explicit opt-in via API key configuration
- Has no runtime dependencies beyond OpenAI (when enabled)
- Can be completely disabled by not setting the API key
- Gracefully degrades when disabled (no errors shown to users)

## Deployment Notes

1. **No Database Migrations**: Feature uses existing OOD infrastructure
2. **No Gem Changes**: Uses only standard Ruby/Rails libraries (`net/http`, `json`)
3. **Asset Pipeline**: Uses inline partial approach to avoid precompilation complexity
4. **Backwards Compatible**: Works with existing OOD installations
5. **Zero Downtime**: Can be deployed without service interruption (restart recommended to load new code)
6. **No External Services Required**: OpenAI API only used when assistant is invoked

## Code Style Compliance

This PR follows the [OOD Contributing Guidelines](https://github.com/OSC/ondemand/blob/master/CONTRIBUTING.md):

### Ruby Style
- ✅ Snake_case for methods and variables
- ✅ 2-space indentation, no tabs
- ✅ Attributes defined with `attr_reader` (read-only objects)
- ✅ Comments explaining intent at class/method level
- ✅ Meaningful variable names (no single letters except block iterators)
- ✅ Methods use `?` suffix for boolean returns
- ✅ Implicit `begin` blocks in rescue statements
- ✅ Files end with newline

### JavaScript Style
- ✅ File names use underscores (`assistant.js`)
- ✅ `camelCase` for variables and functions
- ✅ `const` and `let` (no `var`)
- ✅ ES6 class syntax for modularity

### CSS Style
- ✅ Class names use hyphens (`ood-assistant-bubble`)
- ✅ Relative sizes (`em`, `rem`) over pixels where appropriate
- ✅ Responsive breakpoints for mobile

### HTML Style
- ✅ IDs use underscores (`ood-assistant-input`)
- ✅ Semantic HTML5 elements

## Checklist

- [x] Code follows OOD style guidelines
- [x] Self-reviewed the code
- [x] Comments explain intent (not just mechanics)
- [x] Added comprehensive documentation
- [x] No personal information in commits
- [x] Tested manually in Docker environment
- [x] No breaking changes
- [x] Security considerations addressed
- [x] Error handling implemented throughout
- [x] Logging added for debugging (Rails logger)
- [x] All new methods have descriptive comments
- [x] Read-only object pattern followed (`attr_reader` only)

## Additional Notes

### Why Inline Partial Instead of Asset Pipeline?

This implementation uses an inline partial (`_assistant.html.erb`) rather than fully compiled assets because:

1. **Production Complexity**: Precompiled assets with fingerprints make live updates difficult in production
2. **Container Deployment**: Easier to update without full asset recompilation
3. **Self-Contained**: Single file contains all HTML/CSS/JS for easier maintenance
4. **Faster Development**: Simpler to modify and test without build steps

The trade-off is a slightly larger HTML payload (~10KB), but the benefit is significantly easier deployment and maintenance. The separate `.js` and `.css` files are included for sites that prefer to use the asset pipeline.

### OpenAI API Costs

Based on GPT-4o-mini pricing (as of Dec 2024):
- Input: $0.150 per 1M tokens
- Output: $0.600 per 1M tokens

Typical query cost: ~$0.001-0.005 per conversation turn
Monthly cost estimate: $10-50 for moderate usage (100-500 queries/day)

Recommend monitoring usage via OpenAI dashboard and setting usage limits.
