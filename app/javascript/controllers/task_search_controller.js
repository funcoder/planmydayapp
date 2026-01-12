import { Controller } from "@hotwired/stimulus"

// Task search autocomplete controller
// Provides a searchable input for selecting tasks with many items
export default class extends Controller {
  static targets = ["input", "results", "hiddenInput", "selectedDisplay"]
  static values = {
    url: String,
    selectedId: Number,
    selectedTitle: String
  }

  connect() {
    this.debounceTimer = null

    // Initialize with existing selection
    if (this.selectedIdValue) {
      this.showSelected(this.selectedIdValue, this.selectedTitleValue)
    }

    // Close results when clicking outside
    document.addEventListener('click', this.handleClickOutside.bind(this))
  }

  disconnect() {
    document.removeEventListener('click', this.handleClickOutside.bind(this))
  }

  handleClickOutside(event) {
    if (!this.element.contains(event.target)) {
      this.hideResults()
    }
  }

  search() {
    clearTimeout(this.debounceTimer)

    const query = this.inputTarget.value.trim()

    if (query.length < 2) {
      this.hideResults()
      return
    }

    this.debounceTimer = setTimeout(() => {
      this.fetchResults(query)
    }, 300)
  }

  async fetchResults(query) {
    try {
      const response = await fetch(`${this.urlValue}?q=${encodeURIComponent(query)}`, {
        headers: {
          'Accept': 'application/json',
          'X-Requested-With': 'XMLHttpRequest'
        }
      })

      if (!response.ok) throw new Error('Search failed')

      const tasks = await response.json()
      this.displayResults(tasks)
    } catch (error) {
      console.error('Task search error:', error)
      this.hideResults()
    }
  }

  displayResults(tasks) {
    if (tasks.length === 0) {
      this.resultsTarget.innerHTML = `
        <div class="px-4 py-3 text-sm text-gray-500">
          No tasks found
        </div>
      `
    } else {
      this.resultsTarget.innerHTML = tasks.map(task => `
        <button type="button"
                class="w-full text-left px-4 py-3 hover:bg-gray-100 focus:bg-gray-100 focus:outline-none transition-colors"
                data-action="click->task-search#selectTask"
                data-task-id="${task.id}"
                data-task-title="${this.escapeHtml(task.title)}">
          <div class="text-sm font-medium text-gray-900">${this.escapeHtml(task.title)}</div>
          <div class="text-xs text-gray-500 capitalize">${task.status.replace('_', ' ')}</div>
        </button>
      `).join('')
    }

    this.resultsTarget.classList.remove('hidden')
  }

  hideResults() {
    this.resultsTarget.classList.add('hidden')
  }

  selectTask(event) {
    const button = event.currentTarget
    const taskId = button.dataset.taskId
    const taskTitle = button.dataset.taskTitle

    this.showSelected(taskId, taskTitle)
    this.hideResults()
    this.inputTarget.value = ''
  }

  showSelected(taskId, taskTitle) {
    this.hiddenInputTarget.value = taskId
    this.selectedDisplayTarget.innerHTML = `
      <div class="flex items-center justify-between bg-primary-50 border-2 border-primary-200 rounded-lg px-4 py-3">
        <span class="text-sm text-gray-900">${this.escapeHtml(taskTitle)}</span>
        <button type="button"
                class="text-gray-400 hover:text-gray-600 p-1"
                data-action="click->task-search#clearSelection">
          <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M6 18L18 6M6 6l12 12"></path>
          </svg>
        </button>
      </div>
    `
    this.selectedDisplayTarget.classList.remove('hidden')
    this.inputTarget.parentElement.classList.add('hidden')
  }

  clearSelection() {
    this.hiddenInputTarget.value = ''
    this.selectedDisplayTarget.classList.add('hidden')
    this.selectedDisplayTarget.innerHTML = ''
    this.inputTarget.parentElement.classList.remove('hidden')
    this.inputTarget.focus()
  }

  escapeHtml(text) {
    const div = document.createElement('div')
    div.textContent = text
    return div.innerHTML
  }
}
