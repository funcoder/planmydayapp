import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["column"]

  connect() {
    if (this.isTouchDevice()) return

    this.placeholder = this.createPlaceholder()

    this.columnTargets.forEach(column => {
      column.addEventListener("dragover", this.handleDragOver)
      column.addEventListener("dragleave", this.handleDragLeave)
      column.addEventListener("drop", this.handleDrop)
    })
  }

  disconnect() {
    this.removePlaceholder()
  }

  isTouchDevice() {
    return (("ontouchstart" in window) ||
            (navigator.maxTouchPoints > 0) ||
            (navigator.msMaxTouchPoints > 0))
  }

  createPlaceholder() {
    const el = document.createElement("div")
    el.style.cssText = "min-height: 72px; background: #eef2ff; border-radius: 0.5rem; display: flex; align-items: center; justify-content: center; outline: 2px dashed #818cf8; outline-offset: -2px;"
    el.innerHTML = '<p style="font-size: 0.875rem; color: #6366f1; font-weight: 500;">Drop here</p>'
    return el
  }

  removePlaceholder() {
    if (this.placeholder && this.placeholder.parentNode) {
      this.placeholder.parentNode.removeChild(this.placeholder)
    }
  }

  dragStart(event) {
    const card = event.currentTarget
    this.draggedTaskId = card.dataset.taskId
    this.draggedCard = card
    this.sourceColumn = card.closest("[data-kanban-target='column']").dataset.column
    card.style.opacity = "0.4"
    event.dataTransfer.effectAllowed = "move"
    event.dataTransfer.setData("text/plain", this.draggedTaskId)
  }

  dragEnd(event) {
    event.currentTarget.style.opacity = ""
    this.removePlaceholder()
    this.draggedCard = null
  }

  handleDragOver = (event) => {
    event.preventDefault()
    event.dataTransfer.dropEffect = "move"

    const column = event.currentTarget
    const taskList = column.querySelector("[data-drop-list]")
    if (!taskList) return

    const afterElement = this.getDropTarget(taskList, event.clientY)
    if (afterElement) {
      taskList.insertBefore(this.placeholder, afterElement)
    } else {
      taskList.appendChild(this.placeholder)
    }
  }

  handleDragLeave = (event) => {
    const column = event.currentTarget
    if (!column.contains(event.relatedTarget)) {
      const taskList = column.querySelector("[data-drop-list]")
      if (taskList && this.placeholder.parentNode === taskList) {
        this.removePlaceholder()
      }
    }
  }

  getDropTarget(taskList, y) {
    const cards = [...taskList.querySelectorAll("[data-task-id]")].filter(
      el => el !== this.draggedCard && el !== this.placeholder
    )

    return cards.reduce((closest, child) => {
      const box = child.getBoundingClientRect()
      const offset = y - box.top - box.height / 2
      if (offset < 0 && offset > closest.offset) {
        return { offset, element: child }
      }
      return closest
    }, { offset: Number.NEGATIVE_INFINITY }).element || null
  }

  handleDrop = async (event) => {
    event.preventDefault()

    const column = event.currentTarget
    const targetColumn = column.dataset.column
    const taskId = event.dataTransfer.getData("text/plain")

    if (!taskId || targetColumn === this.sourceColumn) {
      this.removePlaceholder()
      return
    }

    // Read the sibling task IDs in visual order before removing the placeholder
    const taskList = column.querySelector("[data-drop-list]")
    const orderedIds = [...taskList.querySelectorAll("[data-task-id]")]
      .filter(el => el !== this.draggedCard)
      .map(el => el.dataset.taskId)

    // Find where the placeholder sits among the cards
    const children = [...taskList.children].filter(el => el !== this.draggedCard)
    const placeholderIndex = children.indexOf(this.placeholder)
    // Insert the dragged task ID at that position
    const position = placeholderIndex >= 0 ? placeholderIndex : orderedIds.length
    orderedIds.splice(position, 0, taskId)

    this.removePlaceholder()

    try {
      const response = await fetch(`/tasks/${taskId}/move_to_column`, {
        method: "POST",
        headers: {
          "Content-Type": "application/json",
          "X-CSRF-Token": document.querySelector('[name="csrf-token"]').content
        },
        body: JSON.stringify({ column: targetColumn, task_ids: orderedIds })
      })

      if (response.ok) {
        window.location.reload()
      }
    } catch (error) {
      console.error("Failed to move task:", error)
    }
  }
}
