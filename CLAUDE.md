# PlanMyDay - Development Guidelines

## Important Configuration Notes
Please stick strickly to the Rails 8 way of development, and do not go off tangent.

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
- **Importmap**: ALWAYS use importmap for JavaScript - Rails 8 default, NO esbuild/webpack needed
- **CSS**: Use Tailwind CSS with cssbundling-rails (bun for CSS only)
- **No SPA frameworks**: Leverage Hotwire instead of React/Vue
- **No JS bundlers**: Rails 8 uses importmap, not yarn/npm for JS dependencies

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

## Deploy Checklist

1. **Bump version** in `config/initializers/version.rb` (increment by `0.0.1`)
2. **Update service worker version** in `lib/service-worker.js` — set `CACHE_VERSION` to match the new version (e.g. `'v0.2.1'`)
3. **Update Stimulus SW version** in `app/javascript/controllers/service_worker_controller.js` — set `SW_VERSION` to match (e.g. `'v0.2.1'`)
4. **Run tests** — `rails test:all`
5. **Commit** with message like `chore: bump version to 0.2.1`
6. **Deploy** — the new service worker version triggers the "update available" banner for returning PWA users

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

## Hotwire Native Mobile Apps

PlanMyDay includes full support for native iOS and Android apps using Hotwire Native. This allows the Rails web app to be wrapped in a native shell with native navigation and features.

### Architecture

**Web-First Approach:**
- Single Rails codebase serves web, iOS, and Android
- Views are rendered once and reused across all platforms
- Native apps use WKWebView (iOS) / WebView (Android) to display web content
- Cookie-based authentication works seamlessly across platforms
- Turbo Drive and Stimulus work identically in native apps

### Backend Implementation

#### 1. Path Configuration Endpoint
**File:** `app/controllers/hotwire_native_controller.rb`

Serves dynamic path configuration to native apps:
```ruby
GET /path-configuration.json
```

**Patterns:**
- `.*` - Default context with pull-to-refresh
- `/tasks/new$`, `/tasks/.*/edit$` - Modal presentation
- `/signup$`, `/session/new$` - Auth flows as modals
- `/profile$` - Settings as modal
- `/pricing$`, `/subscriptions` - Subscription flows as modals

**Updating:** Modify `app/controllers/hotwire_native_controller.rb` to add new route patterns.

#### 2. Native App Detection
**File:** `app/controllers/application_controller.rb`

```ruby
def native_app?
  request.user_agent&.match?(/Hotwire Native/)
end
```

**Usage in views:**
```erb
<% unless native_app? %>
  <!-- Web-only content -->
<% end %>
```

**Current Usage:**
- Hides cookie consent banner for native apps
- Can be extended for native-specific navigation or features

#### 3. Push Notifications Backend
**Model:** `DeviceToken` (app/models/device_token.rb)

Stores device tokens for push notifications:
- `user_id` - Associated user
- `token` - APNs (iOS) or FCM (Android) device token
- `platform` - 'ios' or 'android'
- `active` - Boolean flag for token status

**API Endpoints:**
```ruby
POST /api/v1/device_tokens
  params: { token: string, platform: string }

DELETE /api/v1/device_tokens/:id
```

**Registration:**
```ruby
DeviceToken.register(user, token, platform)
```

### Mobile-Specific Optimizations

#### Touch Target Sizes
- All interactive elements meet iOS/Android minimum 44x44px touch targets
- Icon buttons use `p-3` padding (44px total)
- Dropdown menu items use `py-3` padding with `text-base` font
- Touch-optimization class: `touch-manipulation` for better responsiveness

#### Drag and Drop
**File:** `app/javascript/controllers/task_controller.js`

- Desktop: Full HTML5 drag-and-drop for task reordering
- Mobile: Drag disabled automatically (touch detection)
- Mobile users can still edit and reorder tasks via other UI controls

#### Responsive Design
- All pages tested at mobile widths: 375px (iPhone SE), 390px (iPhone 14), 430px (iPhone 14 Pro Max)
- Tailwind responsive classes used throughout (`sm:`, `md:`, `lg:`)
- Mobile-first navigation with hamburger menu
- Form inputs optimized for touch keyboards

### iOS App Setup (Future Implementation)

When ready to build the iOS app:

1. **Create Xcode Project**
   - iOS App with Storyboard
   - Minimum: iOS 14+

2. **Add Hotwire Native Package**
   ```
   https://github.com/hotwired/hotwire-native-ios
   ```

3. **Configure Navigator**
   ```swift
   let rootURL = URL(string: "https://planmyday-app.fly.dev")!
   // Or for development: http://localhost:3000
   ```

4. **Load Path Configuration**
   ```swift
   let serverURL = URL(string: "https://planmyday-app.fly.dev/path-configuration.json")!
   Hotwire.loadPathConfiguration(from: [.server(serverURL)])
   ```

5. **Push Notifications**
   - Add Push Notifications capability
   - Request notification permissions
   - Register device token via API: `POST /api/v1/device_tokens`

### Android App Setup (Future Implementation)

When ready to build the Android app:

1. **Add Dependencies**
   ```kotlin
   implementation("dev.hotwire:core:1.1.0")
   implementation("dev.hotwire:navigation-fragments:1.1.0")
   ```

2. **Configure MainActivity**
   ```kotlin
   NavigatorConfiguration(
     name = "main",
     startLocation = "https://planmyday-app.fly.dev",
     // Development: "http://10.0.2.2:3000"
   )
   ```

3. **Push Notifications**
   - Configure FCM (Firebase Cloud Messaging)
   - Register device token via API: `POST /api/v1/device_tokens`

### Authentication in Native Apps

**Current Implementation:**
- Cookie-based session authentication works perfectly
- Native apps automatically persist cookies in WKWebView/WebView
- Login flow: User navigates to `/session/new`, logs in, cookie is set, subsequent requests authenticated

**No changes needed!** The existing Rails session authentication is compatible with Hotwire Native.

### Testing Mobile Features

**Local Testing:**
1. Start Rails server: `bin/dev`
2. Test in mobile browsers (Safari iOS, Chrome Android)
3. Use browser dev tools to simulate mobile devices
4. Test touch interactions, dropdowns, forms

**Native App Testing:**
- iOS: Point Xcode simulator to `http://localhost:3000`
- Android: Point emulator to `http://10.0.2.2:3000`
- Verify path configuration loads correctly
- Test navigation (modal vs default contexts)
- Test authentication flow
- Test push notification registration

### Future Enhancements

**Potential Native Features:**
- [ ] Native voice input for brain dumps (bridge component)
- [ ] Background Pomodoro timer (bridge component)
- [ ] Native share functionality
- [ ] Haptic feedback for task completion
- [ ] Widget support (iOS 14+, Android 12+)
- [ ] Offline support with local storage

**Bridge Components:**
When web capabilities aren't sufficient, create Swift/Kotlin bridge components that communicate with JavaScript via Hotwire's bridge system.

### Resources

- **Hotwire Native Docs:** https://native.hotwired.dev/
- **iOS Package:** https://github.com/hotwired/hotwire-native-ios
- **Android Package:** https://github.com/hotwired/hotwire-native-android
- **Path Configuration:** https://native.hotwired.dev/overview/path-configuration