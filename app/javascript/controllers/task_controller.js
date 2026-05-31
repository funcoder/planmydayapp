import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="task"
export default class extends Controller {
  static targets = ["item", "list"]
  static values = { sortable: { type: Boolean, default: true } }

  connect() {
    this.boundDragStart = this.dragStart.bind(this)
    this.boundDragEnd = this.dragEnd.bind(this)
    this.boundDragOver = this.dragOver.bind(this)
    this.boundDrop = this.drop.bind(this)

    if (!this.isTouchDevice() && this.sortableValue && this.hasListTarget) {
      this.enableDragging()
      return
    }

    this.disableDragging()
  }

  disconnect() {
    this.teardownDragging()
  }

  isTouchDevice() {
    return (('ontouchstart' in window) ||
            (navigator.maxTouchPoints > 0) ||
            (navigator.msMaxTouchPoints > 0))
  }

  enableDragging() {
    this.teardownDragging()

    this.itemTargets.forEach(item => {
      item.setAttribute("draggable", "true")
      item.style.cursor = "grab"
      item.addEventListener("dragstart", this.boundDragStart)
      item.addEventListener("dragend", this.boundDragEnd)
    })

    this.listTargets.forEach(list => {
      list.addEventListener("dragover", this.boundDragOver)
      list.addEventListener("drop", this.boundDrop)
    })
  }

  disableDragging() {
    this.teardownDragging()

    this.itemTargets.forEach(item => {
      item.removeAttribute("draggable")
      item.style.cursor = ""
    })
  }

  teardownDragging() {
    this.itemTargets.forEach(item => {
      item.removeEventListener("dragstart", this.boundDragStart)
      item.removeEventListener("dragend", this.boundDragEnd)
    })

    this.listTargets.forEach(list => {
      list.removeEventListener("dragover", this.boundDragOver)
      list.removeEventListener("drop", this.boundDrop)
    })
  }

  dragStart(event) {
    this.draggedItem = event.currentTarget.closest('[data-task-target="item"]')
    this.dragSourceList = this.draggedItem?.closest('[data-task-target="list"]')

    if (!this.draggedItem || !this.dragSourceList) {
      return
    }

    this.draggedItem.style.opacity = "0.55"
    event.dataTransfer.effectAllowed = "move"
    event.dataTransfer.setData("text/plain", this.draggedItem.dataset.taskId)
  }

  dragEnd() {
    if (!this.draggedItem) {
      return
    }

    this.draggedItem.style.opacity = ""
    this.draggedItem = null
    this.dragSourceList = null
  }

  dragOver(event) {
    if (!this.draggedItem || event.currentTarget !== this.dragSourceList) {
      return
    }

    event.preventDefault()
    event.dataTransfer.dropEffect = "move"

    const list = event.currentTarget
    const afterElement = this.getDragAfterElement(list, event.clientY)
    if (afterElement == null) {
      list.appendChild(this.draggedItem)
    } else {
      list.insertBefore(this.draggedItem, afterElement)
    }
  }

  drop(event) {
    if (!this.draggedItem || event.currentTarget !== this.dragSourceList) {
      return
    }

    event.preventDefault()
    this.updateOrder()
  }

  getDragAfterElement(list, y) {
    const draggableElements = [...list.querySelectorAll('[data-task-target="item"]')].filter(
      item => item !== this.draggedItem
    )

    return draggableElements.reduce((closest, child) => {
      const box = child.getBoundingClientRect()
      const offset = y - box.top - box.height / 2

      if (offset < 0 && offset > closest.offset) {
        return { offset: offset, element: child }
      } else {
        return closest
      }
    }, { offset: Number.NEGATIVE_INFINITY }).element
  }

  async updateOrder() {
    const ids = [...this.element.querySelectorAll('[data-task-target="item"]')].map(item => item.dataset.taskId)

    try {
      const response = await fetch("/tasks/update_order", {
        method: "POST",
        headers: {
          "Content-Type": "application/json",
          "X-CSRF-Token": document.querySelector('[name="csrf-token"]').content
        },
        body: JSON.stringify({ task_ids: ids })
      })

      if (!response.ok) {
        console.error("Failed to update order")
      }
    } catch (error) {
      console.error("Error:", error)
    }
  }

  async complete(event) {
    event.preventDefault()
    const button = event.currentTarget
    const taskItem = button.closest('[data-task-target="item"]')
    const originalHtml = button.innerHTML

    button.disabled = true
    button.classList.add("opacity-80")
    button.innerHTML = `
      <svg class="w-4 h-4 animate-spin" viewBox="0 0 24 24" fill="none" aria-hidden="true">
        <circle class="opacity-30" cx="12" cy="12" r="9" stroke="currentColor" stroke-width="2"></circle>
        <path class="opacity-100" d="M21 12a9 9 0 00-9-9" stroke="currentColor" stroke-width="2" stroke-linecap="round"></path>
      </svg>
    `

    try {
      const response = await fetch(button.dataset.url, {
        method: "POST",
        headers: {
          "X-CSRF-Token": document.querySelector('[name="csrf-token"]').content,
          "Accept": "application/json"
        }
      })

      if (!response.ok) {
        throw new Error("Failed to complete task")
      }

      taskItem.style.transition = "all 0.25s ease"
      taskItem.style.opacity = "0"
      taskItem.style.transform = "scale(0.96)"

      setTimeout(() => {
        window.location.reload()
      }, 250)
    } catch (error) {
      console.error("Error:", error)
      button.disabled = false
      button.classList.remove("opacity-80")
      button.innerHTML = originalHtml
    }
  }

  async start(event) {
    event.preventDefault()
    const button = event.currentTarget
    const originalHtml = button.innerHTML

    button.disabled = true
    button.classList.add("opacity-80")
    button.innerHTML = `
      <svg class="w-4 h-4 animate-spin" viewBox="0 0 24 24" fill="none" aria-hidden="true">
        <circle class="opacity-30" cx="12" cy="12" r="9" stroke="currentColor" stroke-width="2"></circle>
        <path class="opacity-100" d="M21 12a9 9 0 00-9-9" stroke="currentColor" stroke-width="2" stroke-linecap="round"></path>
      </svg>
    `
    
    try {
      const response = await fetch(button.dataset.url, {
        method: 'POST',
        headers: {
          'X-CSRF-Token': document.querySelector('[name="csrf-token"]').content,
          'Accept': 'application/json'
        }
      })

      if (!response.ok) {
        throw new Error("Failed to start task")
      }

      window.location.reload()
    } catch (error) {
      console.error('Error:', error)
      button.disabled = false
      button.classList.remove("opacity-80")
      button.innerHTML = originalHtml
    }
  }
}
