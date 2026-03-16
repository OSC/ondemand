# Open OnDemand AI Assistant

The AI Assistant is a floating chat widget that provides LLM-powered assistance for managing HPC tasks directly from the Open OnDemand web interface.

## Features

- **Floating Chat Bubble** - Always accessible from the bottom-right corner of any page
- **Natural Language Interface** - Ask questions in plain English
- **Tool-Based Agent** - Executes real actions on your behalf (with confirmation for destructive operations)
- **Context-Aware** - Knows your username, home directory, and available clusters

## Capabilities

### Job Management
- List all your jobs across clusters
- Filter jobs by state (running, pending, completed)
- Get detailed information about specific jobs
- Delete/cancel jobs (with confirmation)

### File Operations
- Browse directories
- List files with metadata (size, permissions, modified date)
- Read text file contents
- Get file/directory information

### Cluster Information
- View available clusters
- Check cluster status
- See job queue statistics

### Interactive Sessions
- List active sessions (Jupyter, Desktop, RStudio, etc.)
- View session status and time remaining
- Discover available interactive applications

## Installation

### Prerequisites

- Open OnDemand 3.0+
- OpenAI API key

### Setup

1. **Add the environment variable** to your OnDemand configuration:

   ```bash
   # /etc/ood/config/apps/dashboard/env
   OPENAI_API_KEY=sk-your-api-key-here
   ```

   Or for development:
   ```bash
   # apps/dashboard/.env.local
   OPENAI_API_KEY=sk-your-api-key-here
   ```

2. **Restart the web server** to apply changes:
   ```bash
   sudo systemctl restart httpd
   ```

3. **Verify** by visiting the dashboard - you should see a purple chat bubble in the bottom-right corner.

## Configuration

| Environment Variable | Default | Description |
|---------------------|---------|-------------|
| `OPENAI_API_KEY` | *(required)* | Your OpenAI API key |
| `OPENAI_MODEL` | `gpt-4o-mini` | OpenAI model to use (e.g., `gpt-4o`, `gpt-4-turbo`) |

## Usage Examples

### Checking Jobs

```
User: Show me my running jobs
Assistant: You have 3 running jobs:

| Job ID | Name | Cluster | Queue | Nodes |
|--------|------|---------|-------|-------|
| 12345 | simulation_v2 | pitzer | batch | 4 |
| 12346 | data_process | owens | serial | 1 |
| 12347 | ml_training | pitzer | gpu | 2 |
```

### File Operations

```
User: What's in my scratch directory?
Assistant: Here are the contents of /fs/scratch/user123:

- 📁 project_a/
- 📁 project_b/
- 📄 results.csv (2.3 MB)
- 📄 config.yaml (1.2 KB)

Would you like me to look inside any of these directories?
```

### Job Management

```
User: Delete job 12345 on pitzer
Assistant: Are you sure you want to delete job 12345 (simulation_v2) on pitzer? 
This job is currently running and has been executing for 2 hours.

User: Yes, delete it
Assistant: ✅ Job 12345 has been successfully deleted.
```

### Cluster Status

```
User: What's the status of the pitzer cluster?
Assistant: **Pitzer Cluster Status:**
- Total jobs: 1,247
- Running: 892
- Queued: 355
- Login host: pitzer.osc.edu
```

## Architecture

### Components

```
┌─────────────────────────────────────────────────────────┐
│                    Browser (Frontend)                    │
├─────────────────────────────────────────────────────────┤
│  assistant.js          │  assistant.css                 │
│  - Chat widget UI      │  - Floating bubble styles      │
│  - Message handling    │  - Chat window styles          │
│  - API communication   │  - Responsive design           │
└────────────────────────┴────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────┐
│                 Rails Backend (Controller)               │
├─────────────────────────────────────────────────────────┤
│  assistant_controller.rb                                 │
│  - POST /assistant/chat   - Process messages            │
│  - GET /assistant/status  - Check if enabled            │
│  - Tool execution         - Run HPC operations          │
└─────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────┐
│                    External Services                     │
├──────────────────────┬──────────────────────────────────┤
│   OpenAI API         │   OOD Core Libraries             │
│   - Chat completions │   - Job adapters                 │
│   - Tool calls       │   - File operations              │
│                      │   - Cluster configs              │
└──────────────────────┴──────────────────────────────────┘
```

