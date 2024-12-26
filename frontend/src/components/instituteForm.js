import React, { useState } from "react";
import { addInstitute } from "../services/api";
import "../App.css"

const AddInstitute = () => {
  const [formData, setFormData] = useState({
    name: "",
    tuition_fees: "",
    address: "",
    website: "",
    accreditation_status: false,
    established_year: "",
    type:""
  });

  const handleChange = (e) => {
    const { name, value, type, checked } = e.target;
    setFormData({
      ...formData,
      [name]: type === "checkbox" ? checked : value,
    });
  };

  const handleSubmit = async (e) => {
    e.preventDefault();
    try {
      const response = await addInstitute(formData);
      alert("Institute added successfully!");
      console.log(response); // Newly added institute details
    } catch (error) {
      console.error("Error adding institute:", error.message);
      alert("Failed to add institute. Please try again.");
    }
  };

  return (
    <div>
      <h2>Add Institute</h2>
      <form onSubmit={handleSubmit}>
        <label>
          Name:
          <input type="text" name="name" value={formData.name} onChange={handleChange} required />
        </label>
        <label>
          Tuition Fees:
          <input
            type="number"
            name="tuition_fees"
            value={formData.tuition_fees}
            onChange={handleChange}
          />
        </label>
        <label>
          Address:
          <textarea name="address" value={formData.address} onChange={handleChange} />
        </label>
        <label>
          Website:
          <input type="url" name="website" value={formData.website} onChange={handleChange} />
        </label>
        <label>
          Accreditation Status:
          <input
            type="checkbox"
            name="accreditation_status"
            checked={formData.accreditation_status}
            onChange={handleChange}
          />
        </label>
        <label>
          Established Year:
          <input
            type="number"
            name="established_year"
            value={formData.established_year}
            onChange={handleChange}
          />
        </label>
        <label>
          Type:
          <input
            type="text"
            name="type"
            value={formData.type}
            onChange={handleChange}
          />
        </label>
        <button type="submit">Add Institute</button>
      </form>
    </div>
  );
};

export default AddInstitute;
