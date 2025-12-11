/**
 * AI Assistant Chat Widget for Open OnDemand
 * A floating chat bubble that provides LLM-powered assistance
 */

class OODAssistant {
  constructor() {
    this.isOpen = false;
    this.isMinimized = false;
    this.history = [];
    this.isLoading = false;
    this.init();
  }

  init() {
    this.createWidget();
    this.attachEventListeners();
    this.checkStatus();
  }

  createWidget() {
    // Create main container
    const container = document.createElement('div');
    container.id = 'ood-assistant-container';
    container.innerHTML = `
      <div id="ood-assistant-bubble" class="ood-assistant-bubble" title="AI Assistant">
        <svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
          <path d="M21 15a2 2 0 0 1-2 2H7l-4 4V5a2 2 0 0 1 2-2h14a2 2 0 0 1 2 2z"></path>
        </svg>
        <span class="ood-assistant-badge" style="display: none;">!</span>
      </div>
      
      <div id="ood-assistant-chat" class="ood-assistant-chat" style="display: none;">
        <div class="ood-assistant-header">
          <div class="ood-assistant-title">
            <svg xmlns="http://www.w3.org/2000/svg" width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
              <circle cx="12" cy="12" r="3"></circle>
              <path d="M19.4 15a1.65 1.65 0 0 0 .33 1.82l.06.06a2 2 0 0 1 0 2.83 2 2 0 0 1-2.83 0l-.06-.06a1.65 1.65 0 0 0-1.82-.33 1.65 1.65 0 0 0-1 1.51V21a2 2 0 0 1-2 2 2 2 0 0 1-2-2v-.09A1.65 1.65 0 0 0 9 19.4a1.65 1.65 0 0 0-1.82.33l-.06.06a2 2 0 0 1-2.83 0 2 2 0 0 1 0-2.83l.06-.06a1.65 1.65 0 0 0 .33-1.82 1.65 1.65 0 0 0-1.51-1H3a2 2 0 0 1-2-2 2 2 0 0 1 2-2h.09A1.65 1.65 0 0 0 4.6 9a1.65 1.65 0 0 0-.33-1.82l-.06-.06a2 2 0 0 1 0-2.83 2 2 0 0 1 2.83 0l.06.06a1.65 1.65 0 0 0 1.82.33H9a1.65 1.65 0 0 0 1-1.51V3a2 2 0 0 1 2-2 2 2 0 0 1 2 2v.09a1.65 1.65 0 0 0 1 1.51 1.65 1.65 0 0 0 1.82-.33l.06-.06a2 2 0 0 1 2.83 0 2 2 0 0 1 0 2.83l-.06.06a1.65 1.65 0 0 0-.33 1.82V9a1.65 1.65 0 0 0 1.51 1H21a2 2 0 0 1 2 2 2 2 0 0 1-2 2h-.09a1.65 1.65 0 0 0-1.51 1z"></path>
            </svg>
            <span>HPC Assistant</span>
          </div>
          <div class="ood-assistant-controls">
            <button id="ood-assistant-clear" class="ood-assistant-btn" title="Clear chat">
              <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                <polyline points="3 6 5 6 21 6"></polyline>
                <path d="M19 6v14a2 2 0 0 1-2 2H7a2 2 0 0 1-2-2V6m3 0V4a2 2 0 0 1 2-2h4a2 2 0 0 1 2 2v2"></path>
              </svg>
            </button>
            <button id="ood-assistant-minimize" class="ood-assistant-btn" title="Minimize">
              <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                <line x1="5" y1="12" x2="19" y2="12"></line>
              </svg>
            </button>
            <button id="ood-assistant-close" class="ood-assistant-btn" title="Close">
              <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                <line x1="18" y1="6" x2="6" y2="18"></line>
                <line x1="6" y1="6" x2="18" y2="18"></line>
              </svg>
            </button>
          </div>
        </div>
        
        <div id="ood-assistant-messages" class="ood-assistant-messages">
          <div class="ood-assistant-message assistant">
            <div class="ood-assistant-message-content">
              👋 Hi! I'm your HPC assistant. I can help you:
              <ul>
                <li>Check and manage your jobs</li>
                <li>Browse files and directories</li>
                <li>View cluster status</li>
                <li>Launch interactive sessions</li>
              </ul>
              How can I help you today?
            </div>
          </div>
        </div>
        
        <div id="ood-assistant-loading" class="ood-assistant-loading" style="display: none;">
          <div class="ood-assistant-typing">
            <span></span><span></span><span></span>
          </div>
        </div>
        
        <div class="ood-assistant-input-container">
          <textarea 
            id="ood-assistant-input" 
            class="ood-assistant-input" 
            placeholder="Ask me anything about your HPC tasks..."
            rows="1"
          ></textarea>
          <button id="ood-assistant-send" class="ood-assistant-send" title="Send message">
            <svg xmlns="http://www.w3.org/2000/svg" width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
              <line x1="22" y1="2" x2="11" y2="13"></line>
              <polygon points="22 2 15 22 11 13 2 9 22 2"></polygon>
            </svg>
          </button>
        </div>
        
        <div class="ood-assistant-footer">
          <span>Powered by OpenAI</span>
        </div>
      </div>
    `;
    
    document.body.appendChild(container);
    
    // Cache DOM elements
    this.bubble = document.getElementById('ood-assistant-bubble');
    this.chat = document.getElementById('ood-assistant-chat');
    this.messages = document.getElementById('ood-assistant-messages');
    this.input = document.getElementById('ood-assistant-input');
    this.sendBtn = document.getElementById('ood-assistant-send');
    this.loading = document.getElementById('ood-assistant-loading');
    this.closeBtn = document.getElementById('ood-assistant-close');
    this.minimizeBtn = document.getElementById('ood-assistant-minimize');
    this.clearBtn = document.getElementById('ood-assistant-clear');
  }

