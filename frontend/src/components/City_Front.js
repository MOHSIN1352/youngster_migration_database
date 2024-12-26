import React, { useState, useEffect } from "react";
import { getCities } from "../services/api";

const City = () => {
  const [cities, setCities] = useState([]);

  useEffect(() => {
    const fetchCities = async () => {
      const fetchedCities = await getCities();
      setCities(fetchedCities);
    };

    fetchCities();
  }, []);

  return (
    <div>
      <h2>Cities</h2>
      <table>
        <thead>
          <tr>
            <th>City ID</th>
            <th>City Name</th>
            <th>State ID</th>
          </tr>
        </thead>
        <tbody>
          {cities.length === 0 ? (
            <tr>
              <td colSpan="4">No cities available</td>
            </tr>
          ) : (
            cities.map((city) => (
              <tr key={city.city_id}>
                <td>{city.city_id}</td>
                <td>{city.city_name}</td>
                <td>{city.state_id}</td>
              </tr>
            ))
          )}
        </tbody>
      </table>
    </div>
  );
};

export default City;
