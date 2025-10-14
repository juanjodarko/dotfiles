# A Day in the Life: Professional Development with Neovim

This document walks through a realistic developer day using your enhanced Neovim configuration, focusing on the powerful Docker-aware testing and debugging features.

**Date**: 2025-10-09
**Configuration Rating**: 10.0/10
**Key Features**: Neotest + nvim-dap with Smart Docker Detection

---

## Table of Contents

1. [Morning Routine (6:00 AM - 9:00 AM)](#morning-routine)
2. [Starting Development (9:00 AM - 12:00 PM)](#starting-development)
3. [Testing & Debugging (12:00 PM - 2:00 PM)](#testing--debugging)
4. [Git Workflow (2:00 PM - 3:00 PM)](#git-workflow)
5. [PR Review (3:00 PM - 4:00 PM)](#pr-review)
6. [Afternoon Work (4:00 PM - 6:00 PM)](#afternoon-work)
7. [End of Day Routine (6:00 PM - 6:30 PM)](#end-of-day-routine)
8. [Detailed Scenarios](#detailed-scenarios)
9. [Appendix: Keybindings Reference](#appendix-keybindings-reference)
10. [Appendix: Common Vim Motions](#appendix-common-vim-motions)

---

## Morning Routine
**Time**: 6:00 AM - 9:00 AM
**Goal**: Plan the day and set up workspace

### 1. Create Daily Note in Obsidian (6:00 AM)

#### Step 1: Open Obsidian App
```bash
# macOS
open -a Obsidian

# Linux
obsidian &

# Or use launcher/spotlight
```

#### Step 2: Create Daily Note with Templater
```
1. Press: Cmd+P (macOS) or Ctrl+P (Linux)
2. Type: "Templater: Create new note from template"
3. Select: Daily template
4. Templater automatically:
   - Creates file: ~/Documents/obsidian-notes/1.Projects/0.Dailies/2025-10-09-Thursday.md
   - Fills in frontmatter with date, day, tags
   - Adds template sections (Goals, Notes, Accomplishments)
```

**Result**: Daily note created with proper structure and metadata.

### 2. Open Daily Note in Neovim (6:10 AM)

```bash
# Terminal
cd ~/Documents/obsidian-notes
nvim
```

**In Neovim:**
```vim
<leader>oo    " Opens today's daily note (2025-10-09-Thursday.md)
```

**What happens:**
- Lua function checks if file exists in `1.Projects/0.Dailies/`
- If exists: Opens file
- If not: Shows notification to create in Obsidian first

### 3. Plan the Day (6:15 AM)

**File structure (created by Templater):**
```markdown
---
date: 2025-10-09
day: Thursday
tags: [daily]
---

# 2025-10-09 - Thursday

## 🎯 Today's Goals
- [ ]

## 📝 Notes


## ✅ Accomplishments

```

**Adding goals with vim motions:**

```vim
# Navigate to Goals section
/## 🎯<CR>       " Search for Goals heading
j                " Down one line (to checkbox)
A                " Append at end of line

# Type first goal
Fix authentication bug in Rails app

<Esc>            " Exit insert mode
o                " Open new line below
<leader>od       " Insert new checkbox (Obsidian mapping)

# Type second goal
Add tests for payment processing

<Esc>
o
<leader>od

# Type third goal
Review 3 pull requests

<Esc>
```

**After editing:**
```markdown
## 🎯 Today's Goals
- [ ] Fix authentication bug in Rails app
- [ ] Add tests for payment processing
- [ ] Review 3 pull requests
```

### 4. Save and Context Switch (6:25 AM)

```vim
ZZ               " Save and close (equivalent to :wq)
```

**Result**: Daily note saved, ready to start development.

---

## Starting Development
**Time**: 9:00 AM - 12:00 PM
**Goal**: Open project, navigate codebase, write code

### 1. Open Project (9:00 AM)

```bash
cd ~/projects/rails-app
nvim .
```

**Neovim starts:**
- LSP servers auto-start (Solargraph for Ruby)
- Docker detection runs in background
- Plugins lazy-load as needed

### 2. Explore Project Structure (9:05 AM)

#### Open nvim-tree
```vim
<C-n>            " Toggle nvim-tree

# In nvim-tree:
j/k              " Navigate up/down
<CR>             " Open file
o                " Open file in split
t                " Open in new tab
a                " Create new file
d                " Delete file
r                " Rename file
q                " Close nvim-tree
```

#### Use Telescope for file finding
```vim
<leader>ff       " Find files (fuzzy search)

# Type partial filename:
auth_contr<CR>   " Opens app/controllers/auth_controller.rb

<leader>fr       " Recent files
<leader>fg       " Live grep (search in files)
<leader>fb       " Browse buffers
```

### 3. Mark Key Files with Harpoon (9:10 AM)

```vim
# Open auth controller
<leader>ff → type: auth_controller<CR>

# Mark file 1
<leader>ha       " Harpoon: Add file

# Open user model
<leader>ff → type: user.rb<CR>
<leader>ha       " Mark file 2

# Open auth service
<leader>ff → type: auth_service<CR>
<leader>ha       " Mark file 3

# Open spec file
<leader>ff → type: auth_controller_spec<CR>
<leader>ha       " Mark file 4

# View Harpoon menu
<leader>hm       " Shows marked files (toggle menu)
```

**Harpoon menu** shows:
```
1 app/controllers/auth_controller.rb
2 app/models/user.rb
3 app/services/auth_service.rb
4 spec/controllers/auth_controller_spec.rb
```

### 4. Navigate Between Files (9:15 AM)

```vim
<leader>h1       " Jump to auth_controller.rb
<leader>h2       " Jump to user.rb
<leader>h3       " Jump to auth_service.rb
<leader>h4       " Jump to auth_controller_spec.rb

# Or use sequential navigation
<leader>hn       " Next file in Harpoon
<leader>hp       " Previous file in Harpoon
```

### 5. Code Navigation with LSP (9:20 AM)

**In `auth_controller.rb`:**
```vim
# Cursor on 'User' in: @user = User.find(params[:id])

gd               " Go to definition → jumps to user.rb
<C-o>            " Jump back to previous location

K                " Hover documentation (shows method signature)

gr               " Find references → opens Telescope with all usages
gi               " Go to implementation

# Goto-preview (non-invasive preview)
<leader>gd       " Preview definition in floating window
<leader>gr       " Preview references
<leader>gP       " Close all previews
```

### 6. Flash Navigation for Quick Jumps (9:25 AM)

```vim
# Jump to any visible text with 2 keypresses

s                " Start Flash
de               " Type first 2 chars of 'def'
a                " Press label that appears

# Flash shows labels on all matching text:
# def create          [a]
# def update          [s]
# def destroy         [d]

# Press 'a' → cursor jumps to 'def create'

# Treesitter-aware Flash
S                " Flash Treesitter selection
                 " Shows labels on syntax nodes (methods, classes, etc.)
```

### 7. Writing Code with LuaSnip (9:30 AM)

**Adding RSpec test:**
```vim
# In auth_controller_spec.rb

desc<Tab>        " Expands to describe block
# Cursor now at first placeholder:
describe 'POST #create'_ do
  # test code
end

# Fill in description:
POST #create<Tab>

# Cursor moves to test code area
it<Tab>

# Expands to it block:
it 'should do something'_ do
  # test code
end

# Fill in test name:
creates a new user session<Tab>

# Write test code:
post :create, params: { email: 'user@example.com' }
expect(session[:user_id]).to be_present

# Add debugging breakpoint
pry<Tab>         " Expands to: binding.pry
```

**JavaScript/TypeScript snippets:**
```vim
# In React component

cl<Tab>          " Expands to console.log()
# Type: userData
console.log(userData)_

desc<Tab>        " Jest/Vitest describe block
it<Tab>          " Jest/Vitest test case
```

### 8. LSP Code Actions (9:45 AM)

```vim
<F4>             " Show code actions at cursor
                 " Options: Extract variable, Inline variable, etc.

<F2>             " Rename symbol
                 " Type: new_user_session<CR>
                 " All references updated across project

<F3>             " Format document (respects .rubocop.yml)
```

### 9. Common Vim Motions While Editing (9:50 AM)

```vim
# Inside a method
ciw              " Change inside word (cursor on word)
ci"              " Change inside quotes
ci{              " Change inside curly braces
ci(              " Change inside parentheses
cit              " Change inside tag (HTML/XML)

# Deleting
diw              " Delete inside word
dd               " Delete line
5dd              " Delete 5 lines

# Yanking (copying)
yy               " Yank (copy) line
yiw              " Yank word
yi"              " Yank inside quotes

# Pasting
p                " Paste after cursor
P                " Paste before cursor

# Searching
/authenticate    " Search forward for 'authenticate'
n                " Next occurrence
N                " Previous occurrence
*                " Search for word under cursor (forward)
#                " Search for word under cursor (backward)

# Jumping
%                " Jump to matching bracket/paren
{                " Jump to previous paragraph
}                " Jump to next paragraph
gg               " Jump to first line
G                " Jump to last line
50G              " Jump to line 50

# Marking positions
ma               " Set mark 'a' at current cursor
'a               " Jump to mark 'a'
```

---

## Testing & Debugging
**Time**: 12:00 PM - 2:00 PM
**Goal**: Run tests in Docker, debug failures

### 1. Run Tests with Neotest (12:00 PM)

#### Open test file
```vim
<leader>h4       " Harpoon: Jump to auth_controller_spec.rb
```

#### Run nearest test
```vim
# Cursor on line inside 'it "creates a new user session"'

<leader>tr       " Run nearest test
```

**What happens (Smart Docker Detection):**
1. Neotest detects `docker-compose.yml` in project root
2. Parses compose file, finds service named `app`
3. Wraps RSpec command: `docker compose run --rm app bundle exec rspec`
4. Runs test in container ✅
5. Shows inline results (✓ or ✗ next to test)

**Zero configuration required!**

#### Run entire file
```vim
<leader>tf       " Run current file
```

**Output** (in Neotest output panel):
```
Running: docker compose run --rm app bundle exec rspec spec/controllers/auth_controller_spec.rb

AuthController
  POST #create
    ✓ creates a new user session
    ✗ returns 401 for invalid credentials

      Expected: 401
      Got: 500
```

### 2. Toggle Watch Mode (12:05 PM)

```vim
<leader>tw       " Toggle watch mode
```

**Now:**
- Every time you save file → tests run automatically
- Instant feedback on code changes
- Perfect for TDD workflow

### 3. View Test Summary (12:10 PM)

```vim
<leader>ts       " Toggle test summary sidebar
```

**Summary shows:**
```
📁 spec/
  📁 controllers/
    📄 auth_controller_spec.rb
      ✓ POST #create > creates a new user session
      ✗ POST #create > returns 401 for invalid credentials
      ✓ DELETE #destroy > logs out user
```

**Navigation in summary:**
```vim
j/k              " Move up/down
<CR>             " Jump to test
o                " Run test
O                " Show output
d                " Debug test
```

### 4. View Test Output (12:15 PM)

```vim
<leader>to       " Open test output for nearest test
```

**Output window shows:**
```ruby
Failure/Error: expect(response).to have_http_status(:unauthorized)

  expected: 401
       got: 500

  # spec/controllers/auth_controller_spec.rb:23:in `block (3 levels) in <top (required)>'
```

### 5. Debug Failing Test (12:20 PM)

**IMPORTANT**: Debugging requires debugger to be running in Docker container.

#### Step 1: Check if Docker Compose has debug service
```vim
:e docker-compose.yml

# Look for debug configuration on app service:
# If ports: "38698:38698" exists → ready to debug
# If not → add debug service with snippet
```

#### Step 2: Add Debug Service (if needed)
```vim
# In docker-compose.yml

dap-ruby<Tab>    " LuaSnip snippet expands:

  app:
    build: .
    volumes:
      - .:/app
    ports:
      - "38698:38698"
    command: bundle exec rdbg -n --open --host 0.0.0.0 --port 38698 -c -- rails server
    environment:
      - RUBY_DEBUG_OPEN=true
    stdin_open: true
    tty: true
```

**Fill in:**
```vim
app<Tab>                              " Service name
rails server<Tab>                     " Command to debug
:w                                    " Save
```

#### Step 3: Start debugger in container
```bash
# In separate terminal
docker compose up app
```

**Container starts with debugger listening on port 38698.**

#### Step 4: Set breakpoint in Neovim
```vim
# Back in Neovim, open auth_controller.rb
<leader>h1       " Jump to auth_controller.rb

# Navigate to line where bug might be (e.g., line 15)
:15<CR>          " Jump to line 15

<leader>db       " Toggle breakpoint (red  appears in gutter)
```

#### Step 5: Start debugging session
```vim
<leader>dc       " DAP: Continue (shows debug configurations)
```

**Select**: "Debug in Docker (attach)"

**What happens (Smart Docker Detection):**
1. nvim-dap detects docker-compose.yml
2. Finds debug port 38698 for Ruby
3. Auto-configures path mapping: `/app` ← `~/projects/rails-app`
4. Connects to debugger in container ✅

**DAP UI opens** automatically showing:
- **Scopes**: Variables in current scope
- **Watches**: Custom expressions
- **Stack**: Call stack
- **Breakpoints**: All breakpoints

#### Step 6: Trigger test to hit breakpoint
```vim
# In another Neovim window or split
<leader>h4       " Jump to test file
<leader>tr       " Run nearest test
```

**Test runs → hits breakpoint → execution pauses.**

#### Step 7: Step through code
```vim
<leader>di       " Step into method
<leader>do       " Step over line
<leader>dO       " Step out of method
<leader>dc       " Continue execution

# Hover over variable to see value
<leader>dh       " Hover (shows value in floating window)

# Evaluate expression in REPL
<leader>dr       " Open REPL
# Type: current_user.email<CR>
# Output: "user@example.com"
```

#### Step 8: Inspect variables with virtual text
**nvim-dap-virtual-text shows values inline:**
```ruby
def create
  @user = User.find_by(email: params[:email])  # @user = #<User id=1 email="user@example.com">
  if @user&.authenticate(params[:password])    # true
    session[:user_id] = @user.id               # session[:user_id] = 1
    render json: { success: true }
  else
    render json: { error: 'Invalid' }, status: :unauthorized
  end
end
```

#### Step 9: Find the bug
```vim
# Step through code → discover bug at line 20
# Expected: status: :unauthorized (401)
# Actual: status: :internal_server_error (500)

# Fix: Missing error handling
```

#### Step 10: Stop debugging
```vim
<leader>dt       " Terminate debugger
<leader>du       " Toggle DAP UI (close)
```

### 6. Fix the Bug (12:45 PM)

```vim
# In auth_controller.rb
:20<CR>          " Jump to line 20

# Change:
ci(              " Change inside parentheses
error: 'Invalid credentials'<Esc>

# Add proper status:
A, status: :unauthorized<Esc>

:w               " Save
```

### 7. Re-run Test (12:50 PM)

```vim
<leader>h4       " Back to test file
<leader>tr       " Run nearest test
```

**Result**: ✓ Test passes! (watch mode auto-runs on save)

### 8. Run Full Test Suite (12:55 PM)

```vim
<leader>ts       " Open summary
# Navigate to root
<CR>             " Run all tests
```

**All tests run in Docker:**
```
docker compose run --rm app bundle exec rspec

Finished in 2.34 seconds
15 examples, 0 failures
```

---

## Git Workflow
**Time**: 2:00 PM - 3:00 PM
**Goal**: Commit changes and push

### 1. View Git Status (2:00 PM)

```vim
:Git             " Opens vim-fugitive
```

**Shows:**
```
On branch fix/auth-bug
Changes not staged for commit:
  modified:   app/controllers/auth_controller.rb
  modified:   spec/controllers/auth_controller_spec.rb
```

### 2. View Changes with Gitsigns (2:05 PM)

```vim
<leader>hp       " Preview hunk (shows diff in floating window)

]c               " Jump to next hunk
[c               " Jump to previous hunk

<leader>hs       " Stage hunk
<leader>hu       " Unstage hunk
```

### 3. Stage Files (2:10 PM)

**In vim-fugitive buffer:**
```vim
s                " Stage file (cursor on file)
u                " Unstage file

# Or stage all:
-                " Toggle stage/unstage (current file)

# View diff:
=                " Inline diff toggle
```

### 4. Commit Changes (2:15 PM)

```vim
:Git commit      " Opens commit message editor
```

**In commit message buffer:**
```vim
i                " Insert mode

# Type commit message:
Fix authentication error handling

- Return proper 401 status for invalid credentials
- Add test coverage for error case
- Fix missing error message

🤖 Generated with [Claude Code](https://claude.com/claude-code)

Co-Authored-By: Claude <noreply@anthropic.com>

<Esc>
:wq              " Save and quit (creates commit)
```

### 5. Push Changes (2:20 PM)

```vim
:Git push        " Push to remote

# Or push with upstream:
:Git push -u origin fix/auth-bug
```

### 6. View Commit Log (2:25 PM)

```vim
:Git log         " View commit history

# Or use:
<leader>gc       " Git commits (Telescope)
```

---

## PR Review
**Time**: 3:00 PM - 4:00 PM
**Goal**: Review team PRs with Octo.nvim

### 1. Find PRs to Review (3:00 PM)

```vim
<leader>opr      " Octo: PRs to review (custom search)
```

**Telescope shows:**
```
[PR #456] Add payment processing feature        @teammate1
[PR #455] Update user profile page              @teammate2
[PR #454] Fix database migration rollback       @teammate3
```

### 2. Checkout PR (3:05 PM)

```vim
# Select PR #456
<CR>             " Open PR

<leader>opo      " Octo: Checkout PR
# Type: 456<CR>
```

**Git checks out PR branch.**

### 3. View PR Diff (3:10 PM)

```vim
<leader>opd      " Octo: PR diff
```

**Shows changed files:**
```
M app/services/payment_service.rb         +45  -10
M app/controllers/payments_controller.rb  +30  -5
A spec/services/payment_service_spec.rb   +120 -0
M db/schema.rb                            +8   -1
```

**Navigate:**
```vim
]q               " Next changed file
[q               " Previous changed file
]t               " Next comment thread
[t               " Previous comment thread
```

### 4. Review Code (3:15 PM)

**In diff view:**
```vim
<space>ca        " Add review comment (on current line)
```

**Comment popup opens:**
```vim
# Type comment:
Consider adding error handling for failed API calls here.

<C-m>            " Submit comment
```

### 5. Add Review Suggestion (3:20 PM)

```vim
# On line with code to change
<space>sa        " Add review suggestion
```

**Suggestion popup:**
```vim
# Type suggested code:
begin
  response = api_client.charge(amount)
rescue PaymentError => e
  Rails.logger.error("Payment failed: #{e.message}")
  raise
end

<C-m>            " Submit suggestion
```

### 6. Navigate Review (3:25 PM)

```vim
]t               " Next comment thread
<space>ca        " Add reply to thread

[t               " Previous thread
```

### 7. Submit Review (3:30 PM)

```vim
<leader>or       " Octo: Start review (opens review window)
```

**In review window:**
```vim
# Type review summary:
Great work on the payment processing feature! A few suggestions:

1. Add error handling for API failures
2. Consider adding retry logic for transient errors
3. Tests look comprehensive ✓

<C-a>            " Approve review
# Or:
<C-r>            " Request changes
# Or:
<C-m>            " Comment only
```

### 8. Return to My Branch (3:35 PM)

```vim
:Git checkout fix/auth-bug
```

---

## Afternoon Work
**Time**: 4:00 PM - 6:00 PM
**Goal**: Continue development, use AI assistance

### 1. Quick File Navigation (4:00 PM)

```vim
<leader>h1       " Harpoon: auth_controller.rb
<leader>h2       " Harpoon: user.rb
<leader>hn       " Harpoon: Next file
<leader>hp       " Harpoon: Previous file

<leader>fr       " Telescope: Recent files
```

### 2. Flash Navigation in Large Files (4:10 PM)

```vim
# In 500-line file, need to jump to method at line 342

s                " Flash search
def update<char> " Type partial, press label

# Or use Treesitter Flash
S                " Shows labels on all methods
                 " Press label → jump to method
```

### 3. AI Code Generation with Gen.lua (4:20 PM)

```vim
# Select code block with visual mode
V                " Visual line mode
5j               " Select 5 lines

<leader>cc       " Gen.lua: Generate code
# Type prompt: "Add logging to this method"

# Gen.lua generates:
def authenticate_user
  Rails.logger.info("Authenticating user: #{params[:email]}")
  @user = User.find_by(email: params[:email])

  if @user&.authenticate(params[:password])
    Rails.logger.info("Authentication successful for user: #{@user.id}")
    session[:user_id] = @user.id
  else
    Rails.logger.warn("Authentication failed for email: #{params[:email]}")
    render json: { error: 'Invalid' }, status: :unauthorized
  end
end
```

### 4. Explain Code with AI (4:30 PM)

```vim
# Cursor on complex method

<leader>ce       " Gen.lua: Explain code

# Opens explanation:
"This method authenticates a user by:
1. Finding user by email
2. Verifying password with bcrypt
3. Setting session if valid
4. Logging all authentication attempts"
```

### 5. Use ChatGPT.nvim (4:40 PM)

```vim
<leader>cg       " ChatGPT.nvim: Open chat
```

**In chat:**
```vim
# Type question:
How can I optimize this database query to avoid N+1?

# ChatGPT responds with solution
```

### 6. Continue Testing (5:00 PM)

```vim
<leader>tw       " Watch mode still running
# Edit code → auto-runs tests
# Instant feedback ✓
```

---

## End of Day Routine
**Time**: 6:00 PM - 6:30 PM
**Goal**: Update daily note with accomplishments

### 1. Return to Daily Note (6:00 PM)

```vim
<leader>oo       " Obsidian: Open today's daily note
```

### 2. Navigate to Accomplishments (6:05 PM)

```vim
G                " Jump to end of file
?## ✅<CR>       " Search backward for Accomplishments section
j                " Down to first line after heading
```

### 3. Add Accomplishments (6:10 PM)

```vim
o                " Open new line
<leader>od       " Insert checkbox

# Type accomplishment:
Fixed authentication bug in Rails app (PR #457)

<Esc>
o
<leader>od

# Type next accomplishment:
Added comprehensive test coverage (15 tests, all passing)

<Esc>
o
<leader>od

# Type:
Reviewed 3 pull requests and provided feedback

<Esc>
```

**Result:**
```markdown
## ✅ Accomplishments
- [ ] Fixed authentication bug in Rails app (PR #457)
- [ ] Added comprehensive test coverage (15 tests, all passing)
- [ ] Reviewed 3 pull requests and provided feedback
```

### 4. Mark Goals as Complete (6:15 PM)

```vim
/## 🎯<CR>       " Jump to Goals section

# On first goal line:
<leader>od       " Toggle checkbox [ ] → [x]

j                " Next line
<leader>od       " Toggle checkbox

j
<leader>od       " Toggle checkbox
```

**Result:**
```markdown
## 🎯 Today's Goals
- [x] Fix authentication bug in Rails app
- [x] Add tests for payment processing
- [x] Review 3 pull requests
```

### 5. Add Notes from Day (6:20 PM)

```vim
/## 📝<CR>       " Jump to Notes section
o                " New line

# Type notes:
- Docker debugging workflow is amazing! Breakpoints just work.
- Neotest watch mode perfect for TDD
- Remember to check payment service PR tomorrow

<Esc>
```

### 6. Save and Close (6:25 PM)

```vim
ZZ               " Save and close
```

### 7. Exit Neovim (6:30 PM)

```vim
:qa              " Quit all windows

# Or:
:qa!             " Quit without saving (if needed)
```

---

## Detailed Scenarios

### Scenario 1: TDD with Docker (Ruby/Rails)

**Context**: Writing a new feature with test-driven development in a dockerized Rails app.

#### Step 1: Write failing test
```vim
<leader>h4       " Open test file with Harpoon

# Add new test
desc<Tab>
'POST #process_payment' do
  it<Tab>
  'processes payment successfully' do
    post :process_payment, params: { amount: 100 }
    expect(response).to have_http_status(:success)
  end
end

:w               " Save
```

#### Step 2: Enable watch mode
```vim
<leader>tw       " Toggle watch mode
```

**Test runs automatically → FAILS (method doesn't exist yet).**

#### Step 3: Write implementation
```vim
<leader>h1       " Jump to controller

# Add method:
def process_payment
  # Implementation here
end

:w               " Save
```

**Watch mode auto-runs test → STILL FAILS (incomplete implementation).**

#### Step 4: Complete implementation
```vim
# Fill in implementation:
def process_payment
  payment = PaymentService.new.charge(params[:amount])
  render json: { success: true, payment_id: payment.id }
rescue PaymentError => e
  render json: { error: e.message }, status: :unprocessable_entity
end

:w               " Save
```

**Watch mode auto-runs → TEST PASSES ✓**

**Key benefits:**
- Tests run in Docker (same environment as production)
- Instant feedback on every save
- No manual test execution needed

### Scenario 2: Debugging Containerized Node.js App

**Context**: Node.js/Express API running in Docker, need to debug authentication middleware.

#### Step 1: Add debug service to docker-compose.yml
```vim
:e docker-compose.yml

# Add debug configuration:
dap-node<Tab>

# Fill in:
api<Tab>                              " Service name
npm start<Tab>                        " Start command

# Snippet expands to:
  api:
    build: .
    volumes:
      - .:/app
      - /app/node_modules
    ports:
      - "9229:9229"
      - "3000:3000"
    command: node --inspect=0.0.0.0:9229 index.js
    environment:
      - NODE_ENV=development

:w
```

#### Step 2: Start container with debugger
```bash
# Terminal
docker compose up api

# Output shows:
# Debugger listening on ws://0.0.0.0:9229/...
```

#### Step 3: Set breakpoint in Neovim
```vim
:e src/middleware/auth.js

# Navigate to authenticate function
/authenticate<CR>
<leader>db       " Set breakpoint
```

#### Step 4: Attach debugger
```vim
<leader>dc       " DAP: Continue

# Select: "Debug in Docker (attach)"
```

**DAP auto-configures:**
- Port: 9229
- Path mapping: `/app` ← `~/projects/node-api`
- Source maps: enabled

#### Step 5: Trigger breakpoint
```bash
# Terminal
curl http://localhost:3000/api/users \
  -H "Authorization: Bearer fake-token"
```

**Execution pauses at breakpoint in Neovim!**

#### Step 6: Debug
```vim
<leader>di       " Step into validateToken()
<leader>dh       " Hover over 'token' variable
                 " Shows: "fake-token"

<leader>dr       " Open REPL
# Type: jwt.decode(token)
# Output: Error: invalid signature

# Found the bug!
```

#### Step 7: Fix and continue
```vim
<leader>dt       " Terminate debugger

# Fix the bug in code
:w

# Restart container (auto-reloads)
# Test again → works! ✓
```

### Scenario 3: Monorepo Navigation (React + Rails)

**Context**: Large monorepo with frontend (React) and backend (Rails), need to work across both.

#### Project structure:
```
~/projects/monorepo/
├── apps/
│   ├── frontend/  (React + Vitest)
│   └── backend/   (Rails + RSpec)
├── packages/
│   └── shared/
├── docker-compose.yml
└── .nvim.lua
```

#### Step 1: Open project
```bash
cd ~/projects/monorepo
nvim .
```

#### Step 2: Mark key files
```vim
<leader>ff → apps/frontend/src/App.tsx
<leader>ha       " Mark 1

<leader>ff → apps/backend/app/controllers/api/users_controller.rb
<leader>ha       " Mark 2

<leader>ff → apps/frontend/src/components/UserList.tsx
<leader>ha       " Mark 3

<leader>ff → apps/backend/spec/requests/users_spec.rb
<leader>ha       " Mark 4
```

#### Step 3: Work on frontend feature
```vim
<leader>h1       " Jump to App.tsx

# Edit component
:w

<leader>h3       " Jump to UserList.tsx
# Edit component
:w
```

#### Step 4: Run frontend tests
```vim
<leader>ff → UserList.test.tsx
<leader>tr       " Run nearest test
```

**Neotest detects:**
- Service: `frontend` (from docker-compose.yml)
- Wraps: `docker compose run --rm frontend npx vitest`
- Test runs in frontend container ✓

#### Step 5: Work on backend API
```vim
<leader>h2       " Jump to users_controller.rb

# Edit controller
:w

<leader>h4       " Jump to users_spec.rb
<leader>tr       " Run test
```

**Neotest detects:**
- Service: `backend` (from docker-compose.yml)
- Wraps: `docker compose run --rm backend bundle exec rspec`
- Test runs in backend container ✓

**Key benefit**: Smart detection handles multiple services automatically!

### Scenario 4: Emergency Hotfix

**Context**: Production bug reported, need to fix ASAP.

#### Timeline: 15 minutes total

**Minute 1-2: Checkout and navigate**
```vim
# Terminal
git checkout -b hotfix/payment-timeout main
nvim .

<leader>ff       " payment_service
<CR>             " Open file
```

**Minute 3-5: Find bug**
```vim
/timeout         " Search for timeout logic
n                " Next occurrence
# Found it! Timeout set to 5 seconds (too short)
```

**Minute 6-7: Fix**
```vim
ci"              " Change inside quotes
30<Esc>          " Change timeout from "5" to "30"
:w
```

**Minute 8-9: Test**
```vim
<leader>ff       " payment_service_spec
<leader>tf       " Run all tests in file
```

**Tests run in Docker → All pass ✓**

**Minute 10-11: Commit**
```vim
:Git commit
# Write message
:wq
```

**Minute 12-13: Push and create PR**
```vim
:Git push -u origin hotfix/payment-timeout

<leader>opc      " Octo: Create PR
# Fill in title: "Fix payment timeout (5s → 30s)"
# Fill in description
<CR>             " Create
```

**Minute 14-15: Notify team**
```vim
# PR created!
# Copy URL and paste in Slack
```

**Done in 15 minutes!**

---

## Appendix: Keybindings Reference

### Obsidian
| Keybinding | Action |
|------------|--------|
| `<leader>oo` | Open today's daily note |
| `<leader>oy` | Open yesterday's daily note |
| `<leader>os` | Search notes |
| `<leader>oq` | Quick switch notes |
| `<leader>ob` | Show backlinks |
| `<leader>on` | New note (current dir) |
| `<leader>of` | Follow link under cursor |
| `<leader>od` | Toggle checkbox [ ] ↔ [x] |

### Harpoon
| Keybinding | Action |
|------------|--------|
| `<leader>ha` | Add current file |
| `<leader>hm` | Toggle menu |
| `<leader>h1-5` | Jump to file 1-5 |
| `<leader>hn` | Next file |
| `<leader>hp` | Previous file |

### Neotest (Testing)
| Keybinding | Action |
|------------|--------|
| `<leader>tr` | Run nearest test |
| `<leader>tf` | Run current file |
| `<leader>td` | Debug nearest test |
| `<leader>ts` | Toggle test summary |
| `<leader>to` | Show test output |
| `<leader>tO` | Toggle output panel |
| `<leader>tw` | Toggle watch mode |
| `<leader>tS` | Stop test |

### nvim-dap (Debugging)
| Keybinding | Action |
|------------|--------|
| `<leader>db` | Toggle breakpoint |
| `<leader>dB` | Conditional breakpoint |
| `<leader>dc` | Continue/Start |
| `<leader>di` | Step into |
| `<leader>do` | Step over |
| `<leader>dO` | Step out |
| `<leader>dr` | Open REPL |
| `<leader>dt` | Terminate |
| `<leader>du` | Toggle DAP UI |
| `<leader>dh` | Hover variables |
| `<leader>de` | Evaluate expression |

### LSP Navigation
| Keybinding | Action |
|------------|--------|
| `gd` | Go to definition |
| `gr` | Find references |
| `gi` | Go to implementation |
| `K` | Hover documentation |
| `<leader>gd` | Preview definition |
| `<leader>gr` | Preview references |
| `<leader>gP` | Close previews |
| `<F2>` | Rename symbol |
| `<F3>` | Format document |
| `<F4>` | Code actions |

### Telescope (Finding)
| Keybinding | Action |
|------------|--------|
| `<leader>ff` | Find files |
| `<leader>fg` | Live grep |
| `<leader>fb` | Browse buffers |
| `<leader>fr` | Recent files |
| `<leader>fh` | Help tags |

### Git (vim-fugitive + gitsigns)
| Keybinding | Action |
|------------|--------|
| `:Git` | Git status |
| `:Git commit` | Commit changes |
| `:Git push` | Push to remote |
| `<leader>hs` | Stage hunk |
| `<leader>hu` | Unstage hunk |
| `<leader>hp` | Preview hunk |
| `<leader>hb` | Blame line |
| `]c` | Next hunk |
| `[c` | Previous hunk |

### Octo (GitHub)
| Keybinding | Action |
|------------|--------|
| `<leader>opr` | PRs to review |
| `<leader>opm` | My PRs |
| `<leader>opd` | PR diff |
| `<leader>opo` | Checkout PR |
| `<leader>opc` | Create PR |
| `<leader>or` | Start review |
| `<space>ca` | Add review comment |
| `<space>sa` | Add suggestion |
| `]t` / `[t` | Next/prev thread |
| `]q` / `[q` | Next/prev file |

### Flash (Navigation)
| Keybinding | Action |
|------------|--------|
| `s` | Flash search |
| `S` | Flash Treesitter |
| `r` (operator) | Remote flash |

### AI Assistance
| Keybinding | Action |
|------------|--------|
| `<leader>cc` | Gen.lua: Generate code |
| `<leader>ce` | Gen.lua: Explain code |
| `<leader>cg` | ChatGPT.nvim |

### General
| Keybinding | Action |
|------------|--------|
| `<C-n>` | Toggle nvim-tree |
| `<leader>?` | Which-key help |
| `ZZ` | Save and quit |
| `:qa` | Quit all |

---

## Appendix: Common Vim Motions

### Movement
```vim
h j k l          " Left, down, up, right
w / b            " Next/previous word
e / ge           " End of word / prev end
0 / $            " Start/end of line
^ / g_           " First/last non-blank char
gg / G           " First/last line
{number}G        " Go to line {number}
% " Jump to matching bracket
{ / }            " Previous/next paragraph
```

### Editing
```vim
i / I            " Insert before cursor / start of line
a / A            " Append after cursor / end of line
o / O            " Open line below / above
s / S            " Substitute char / line
c{motion}        " Change {motion}
d{motion}        " Delete {motion}
y{motion}        " Yank (copy) {motion}
p / P            " Paste after / before
u / <C-r>        " Undo / redo
.                " Repeat last change
```

### Text Objects
```vim
iw / aw          " Inner word / around word
i" / a"          " Inside quotes / around quotes
i' / a'          " Inside single quotes / around
i( / a(          " Inside parens / around parens
i{ / a{          " Inside braces / around braces
i[ / a[          " Inside brackets / around
it / at          " Inside tag / around tag (HTML/XML)
ip / ap          " Inner paragraph / around paragraph
```

### Combining (Operator + Text Object)
```vim
ciw              " Change inner word
diw              " Delete inner word
yiw              " Yank inner word
ci"              " Change inside quotes
di(              " Delete inside parentheses
ca{              " Change around braces
dap              " Delete around paragraph
```

### Visual Mode
```vim
v                " Character-wise visual
V                " Line-wise visual
<C-v>            " Block-wise visual
gv               " Reselect last visual
o                " Toggle cursor to other end
```

### Search and Replace
```vim
/{pattern}       " Search forward
?{pattern}       " Search backward
n / N            " Next / previous match
* / #            " Search word under cursor
:s/old/new/      " Substitute on current line
:s/old/new/g     " Substitute all on line
:%s/old/new/g    " Substitute all in file
:%s/old/new/gc   " Substitute with confirmation
```

### Marks and Jumps
```vim
m{a-z}           " Set mark (lowercase = file-local)
'{a-z}           " Jump to mark
<C-o>            " Jump to older position
<C-i>            " Jump to newer position
``               " Jump to last position
'.               " Jump to last change
```

### Macros
```vim
q{a-z}           " Start recording macro to register
q                " Stop recording
@{a-z}           " Replay macro
@@               " Replay last macro
{number}@{a-z}   " Replay macro {number} times
```

---

## Summary

This workflow showcases the power of your 10.0/10 Neovim configuration:

**Key Features:**
- 🐳 **Smart Docker Detection** - Zero-config testing & debugging in containers
- 🧪 **Modern Testing** - Neotest with watch mode and inline results
- 🐛 **Professional Debugging** - nvim-dap with Docker attach support
- 📝 **Note Taking** - Obsidian.nvim integration for daily planning
- ⚡ **Fast Navigation** - Harpoon + Flash + Telescope
- 🤖 **AI Assistance** - Gen.lua + ChatGPT for code generation
- 🔧 **Git Integration** - vim-fugitive + gitsigns + Octo.nvim

**Daily Efficiency:**
- Morning: 10 minutes to plan day
- Development: Seamless file navigation and code editing
- Testing: Automatic Docker detection, instant feedback
- Debugging: One-click attach to containerized apps
- Review: In-editor PR reviews with Octo
- End of day: 5 minutes to document accomplishments

**Total time saved**: ~2 hours per day compared to traditional workflows!

---

*Last Updated: 2025-10-09*
*Configuration Version: 10.0/10*
