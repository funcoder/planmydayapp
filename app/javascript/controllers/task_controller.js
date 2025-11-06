import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="task"
export default class extends Controller {
  static targets = ["item", "list"]
  
  connect() {
    console.log("Task controller connected with", this.itemTargets.length, "items")
    // Only enable drag and drop on non-touch devices
    if (!this.isTouchDevice()) {
      this.addDragListeners()
    } else {
      // Remove draggable attribute on mobile
      this.itemTargets.forEach(item => {
        item.removeAttribute('draggable')
        item.style.cursor = 'default'
      })
    }
  }

  isTouchDevice() {
    return (('ontouchstart' in window) ||
            (navigator.maxTouchPoints > 0) ||
            (navigator.msMaxTouchPoints > 0))
  }

  addDragListeners() {
    this.itemTargets.forEach(item => {
      // Remove any existing listeners
      item.removeEventListener('dragstart', this.dragStart)
      item.removeEventListener('dragend', this.dragEnd)

      // Add new listeners
      item.addEventListener('dragstart', this.dragStart.bind(this))
      item.addEventListener('dragend', this.dragEnd.bind(this))
    })

    // Add listeners to the list container
    if (this.hasListTarget) {
      this.listTarget.addEventListener('dragover', this.dragOver.bind(this))
      this.listTarget.addEventListener('drop', this.drop.bind(this))
    }
  }

  dragStart(e) {
    console.log("Drag started", e.target)
    this.draggedItem = e.target.closest('[data-task-target="item"]')
    this.draggedItem.style.opacity = '0.5'
    e.dataTransfer.effectAllowed = 'move'
    e.dataTransfer.setData('text/html', this.draggedItem.innerHTML)
  }

  dragEnd(e) {
    console.log("Drag ended")
    if (this.draggedItem) {
      this.draggedItem.style.opacity = ''
    }
    this.updateOrder()
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
    console.log("Dropped")
  }

  getDragAfterElement(y) {
    const draggableElements = [...this.listTarget.querySelectorAll('[data-task-target="item"]:not([style*="opacity: 0.5"])')];
    
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
    const ids = this.itemTargets.map(item => item.dataset.taskId)
    console.log("Updating order:", ids)
    
    try {
      const response = await fetch('/tasks/update_order', {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          'X-CSRF-Token': document.querySelector('[name="csrf-token"]').content
        },
        body: JSON.stringify({ task_ids: ids })
      })
      
      if (!response.ok) {
        console.error('Failed to update order')
      }
    } catch (error) {
      console.error('Error:', error)
    }
  }

  async complete(event) {
    event.preventDefault()
    console.log("Complete clicked")
    const button = event.currentTarget
    const taskItem = button.closest('[data-task-target="item"]')
    
    button.disabled = true
    button.textContent = "Completing..."
    
    try {
      const response = await fetch(button.dataset.url, {
        method: 'POST',
        headers: {
          'X-CSRF-Token': document.querySelector('[name="csrf-token"]').content,
          'Accept': 'text/html'
        }
      })
      
      if (response.ok) {
        taskItem.style.transition = 'all 0.3s'
        taskItem.style.opacity = '0'
        taskItem.style.transform = 'scale(0.8)'
        
        setTimeout(() => {
          window.location.reload()
        }, 300)
      }
    } catch (error) {
      console.error('Error:', error)
      button.disabled = false
      button.textContent = "Complete"
    }
  }

  async start(event) {
    event.preventDefault()
    console.log("Start clicked")
    const button = event.currentTarget
    const taskItem = button.closest('[data-task-target="item"]')
    
    button.disabled = true
    button.textContent = "Starting..."
    
    try {
      const response = await fetch(button.dataset.url, {
        method: 'POST',
        headers: {
          'X-CSRF-Token': document.querySelector('[name="csrf-token"]').content,
          'Accept': 'text/html'
        }
      })
      
      if (response.ok) {
        window.location.reload()
      }
    } catch (error) {
      console.error('Error:', error)
      button.disabled = false
      button.textContent = "Start"
    }
  }
}