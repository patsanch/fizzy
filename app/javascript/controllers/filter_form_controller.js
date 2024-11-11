import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  removeFilter(event) {
    event.preventDefault()
    this.#removeButton(event.target.closest("button"))
  }

  clearCategory({ params: { name } }) {
    this.element.querySelectorAll(`input[name="${name}"]`).forEach(input => this.#removeButton(input.closest("button")))
  }

  #removeButton(button) {
    button.querySelector("input").disabled = true
    button.hidden = true
  }
}
