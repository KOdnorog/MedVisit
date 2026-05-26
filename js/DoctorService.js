class DoctorService {
  constructor(doctorsList) {
    this.doctors = doctorsList;
  }

  getDoctorsBySpecialty(specialty) {
    return this.doctors.filter(function (doctor) {
      return doctor.specialty === specialty;
    });
  }

  getDoctorById(id) {
    return this.doctors.find(function (doctor) {
      return doctor.id === id;
    });
  }
}
