document.addEventListener("DOMContentLoaded", function () {
  const doctorService = new DoctorService(doctors);

  const mobileMenu = new MobileMenu(".nav-toggle", "#mobile-nav");
  mobileMenu.init();

  const bookingForm = new BookingForm("#booking-form", doctorService);
  bookingForm.init();
});
