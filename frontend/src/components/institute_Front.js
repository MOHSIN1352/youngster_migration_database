import React, { useState, useEffect } from "react";
import { getInstitutes } from "../services/api";

const Institutes = () => {
  const [institutes, setInstitutes] = useState([]);

  useEffect(() => {
    const fetchInstitutes = async () => {
      const fetchedInstitutes = await getInstitutes();
      setInstitutes(fetchedInstitutes);
    };

    fetchInstitutes();
  }, []);

  return (
    <div>
      <h2>Institutes</h2>
      <table>
        <thead>
          <tr>
            <th>Institution ID</th>
            <th>Name</th>
            <th>Tuition Fees</th>
            <th>Address</th>
            <th>Website</th>
            <th>Accreditation Status</th>
            <th>Established Year</th>
            <th>Type</th>
          </tr>
        </thead>
        <tbody>
          {institutes.length === 0 ? (
            <tr>
              <td colSpan="7">No institutes available</td>
            </tr>
          ) : (
            institutes.map((institute) => (
              <tr key={institute.institution_id}>
                <td>{institute.institution_id}</td>
                <td>{institute.name}</td>
                <td>{institute.tuition_fees}</td>
                <td>{institute.address}</td>
                <td>{institute.website}</td>
                <td>{institute.accreditation_status ? "Yes" : "No"}</td>
                <td>{institute.established_year}</td>
                <td>{institute.type}</td>

              </tr>
            ))
          )}
        </tbody>
      </table>
    </div>
  );
};

export default Institutes;
