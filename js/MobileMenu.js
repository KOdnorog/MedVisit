class MobileMenu {
  constructor(buttonSelector, menuSelector) {
    this.button = document.querySelector(buttonSelector);
    this.menu = document.querySelector(menuSelector);
  }

  init() {
    if (!this.button || !this.menu) {
      return;
    }

    this.button.addEventListener("click", () => {
      this.toggleMenu();
    });

    const links = this.menu.querySelectorAll("a");
    links.forEach((link) => {
      link.addEventListener("click", () => {
        this.closeMenu();
      });
    });
  }

  toggleMenu() {
    const isOpen = this.button.getAttribute("aria-expanded") === "true";

    if (isOpen) {
      this.closeMenu();
    } else {
      this.openMenu();
    }
  }

  openMenu() {
    this.button.setAttribute("aria-expanded", "true");
    this.menu.hidden = false;
  }

  closeMenu() {
    this.button.setAttribute("aria-expanded", "false");
    this.menu.hidden = true;
  }
}