  attachEventListeners() {
    // Toggle chat on bubble click
    this.bubble.addEventListener('click', () => this.toggleChat());
    
    // Close chat
    this.closeBtn.addEventListener('click', () => this.closeChat());
    
    // Minimize chat
    this.minimizeBtn.addEventListener('click', () => this.minimizeChat());
    
    // Clear chat
    this.clearBtn.addEventListener('click', () => this.clearChat());
    
    // Send message
    this.sendBtn.addEventListener('click', () => this.sendMessage());
    
    // Send on Enter (Shift+Enter for new line)
    this.input.addEventListener('keydown', (e) => {
      if (e.key === 'Enter' && !e.shiftKey) {
        e.preventDefault();
        this.sendMessage();
      }
    });
    
    // Auto-resize textarea
    this.input.addEventListener('input', () => {
      this.input.style.height = 'auto';
      this.input.style.height = Math.min(this.input.scrollHeight, 120) + 'px';
    });
  }

  async checkStatus() {
    // Always show the bubble - don't hide based on status
    console.log('OOD Assistant: Widget loaded');
    try {
      const response = await fetch('/assistant/status');
      const data = await response.json();
      
      if (!data.enabled) {
        console.log('OOD Assistant: API key not configured, but showing bubble anyway');
      }
    } catch (error) {
      console.log('OOD Assistant: Status check failed, but showing bubble anyway', error);
    }
  }

  toggleChat() {
    if (this.isOpen) {
      this.closeChat();
    } else {
      this.openChat();
    }
  }

  openChat() {
    this.isOpen = true;
    this.isMinimized = false;
    this.chat.style.display = 'flex';
    this.bubble.classList.add('active');
    this.input.focus();
    this.scrollToBottom();
  }

  closeChat() {
    this.isOpen = false;
    this.chat.style.display = 'none';
    this.bubble.classList.remove('active');
  }

  minimizeChat() {
    this.isMinimized = true;
    this.chat.style.display = 'none';
    this.bubble.classList.remove('active');
  }

  clearChat() {
    this.history = [];
    this.messages.innerHTML = `
      <div class="ood-assistant-message assistant">
        <div class="ood-assistant-message-content">
          👋 Chat cleared! How can I help you?
        </div>
      </div>
    `;
  }

  async sendMessage() {
    const message = this.input.value.trim();
    if (!message || this.isLoading) return;
    
    // Clear input
    this.input.value = '';
    this.input.style.height = 'auto';
    
    // Add user message to UI
    this.addMessage(message, 'user');
    
    // Add to history
    this.history.push({ role: 'user', content: message });
    
    // Show loading
    this.setLoading(true);
    
    try {
      const response = await fetch('/assistant/chat', {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          'X-CSRF-Token': document.querySelector('meta[name="csrf-token"]')?.content
        },
        body: JSON.stringify({
          message: message,
          history: this.history.slice(-10) // Keep last 10 messages for context
        })
      });
      
      const data = await response.json();
      
      if (data.success) {
        this.addMessage(data.response, 'assistant');
        this.history.push({ role: 'assistant', content: data.response });
      } else {
        this.addMessage(`Error: ${data.error}`, 'error');
      }
    } catch (error) {
      console.error('OOD Assistant: Send failed', error);
      this.addMessage('Sorry, I encountered an error. Please try again.', 'error');
    } finally {
      this.setLoading(false);
    }
  }

  addMessage(content, type) {
    const messageDiv = document.createElement('div');
    messageDiv.className = `ood-assistant-message ${type}`;
    
    const contentDiv = document.createElement('div');
    contentDiv.className = 'ood-assistant-message-content';
    
    // Parse markdown-like formatting
    contentDiv.innerHTML = this.formatMessage(content);
    
    messageDiv.appendChild(contentDiv);
    this.messages.appendChild(messageDiv);
    this.scrollToBottom();
  }

  formatMessage(content) {
    // Basic markdown parsing
    let formatted = content
      // Escape HTML
      .replace(/&/g, '&amp;')
      .replace(/</g, '&lt;')
      .replace(/>/g, '&gt;')
      // Code blocks
      .replace(/```(\w+)?\n([\s\S]*?)```/g, '<pre><code>$2</code></pre>')
      // Inline code
      .replace(/`([^`]+)`/g, '<code>$1</code>')
      // Bold
      .replace(/\*\*([^*]+)\*\*/g, '<strong>$1</strong>')
      // Italic
      .replace(/\*([^*]+)\*/g, '<em>$1</em>')
      // Links
      .replace(/\[([^\]]+)\]\(([^)]+)\)/g, '<a href="$2" target="_blank">$1</a>')
      // Line breaks
      .replace(/\n/g, '<br>');
    
    return formatted;
  }

  setLoading(loading) {
    this.isLoading = loading;
    this.loading.style.display = loading ? 'flex' : 'none';
    this.sendBtn.disabled = loading;
    
    if (loading) {
      this.scrollToBottom();
    }
  }

  scrollToBottom() {
    requestAnimationFrame(() => {
      this.messages.scrollTop = this.messages.scrollHeight;
    });
  }
}

// Initialize when DOM is ready
if (document.readyState === 'loading') {
  document.addEventListener('DOMContentLoaded', () => new OODAssistant());
} else {
  new OODAssistant();
}

export default OODAssistant;
