import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["item", "list"]

  connect() {
    if (!this.isTouchDevice()) {
      this.addDragListeners()
    } else {
      // Disable drag on touch devices
      this.itemTargets.forEach(item => {
        item.removeAttribute('draggable')
        item.style.cursor = 'default'
      })
    }
  }

  isTouchDevice() {
    return (('ontouchstart' in window) ||
            (navigator.maxTouchPoints > 0))
  }

  addDragListeners() {
    this.itemTargets.forEach(item => {
      item.setAttribute('draggable', 'true')
      item.addEventListener('dragstart', this.dragStart.bind(this))
      item.addEventListener('dragend', this.dragEnd.bind(this))
    })

    if (this.hasListTarget) {
      this.listTarget.addEventListener('dragover', this.dragOver.bind(this))
      this.listTarget.addEventListener('drop', this.drop.bind(this))
    }
  }

  dragStart(e) {
    this.draggedItem = e.target.closest('[data-note-target="item"]')
    if (this.draggedItem) {
      this.draggedItem.style.opacity = '0.5'
      e.dataTransfer.effectAllowed = 'move'
    }
  }

  dragEnd(e) {
    if (this.draggedItem) {
      this.draggedItem.style.opacity = ''
      this.updateOrder()
    }
  }

  dragOver(e) {
    e.preventDefault()
    e.dataTransfer.dropEffect = 'move'

    if (!this.draggedItem) return

    const afterElement = this.getDragAfterElement(e.clientY)
    if (afterElement == null) {
      this.listTarget.appendChild(this.draggedItem)
    } else {
      this.listTarget.insertBefore(this.draggedItem, afterElement)
    }
  }

  drop(e) {
    e.preventDefault()
  }

  getDragAfterElement(y) {
    const draggableElements = [...this.listTarget.querySelectorAll('[data-note-target="item"]:not([style*="opacity: 0.5"])')]

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
    const ids = this.itemTargets.map(item => item.dataset.noteId)

    try {
      const response = await fetch('/notes/update_order', {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          'X-CSRF-Token': document.querySelector('[name="csrf-token"]').content
        },
        body: JSON.stringify({ note_ids: ids })
      })

      if (!response.ok) {
        console.error('Failed to update note order')
      }
    } catch (error) {
      console.error('Error updating note order:', error)
    }
  }
}
