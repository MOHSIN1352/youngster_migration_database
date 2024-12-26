import React, { useState, useEffect } from "react";
import { getMigrations } from "../services/api";

const Migration = () => {
  const [migrations, setMigrations] = useState([]);

  useEffect(() => {
    const fetchMigrations = async () => {
      const fetchedMigrations = await getMigrations();
      setMigrations(fetchedMigrations);
    };

    fetchMigrations();
  }, []);

  return (
    <div>
      <h2>Migrations</h2>
      <table>
        <thead>
          <tr>
            <th>Migration ID</th>
            <th>Youngster ID</th>
            <th>Duration</th>
            <th>From City</th>
            <th>To City</th>
            <th>Migration Date</th>
          </tr>
        </thead>
        <tbody>
          {migrations.length === 0 ? (
            <tr>
              <td colSpan="5">No migrations available</td>
            </tr>
          ) : (
            migrations.map((migration) => (
              <tr key={migration.migration_id}>
                <td>{migration.migration_id}</td>
                <td>{migration.youngster_id}</td>
                <td>{migration.duration}</td>
                <td>{migration.from_region}</td>
                <td>{migration.to_region}</td>
                <td>{migration.migration_date}</td>

              </tr>
            ))
          )}
        </tbody>
      </table>
    </div>
  );
};

export default Migration;
