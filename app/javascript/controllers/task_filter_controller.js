import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="task-filter"
export default class extends Controller {
  static targets = ["task", "container"]

  filter(event) {
    const filterValue = event.currentTarget.dataset.filterValue
    const filterButtons = this.element.querySelectorAll('button[data-action*="task-filter#filter"]')

    // Update active button style
    filterButtons.forEach(btn => {
      btn.classList.remove('bg-purple-600', 'text-white')
      btn.classList.add('bg-gray-100', 'text-gray-700', 'hover:bg-gray-200')
    })
    event.currentTarget.classList.remove('bg-gray-100', 'text-gray-700', 'hover:bg-gray-200')
    event.currentTarget.classList.add('bg-purple-600', 'text-white')

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

      // Show/hide the turbo-frame wrapper
      const elementToToggle = taskFrame || task
      elementToToggle.style.display = shouldShow ? '' : 'none'
    })
  }
}
