import React, { useState, useEffect } from "react";
import { getOpportunities } from "../services/api";

const Opportunities = () => {
  const [opportunities, setOpportunities] = useState([]);

  useEffect(() => {
    const fetchOpportunities = async () => {
      const fetchedOpportunities = await getOpportunities();
      setOpportunities(fetchedOpportunities);
    };

    fetchOpportunities();
  }, []);

  return (
    <div>
      <h2>Opportunities</h2>
      <table>
        <thead>
          <tr>
            <th>Opportunity ID</th>
            <th>Opportunity Type</th>
            <th>Location</th>
            <th>Employer ID</th>
            <th>Salary Benefits</th>
            <th>Eligibility Criteria</th>
          </tr>
        </thead>
        <tbody>
          {opportunities.length === 0 ? (
            <tr>
              <td colSpan="6">No opportunities available</td>
            </tr>
          ) : (
            opportunities.map((opportunity) => (
              <tr key={opportunity.opportunity_id}>
                <td>{opportunity.opportunity_id}</td>
                <td>{opportunity.opportunity_type}</td>
                <td>{opportunity.location}</td>
                <td>{opportunity.employer_id}</td>
                <td>{opportunity.salary_benefits}</td>
                <td>{opportunity.eligibility_criteria}</td>
              </tr>
            ))
          )}
        </tbody>
      </table>
    </div>
  );
};

export default Opportunities;
