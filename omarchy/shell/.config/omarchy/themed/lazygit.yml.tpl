# Lazygit, themed by Omarchy.
#
# This is a TEMPLATE, not a config: omarchy-theme-set-templates renders it to
#   ~/.local/state/omarchy/current/theme/lazygit.yml
# on every theme change, and ~/.config/lazygit/config.yml symlinks to that output.
#
# Lazygit has no include mechanism, so the whole config lives here and only the
# gui.theme colors are substituted. Edit this file, not ~/.config/lazygit/config.yml
# (which is a generated symlink).
#
# Omarchy ships an empty lazygit config, so nothing upstream competes with this.

# Lazygit configuration with rebase-first defaults
# Updated for Neovim integration and monorepo awareness

gui:
  # Show file tree instead of flat list (better for monorepos)
  showFileTree: true
  # Scroll off margin
  scrollHeight: 2
  scrollPastBottom: true
  # Mouse support
  mouseEvents: true
  # Show branch heads in log
  showBranchCommitHash: true
  # Show command log
  showCommandLog: true
  # Split diff mode (better for side-by-side viewing)
  splitDiff: 'auto'
  # Skip discard warning
  skipDiscardChangeWarning: false
  # Show icons
  nerdFontsVersion: "3"
  # Border style
  border: 'rounded'
  # Theme (Catppuccin Mocha colors)
  theme:
    activeBorderColor:
      - '{{ accent }}'
      - bold
    inactiveBorderColor:
      - '{{ muted }}'
    searchingActiveBorderColor:
      - '{{ yellow }}'
      - bold
    optionsTextColor:
      - '{{ accent }}'
    selectedLineBgColor:
      - '{{ selection }}'
    selectedRangeBgColor:
      - '{{ selection }}'
    cherryPickedCommitBgColor:
      - '{{ cyan }}'
    cherryPickedCommitFgColor:
      - '{{ accent }}'
    unstagedChangesColor:
      - '{{ red }}'
    defaultFgColor:
      - '{{ foreground }}'
git:
  # Pull strategy: rebase for feature branches
  pull:
    mode: 'rebase' # 'merge', 'rebase' or 'ff-only'
  # Push options
  push:
    # Prevent force push to main/master
    preventPushingFixupCommits: true
  # Fetch options
  fetch:
    prune: true
    pruneTags: true
  # Merge options
  merging:
    # Manual commit after merge
    manualCommit: false
    # Squash merge options
    squashMergeMessage: "Squash merge {{selectedRef}} into {{currentBranch}}"
  # Commit options
  commit:
    # Sign commits
    signOff: false
    # Verbose commit
    verbose: default # 'default', 'always' or 'never'
  # Branch options
  branchLogCmd: 'git log --graph --color=always --abbrev-commit --decorate --date=relative --pretty=medium {{branchName}} --'
  # Override default commands
  overrideGpg: false
  # Disable force pushing
  disableForcePushing: false
  # Parse emoji from commit message
  parseEmoji: true
  # Log order
  log:
    order: 'topo-order' # 'date-order', 'author-date-order', 'topo-order' or 'default'
    showGraph: 'always' # 'always', 'never' or 'when-maximised'
    showWholeGraph: false
  # Skip hooks
  skipHookPrefix: WIP
  # Auto fetch
  autoFetch: true
  autoRefresh: true
  fetchInterval: 60 # seconds
  # Branch sort order
  branchSort: '-committerdate' # '-committerdate', '-authordate', 'alphabetical'
  # Paging
  pagers:
    - colorArg: always
      pager: delta --dark --paging=never
      useConfig: false
# OS-specific commands
os:
  editPreset: 'nvim'
  edit: 'nvim {{filename}}'
  editAtLine: 'nvim +{{line}} {{filename}}'
  editAtLineAndWait: 'nvim +{{line}} {{filename}}'
  open: 'xdg-open {{filename}} > /dev/null'
  openLink: 'xdg-open {{link}} > /dev/null'
# Refresher updates files on a background goroutine
refresher:
  refreshInterval: 10 # seconds
  fetchInterval: 60 # seconds
# Update options
update:
  method: prompt # 'prompt', 'background', 'never'
  days: 14 # days between update checks
# Confirm on quit
confirmOnQuit: false
# Quit on top-level return
quitOnTopLevelReturn: false
# Disable startup popups
disableStartupPopups: false
# Custom commands for monorepo awareness
customCommands:
  - key: 'P'
    description: 'Smart push (checks for unpulled commits)'
    context: 'global'
    command: 'git push'
    output: terminal
  - key: '<c-p>'
    description: 'Smart pull (rebase on feature branches)'
    context: 'global'
    command: 'git pull --rebase'
    output: terminal
  - key: 'M'
    description: 'Show commits for current package (monorepo)'
    context: 'files'
    command: 'git log --oneline -- {{.SelectedFile.Name | quote}}'
  - key: '<c-d>'
    description: 'Show diff for current package (monorepo)'
    context: 'files'
    command: 'git diff -- {{.SelectedFile.Name | quote}}'
  - key: 'F'
    description: 'Force push with lease (safer than force)'
    context: 'global'
    command: 'git push --force-with-lease'
    prompts:
      - type: 'confirm'
        title: 'Force push with lease?'
        body: 'Are you sure you want to force push with lease?'
    output: terminal
