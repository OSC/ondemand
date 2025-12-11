## Summary

This PR adds a comprehensive AI-powered assistant to the Open OnDemand dashboard that helps users manage HPC tasks through natural language conversations. The assistant appears as a floating chat bubble in the bottom-right corner of all dashboard pages.

## Motivation

New HPC users often face a steep learning curve when learning to manage jobs, navigate file systems, and understand cluster resources. This AI assistant provides a natural language interface that:
- Reduces friction for new users getting started with HPC
- Provides instant help without context-switching to documentation
- Enables power users to perform common tasks more quickly
- Improves overall user experience and accessibility

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
3. `delete_job` - Delete/cancel jobs (with confirmation)
4. `list_files` - Browse directories
5. `read_file` - Read text file contents
6. `get_file_info` - Get file metadata
7. `get_cluster_status` - View cluster information
8. `list_interactive_sessions` - List active sessions
9. `get_available_apps` - List launchable apps

**Write Operations:**
10. `create_file` - Create files with content
11. `submit_batch_job` - Submit existing job scripts
12. `create_and_submit_job` - Create script + submit

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

✅ Job script created at /home/user/hello_job.sh and 
submitted as job 12348 to pitzer cluster.
```

### Example 3: Browse Files
```
User: What's in my home directory?
Assistant: Here are the contents of /home/user:

📁 projects/
📁 data/
📄 config.yaml (1.2 KB)
```

## Files Changed

### New Files

- `apps/dashboard/app/controllers/assistant_controller.rb` - Backend LLM agent
- `apps/dashboard/app/views/layouts/_assistant.html.erb` - Inline widget implementation
- `apps/dashboard/app/javascript/assistant.js` - JavaScript widget module
- `apps/dashboard/app/assets/stylesheets/assistant.css` - Widget styles
- `DOCKER_SETUP.md` - Docker development guide
- `apps/dashboard/AI_ASSISTANT.md` - Feature documentation
- `COMMIT_SUMMARY.md` - Implementation details

### Modified Files

- `apps/dashboard/config/routes.rb` - Added assistant routes
- `apps/dashboard/app/assets/stylesheets/application.scss` - Import assistant styles
- `apps/dashboard/app/javascript/application.js` - Import assistant module
- `.gitignore` - Exclude cookies and session files

## Security Considerations

1. **Authentication**: Runs in user's authenticated session
2. **Authorization**: Uses user's existing permissions (no privilege escalation)
3. **Path Validation**: File operations restricted to user's home directory
4. **CSRF Protection**: Rails CSRF token validation
5. **No Persistence**: Conversation history client-side only (privacy)
6. **Input Validation**: All tool arguments validated before execution

## Testing

### Manual Testing

```bash
# 1. Test status endpoint
curl http://localhost/pun/sys/dashboard/assistant/status

# 2. Test chat endpoint
curl -u username:password http://localhost/pun/sys/dashboard/assistant/chat \
  -H "Content-Type: application/json" \
  -d '{"message": "What jobs are running?"}'

# 3. Browser testing
# - Open dashboard
# - Click purple bubble
# - Send messages and verify responses
```

### Verification Checklist

- [x] Purple bubble appears on all dashboard pages
- [x] Chat window opens/closes correctly
- [x] Messages display in correct order
- [x] All 12 tools functional
- [x] Error handling works properly
- [x] Responsive on mobile
- [x] CSRF token validation
- [x] Markdown formatting displays correctly
- [x] No personal information in code

## Documentation

- **AI_ASSISTANT.md**: Complete feature documentation with usage examples, customization guide, and API reference
- **DOCKER_SETUP.md**: Docker development environment setup including AI assistant configuration
- **COMMIT_SUMMARY.md**: Detailed implementation notes and architectural decisions

## Known Limitations

1. **No Conversation Persistence**: History is client-side only (refreshing loses context)
2. **Rate Limiting**: No built-in rate limiting (consider adding for production)
3. **Cost**: OpenAI API calls have usage costs
4. **File Size**: File reading limited to 100KB
5. **No Streaming**: Full responses only (not streamed)

## Future Enhancements

- Conversation persistence in database
- Streaming responses for faster feedback
- Per-user rate limiting
- Custom tool system for extensibility
- Support for alternative LLM providers
- Job template library
- Batch operations (cancel multiple jobs)
- Proactive notifications

## Breaking Changes

None. This is a new feature that:
- Does not modify existing functionality
- Requires explicit opt-in via API key configuration
- Has no dependencies on external services beyond OpenAI
- Can be disabled by not setting the API key

## Deployment Notes

1. **No Database Migrations**: Feature uses existing OOD infrastructure
2. **No Gem Changes**: Uses only standard Rails and Ruby libraries
3. **Asset Pipeline**: Uses inline partial to avoid precompilation issues
4. **Backwards Compatible**: Gracefully degrades if API key not set
5. **Zero Downtime**: Can be deployed without restart (though restart recommended)

## Screenshots

*(Note: Screenshots would be added here in the actual PR)*

- Chat bubble in bottom-right corner
- Chat window with conversation
- Example job listing response
- Example file browsing response

## Related Issues

This PR addresses user requests for:
- Simplified job management interface
- Natural language HPC task automation
- Improved user onboarding experience
- Reduced learning curve for new HPC users

## Checklist

- [x] Code follows OOD style guidelines
- [x] Self-reviewed the code
- [x] Added comprehensive documentation
- [x] No personal information in commits
- [x] Tested manually in Docker environment
- [x] No breaking changes
- [x] Security considerations addressed
- [x] Error handling implemented
- [x] Logging added for debugging

## Additional Notes

This implementation uses an inline partial approach (`_assistant.html.erb`) rather than the asset pipeline because:

1. **Production Asset Pipeline Complexity**: Precompiled assets with fingerprints make live updates difficult
2. **Container Deployment**: Easier to update without full asset recompilation
3. **Self-Contained**: Single file contains all HTML/CSS/JS for the widget
4. **Maintainability**: Simpler to modify and test

The trade-off is a slightly larger HTML payload, but the benefit is significantly easier deployment and maintenance.
