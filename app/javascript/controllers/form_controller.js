import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  resetComponent() {
    const form = this.element;

    setTimeout(() => {
      form.reset();
      let errors_div = form.querySelector('.errors');
      if (errors_div) errors_div.remove();
    }, 100);
  }
}
