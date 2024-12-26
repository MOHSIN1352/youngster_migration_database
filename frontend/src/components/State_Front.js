import React, { useState, useEffect } from "react";
import { getStates } from "../services/api";

const State = () => {
  const [states, setStates] = useState([]);

  useEffect(() => {
    const fetchStates = async () => {
      const fetchedStates = await getStates();
      setStates(fetchedStates);
    };

    fetchStates();
  }, []);

  return (
    <div>
      <h2>States</h2>
      <table>
        <thead>
          <tr>
            <th>State ID</th>
            <th>State Name</th>
          </tr>
        </thead>
        <tbody>
          {states.length === 0 ? (
            <tr>
              <td colSpan="2">No states available</td>
            </tr>
          ) : (
            states.map((state) => (
              <tr key={state.state_id}>
                <td>{state.state_id}</td>
                <td>{state.state_name}</td>
              </tr>
            ))
          )}
        </tbody>
      </table>
    </div>
  );
};

export default State;
