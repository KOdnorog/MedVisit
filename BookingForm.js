class BookingForm {
  constructor(formSelector, doctorService) {
    this.form = document.querySelector(formSelector);
    this.doctorService = doctorService;
    this.currentStep = 1;
    this.totalSteps = 4;
  }

  init() {
    if (!this.form) {
      return;
    }

    this.steps = this.form.querySelectorAll(".form-step");
    this.progressFill = document.querySelector("#progress-fill");
    this.progressLabel = document.querySelector("#progress-label");
    this.backButton = document.querySelector("#btn-back");
    this.nextButton = document.querySelector("#btn-next");
    this.submitButton = document.querySelector("#btn-submit");
    this.doctorSelect = document.querySelector("#doctor");
    this.doctorHint = document.querySelector("#doctor-hint");
    this.dateInput = document.querySelector("#date");
    this.slotsBox = document.querySelector("#slots");
    this.timeInput = document.querySelector("#time");
    this.slotError = document.querySelector("#slot-error");
    this.successPanel = document.querySelector("#success");
    this.successSummary = document.querySelector("#success-summary");
    this.newBookingButton = document.querySelector("#btn-new-booking");

    this.setMinDate();
    this.addEvents();
    this.updateDoctorSelect();
    this.drawSlots();
    this.showStep(1);
  }

  addEvents() {
    this.backButton.addEventListener("click", () => {
      this.showStep(this.currentStep - 1);
    });

    this.nextButton.addEventListener("click", () => {
      if (this.isStepValid()) {
        this.showStep(this.currentStep + 1);
      }
    });

    this.form.addEventListener("submit", (event) => {
      event.preventDefault();
      this.sendForm();
    });

    this.newBookingButton.addEventListener("click", () => {
      this.resetForm();
    });

    const specialtyInputs = this.form.querySelectorAll("input[name='specialty']");
    specialtyInputs.forEach((input) => {
      input.addEventListener("change", () => {
        this.updateDoctorSelect();
      });
    });

    this.dateInput.addEventListener("change", () => {
      this.timeInput.value = "";
      this.drawSlots();
    });

    const doctorButtons = document.querySelectorAll(".js-pick-doctor");
    doctorButtons.forEach((button) => {
      button.addEventListener("click", () => {
        this.pickDoctorFromCard(button.dataset.id);
      });
    });
  }

  getSelectedSpecialty() {
    const checkedInput = this.form.querySelector("input[name='specialty']:checked");
    return checkedInput ? checkedInput.value : "therapy";
  }

  updateDoctorSelect(selectedDoctorId) {
    const specialty = this.getSelectedSpecialty();
    const filteredDoctors = this.doctorService.getDoctorsBySpecialty(specialty);

    this.doctorSelect.innerHTML = "";

    const emptyOption = document.createElement("option");
    emptyOption.value = "";
    emptyOption.textContent = "— Выберите врача —";
    this.doctorSelect.appendChild(emptyOption);

    filteredDoctors.forEach((doctor) => {
      const option = document.createElement("option");
      option.value = doctor.id;
      option.textContent = doctor.name + " — " + doctor.specialtyName;
      this.doctorSelect.appendChild(option);
    });

    if (selectedDoctorId) {
      this.doctorSelect.value = selectedDoctorId;
    }

    this.doctorHint.textContent = "Показаны врачи по выбранной специализации.";
  }

  pickDoctorFromCard(doctorId) {
    const doctor = this.doctorService.getDoctorById(doctorId);

    if (!doctor) {
      return;
    }

    const specialtyInput = this.form.querySelector("input[value='" + doctor.specialty + "']");
    if (specialtyInput) {
      specialtyInput.checked = true;
    }

    this.updateDoctorSelect(doctor.id);
    this.showStep(2);

    const bookingBlock = document.querySelector("#booking");
    bookingBlock.scrollIntoView({ behavior: "smooth" });
  }

  setMinDate() {
    const today = new Date();
    const year = today.getFullYear();
    const month = String(today.getMonth() + 1).padStart(2, "0");
    const day = String(today.getDate()).padStart(2, "0");
    const date = year + "-" + month + "-" + day;

    this.dateInput.min = date;
    this.dateInput.value = date;
  }

  drawSlots() {
    this.slotsBox.innerHTML = "";

    const date = new Date(this.dateInput.value);
    const dayNumber = date.getDay();
    const isWeekend = dayNumber === 0 || dayNumber === 6;
    const list = isWeekend ? slots.weekend : slots.weekday;

    list.forEach((time) => {
      const button = document.createElement("button");
      button.type = "button";
      button.className = "slot-btn";
      button.textContent = time;

      button.addEventListener("click", () => {
        this.selectSlot(button, time);
      });

      this.slotsBox.appendChild(button);
    });
  }

  selectSlot(button, time) {
    const buttons = this.slotsBox.querySelectorAll(".slot-btn");

    buttons.forEach((item) => {
      item.classList.remove("is-selected");
    });

    button.classList.add("is-selected");
    this.timeInput.value = time;
    this.slotError.hidden = true;
  }

  showStep(stepNumber) {
    if (stepNumber < 1 || stepNumber > this.totalSteps) {
      return;
    }

    this.currentStep = stepNumber;

    this.steps.forEach((step) => {
      const number = Number(step.dataset.step);
      step.classList.toggle("is-active", number === this.currentStep);
    });

    this.backButton.hidden = this.currentStep === 1;
    this.nextButton.hidden = this.currentStep === this.totalSteps;
    this.submitButton.hidden = this.currentStep !== this.totalSteps;

    const progress = (this.currentStep / this.totalSteps) * 100;
    this.progressFill.style.width = progress + "%";
    this.progressLabel.textContent = "Шаг " + this.currentStep + " из " + this.totalSteps;
  }

  isStepValid() {
    if (this.currentStep === 2 && !this.doctorSelect.value) {
      this.doctorSelect.reportValidity();
      return false;
    }

    if (this.currentStep === 3 && !this.timeInput.value) {
      this.slotError.hidden = false;
      return false;
    }

    return true;
  }

  sendForm() {
    if (!this.form.checkValidity()) {
      this.form.reportValidity();
      return;
    }

    if (!this.timeInput.value) {
      this.showStep(3);
      this.slotError.hidden = false;
      return;
    }

    const data = new FormData(this.form);
    const doctor = this.doctorService.getDoctorById(data.get("doctor"));
    const patientName = data.get("name");
    const date = data.get("date");
    const time = data.get("time");

    this.successSummary.textContent =
      patientName + ", вы записаны к врачу " + doctor.name + " на " + date + " в " + time + ".";

    this.form.hidden = true;
    this.successPanel.hidden = false;
  }

  resetForm() {
    this.form.reset();
    this.setMinDate();
    this.timeInput.value = "";
    this.slotError.hidden = true;
    this.updateDoctorSelect();
    this.drawSlots();
    this.showStep(1);

    this.successPanel.hidden = true;
    this.form.hidden = false;
  }
}
