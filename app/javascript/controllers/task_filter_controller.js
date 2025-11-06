import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="task-filter"
export default class extends Controller {
  static targets = ["task", "container"]

  connect() {
    // Apply pending filter by default on page load
    this.applyFilter('pending')
  }

  filter(event) {
    const filterValue = event.currentTarget.dataset.filterValue
    this.applyFilter(filterValue)
  }

  applyFilter(filterValue) {
    const filterButtons = this.element.querySelectorAll('button[data-action*="task-filter#filter"]')

    // Update active button style
    filterButtons.forEach(btn => {
      btn.classList.remove('bg-primary-600', 'text-white')
      btn.classList.add('bg-gray-100', 'text-gray-700', 'hover:bg-gray-200')
    })

    // Find and activate the button for this filter
    const activeButton = this.element.querySelector(`button[data-filter-value="${filterValue}"]`)
    if (activeButton) {
      activeButton.classList.remove('bg-gray-100', 'text-gray-700', 'hover:bg-gray-200')
      activeButton.classList.add('bg-primary-600', 'text-white')
    }

    // Filter tasks
    this.taskTargets.forEach(task => {
      const taskStatus = task.dataset.status
      const taskScheduled = task.dataset.scheduled
      const taskFrame = task.closest('turbo-frame')

      let shouldShow = false

      switch(filterValue) {
        case 'all':
          shouldShow = true
          break
        case 'today':
          shouldShow = taskScheduled === 'today'
          break
        case 'pending':
          shouldShow = taskStatus === 'pending'
          break
        case 'completed':
          shouldShow = taskStatus === 'completed'
          break
      }

      // Show/hide the turbo-frame wrapper using hidden attribute
      const elementToToggle = taskFrame || task
      if (shouldShow) {
        elementToToggle.removeAttribute('hidden')
        elementToToggle.style.display = ''
      } else {
        elementToToggle.setAttribute('hidden', '')
      }
    })
  }
}