### Tool Definitions

The assistant uses OpenAI's function calling feature. Available tools:

| Tool | Description | Parameters |
|------|-------------|------------|
| `list_jobs` | List user's jobs | `cluster?`, `state?` |
| `get_job_details` | Get job info | `job_id`, `cluster` |
| `delete_job` | Delete a job | `job_id`, `cluster` |
| `list_files` | List directory contents | `path?` |
| `get_file_info` | Get file metadata | `path` |
| `read_file` | Read file contents | `path` |
| `get_cluster_status` | Get cluster info | `cluster?` |
| `list_interactive_sessions` | List active sessions | - |
| `get_available_apps` | List launchable apps | - |

## Security Considerations

1. **Authentication** - The assistant runs in the user's authenticated session
2. **Authorization** - All operations use the user's permissions
3. **No Elevated Access** - Cannot perform actions the user couldn't do manually
4. **Confirmation Required** - Destructive operations (delete) should be confirmed
5. **Rate Limiting** - Consider implementing rate limits for API calls
6. **Data Privacy** - Conversation data is not persisted server-side

## Customization

### Changing the Appearance

Edit `apps/dashboard/app/assets/stylesheets/assistant.css`:

```css
/* Change bubble color */
.ood-assistant-bubble {
  background: linear-gradient(135deg, #your-color-1 0%, #your-color-2 100%);
}
```

### Adding Custom Tools

Edit `apps/dashboard/app/controllers/assistant_controller.rb`:

1. Add tool definition to `build_tools`:
```ruby
{
  type: 'function',
  function: {
    name: 'my_custom_tool',
    description: 'Description of what it does',
    parameters: {
      type: 'object',
      properties: {
        param1: { type: 'string', description: 'Parameter description' }
      },
      required: ['param1']
    }
  }
}
```

2. Add handler in `execute_tool`:
```ruby
when 'my_custom_tool'
  tool_my_custom_tool(arguments)
```

3. Implement the tool method:
```ruby
def tool_my_custom_tool(args)
  # Your implementation
  { result: 'success', data: '...' }
end
```

### Modifying the System Prompt

Edit the `system_prompt` method in the controller to change the assistant's personality or add context:

```ruby
def system_prompt
  <<~PROMPT
    You are a helpful HPC assistant for #{site_name}.
    
    Additional context about your site...
    
    Current user: #{CurrentUser.name}
  PROMPT
end
```

## Troubleshooting

### Assistant bubble doesn't appear

1. Check if `OPENAI_API_KEY` is set:
   ```bash
   grep OPENAI_API_KEY /etc/ood/config/apps/dashboard/env
   ```

2. Check browser console for JavaScript errors

3. Verify the status endpoint:
   ```bash
   curl http://localhost/assistant/status
   ```

### "Assistant not configured" error

The OpenAI API key is missing or invalid. Verify:
```bash
curl -H "Authorization: Bearer $OPENAI_API_KEY" \
  https://api.openai.com/v1/models
```

### Tool calls fail

Check Rails logs for errors:
```bash
tail -f /var/log/ondemand-nginx/*/error.log
```

Common issues:
- Cluster not configured properly
- User doesn't have permission for the operation
- Path doesn't exist or isn't accessible

### Slow responses

- Consider using a faster model (`gpt-4o-mini` vs `gpt-4o`)
- Check network connectivity to OpenAI
- Tool operations (especially listing many jobs) can be slow

## Development

### Running Tests

```bash
cd apps/dashboard
bundle exec rails test test/controllers/assistant_controller_test.rb
```

### Local Development

1. Create `.env.local` with your API key:
   ```
   OPENAI_API_KEY=sk-...
   ```

2. Start the development server:
   ```bash
   bin/rails server
   ```

3. Open http://localhost:3000

### Building Assets

After modifying JavaScript or CSS:
```bash
bin/recompile_js
```

## API Reference

### POST /assistant/chat

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

### GET /assistant/status

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

## License

This feature is part of Open OnDemand and is released under the MIT License.