# Keybindings
keybinding:
  universal:
    quit: 'q'
    quit-alt1: '<c-c>'
    return: '<esc>'
    quitWithoutChangingDirectory: 'Q'
    togglePanel: '<tab>'
    prevItem: '<up>'
    nextItem: '<down>'
    prevItem-alt: 'k'
    nextItem-alt: 'j'
    prevPage: ','
    nextPage: '.'
    gotoTop: '<'
    gotoBottom: '>'
    scrollLeft: 'H'
    scrollRight: 'L'
    prevBlock: '<left>'
    nextBlock: '<right>'
    prevBlock-alt: 'h'
    nextBlock-alt: 'l'
    jumpToBlock: ['1', '2', '3', '4', '5']
    nextMatch: 'n'
    prevMatch: 'N'
    optionMenu: <disabled>
    optionMenu-alt1: '?'
    select: '<space>'
    goInto: '<enter>'
    openRecentRepos: '<c-r>'
    confirm: '<enter>'
    remove: 'd'
    new: 'n'
    edit: 'e'
    openFile: 'o'
    scrollUpMain: '<pgup>'
    scrollDownMain: '<pgdown>'
    scrollUpMain-alt1: 'K'
    scrollDownMain-alt1: 'J'
    scrollUpMain-alt2: '<c-u>'
    scrollDownMain-alt2: '<c-d>'
    executeShellCommand: ':'
    createRebaseOptionsMenu: 'm'
    pushFiles: 'P'
    pullFiles: 'p'
    refresh: 'R'
    createPatchOptionsMenu: '<c-p>'
    nextTab: ']'
    prevTab: '['
    nextScreenMode: '+'
    prevScreenMode: '_'
    undo: 'z'
    redo: '<c-z>'
    filteringMenu: '<c-s>'
    diffingMenu: 'W'
    diffingMenu-alt: '<c-e>'
    copyToClipboard: '<c-o>'
    submitEditorText: '<enter>'
    appendNewline: '<a-enter>'
    extrasMenu: '@'
    toggleWhitespaceInDiffView: '<c-w>'
    increaseContextInDiffView: '}'
    decreaseContextInDiffView: '{'
  files:
    commitChanges: 'c'
    commitChangesWithoutHook: 'w'
    amendLastCommit: 'A'
    commitChangesWithEditor: 'C'
    ignoreFile: 'i'
    refreshFiles: 'r'
    stashAllChanges: 's'
    viewStashOptions: 'S'
    toggleStagedAll: 'a'
    viewResetOptions: 'D'
    fetch: 'f'
    toggleTreeView: '`'
    openMergeOptions: 'M'
    openStatusFilter: '<c-b>'
  branches:
    createPullRequest: 'o'
    viewPullRequestOptions: 'O'
    copyPullRequestURL: '<c-y>'
    checkoutBranchByName: 'c'
    forceCheckoutBranch: 'F'
    rebaseBranch: 'r'
    renameBranch: 'R'
    mergeIntoCurrentBranch: 'M'
    viewGitFlowOptions: 'i'
    fastForward: 'f'
    createTag: 'T'
    pushTag: 'P'
    setUpstream: 'u'
    fetchRemote: 'f'
  commits:
    squashDown: 's'
    renameCommit: 'r'
    renameCommitWithEditor: 'R'
    viewResetOptions: 'g'
    markCommitAsFixup: 'f'
    createFixupCommit: 'F'
    squashAboveCommits: 'S'
    moveDownCommit: '<c-j>'
    moveUpCommit: '<c-k>'
    amendToCommit: 'A'
    pickCommit: 'p'
    revertCommit: 't'
    cherryPickCopy: 'c'
    cherryPickCopyRange: 'C'
    pasteCommits: 'v'
    tagCommit: 'T'
    checkoutCommit: '<space>'
    resetCherryPick: '<c-R>'
    copyCommitMessageToClipboard: '<c-y>'
    openLogMenu: '<c-l>'
    viewBisectOptions: 'b'
  stash:
    popStash: 'g'
    renameStash: 'r'
  main:
    toggleDragSelect: 'v'
    toggleDragSelect-alt: 'V'
    toggleSelectHunk: 'a'
    pickBothHunks: 'b'
# Notification settings
notARepository: 'prompt' # 'prompt', 'create', 'skip' or 'quit'
# Prompt to confirm on force-push
promptToReturnFromSubprocess: true
