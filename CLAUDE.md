# PlanMyDay - Development Guidelines

## Important Configuration Notes

### Active Record Encryption
The app uses Active Record encryption for sensitive user data. The encryption keys are configured in `config/environments/development.rb` for development. For production, these should be moved to Rails credentials:

```bash
rails db:encryption:init  # Generate new keys
EDITOR=vim rails credentials:edit  # Add keys to credentials
```

Add the generated keys under:
```yaml
active_record_encryption:
  primary_key: [generated_key]
  deterministic_key: [generated_key]
  key_derivation_salt: [generated_salt]
```

## Project Overview
PlanMyDay is an ADHD-friendly productivity app designed for freelancers. It focuses on minimizing overwhelm through limited daily tasks, brain dump features, and gamification.

## Rails 8 Development Principles

### 1. Use Rails 8 Built-in Features First
Before adding any gem, check if Rails 8 provides a native solution:
- **Authentication**: Use Rails 8's built-in authentication generator instead of Devise
- **Real-time updates**: Use Hotwire (Turbo + Stimulus) instead of React/Vue
- **Background jobs**: Use Solid Queue (built into Rails 8) instead of Sidekiq
- **Caching**: Use Solid Cache instead of Redis for caching
- **WebSockets**: Use Solid Cable instead of Redis for ActionCable

### 2. Frontend Stack
- **Hotwire**: Use Turbo for page updates and Stimulus for JavaScript
- **Importmap**: Prefer importmap over Webpack/esbuild when possible
- **CSS**: Use Tailwind CSS with cssbundling-rails
- **No SPA frameworks**: Leverage Hotwire instead of React/Vue

### 3. Database and Models
- **PostgreSQL**: Primary database
- **Active Record**: Use built-in features like:
  - `has_secure_password` for authentication
  - `has_rich_text` for content fields
  - `has_one_attached` / `has_many_attached` for file uploads
  - Built-in encryption for sensitive data

### 4. Testing
- Use Rails built-in testing framework
- System tests with Capybara for integration testing
- Fixtures over factories

### 5. Performance
- Use `rails dev:cache` for development caching
- Leverage Turbo Frames and Turbo Streams for partial page updates
- Use `data-turbo-permanent` for elements that shouldn't reload

## ADHD-Friendly Design Principles

### Visual Design
- Large, readable fonts (min 16px, prefer 18px+)
- High contrast ratios (WCAG AAA when possible)
- Calming color palette with purposeful use of color
- Plenty of white space
- Clear visual hierarchy

### Interaction Design
- Limit choices (3-5 tasks per day max)
- Progressive disclosure of information
- Quick capture methods (brain dump)
- Visual progress indicators
- Immediate feedback for actions

### Features
- Task rollover for incomplete items
- Pomodoro timer with visual countdown
- Interruption tracking
- Gamification with immediate rewards
- Voice input options where applicable

## Code Style
- Follow Rails conventions
- Use Rails generators when available
- Prefer Rails way over custom solutions
- Keep controllers thin, models smart
- Use concerns for shared behavior
- Descriptive variable and method names

## Development Workflow
1. Check Rails Guides for built-in solutions
2. Use generators for boilerplate
3. Write system tests for features
4. Use Stimulus for interactivity
5. Use Turbo for real-time updates

## Gems to Avoid (Rails 8 has alternatives)
- ❌ Devise → ✅ Rails built-in authentication
- ❌ Sidekiq → ✅ Solid Queue
- ❌ Redis → ✅ Solid Cache/Cable
- ❌ React/Vue → ✅ Hotwire
- ❌ Webpacker → ✅ Importmap/esbuild

## Commands to Remember
```bash
# Generate authentication
rails generate authentication

# Generate Stimulus controller
rails generate stimulus controllername

# Run with caching in development
rails dev:cache

# Run all tests
rails test:all

# Start development server with all services
bin/dev
```

## Implemented Rails 8 Features

### Authentication
- ✅ Built-in authentication instead of Devise
- ✅ Session-based auth with cookies
- ✅ Custom registration controller

### Frontend
- ✅ Hotwire (Turbo + Stimulus) instead of React/Vue
- ✅ Turbo Frames for partial page updates
- ✅ Turbo Streams for real-time updates
- ✅ Stimulus controllers for:
  - Brain dump with voice input
  - Pomodoro timer
  - Task drag-and-drop

### Models
- ✅ `has_rich_text` for brain dump content
- ✅ `encrypts` for sensitive user data
- ✅ `has_one_attached` for avatars
- ✅ `normalizes` for email addresses
- ✅ Broadcast callbacks for real-time updates

### Background Jobs
- ✅ Solid Queue (built-in) instead of Sidekiq
- ✅ Solid Cache instead of Redis
- ✅ Solid Cable for ActionCable

### Database
- ✅ PostgreSQL with proper indexes
- ✅ JSONB fields for flexible data
- ✅ Array fields for tags