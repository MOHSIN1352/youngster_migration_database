import React, { useState, useEffect } from "react";
import { getYoungsters } from "../services/api";

const Youngsters = () => {
  const [youngsters, setYoungsters] = useState([]);

  useEffect(() => {
    const fetchYoungsters = async () => {
      const fetchedYoungsters = await getYoungsters();
      setYoungsters(fetchedYoungsters);
    };

    fetchYoungsters();
  }, []);

  return (
    <div>
      <h2>Youngsters</h2>
      <table>
        <thead>
          <tr>
            <th>Youngster ID</th>
            <th>Name</th>
            <th>Email</th>
            <th>Gender</th>
            <th>Education ID</th>
            <th>Employment ID</th>
            <th>Place of Origin</th>
            <th>Date of Birth</th>
          </tr>
        </thead>
        <tbody>
          {youngsters.length === 0 ? (
            <tr>
              <td colSpan="8">No youngsters available</td>
            </tr>
          ) : (
            youngsters.map((youngster) => (
              <tr key={youngster.youngster_id}>
                <td>{youngster.youngster_id}</td>
                <td>{youngster.name}</td>
                <td>{youngster.email}</td>
                <td>{youngster.gender}</td>
                <td>{youngster.education_id}</td>
                <td>{youngster.employment_id}</td>
                <td>{youngster.place_of_origin}</td>
                <td>{youngster.date_of_birth}</td>
              </tr>
            ))
          )}
        </tbody>
      </table>
    </div>
  );
};

export default Youngsters;
