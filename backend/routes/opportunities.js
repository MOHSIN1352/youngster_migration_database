const express = require("express");
const pool = require("../db/pool");
const router = express.Router();

// Get all opportunities
router.get("/", async (req, res) => {
  try {
    const result = await pool.query("SELECT * FROM Opportunities");
    res.json(result.rows);
  } catch (error) {
    console.error("Error fetching opportunities:", error.message);
    res.status(500).json({ error: "Database error" });
  }
});

/*
// Add a new opportunity
router.post("/", async (req, res) => {
  const { opportunity_type, location, employer_id, salary_benefits, eligibility_criteria } = req.body;
  try {
    const result = await pool.query(
      "INSERT INTO Opportunities (opportunity_type, location, employer_id, salary_benefits, eligibility_criteria) VALUES ($1, $2, $3, $4, $5) RETURNING *",
      [opportunity_type, location, employer_id, salary_benefits, eligibility_criteria]
    );
    res.json(result.rows[0]);
  } catch (error) {
    console.error("Error adding opportunity:", error.message);
    res.status(500).json({ error: "Database error" });
  }
});

// Update an opportunity
router.put("/:id", async (req, res) => {
  const { id } = req.params;
  const { opportunity_type, location, employer_id, salary_benefits, eligibility_criteria } = req.body;
  try {
    const result = await pool.query(
      "UPDATE Opportunities SET opportunity_type = $1, location = $2, employer_id = $3, salary_benefits = $4, eligibility_criteria = $5 WHERE opportunity_id = $6 RETURNING *",
      [opportunity_type, location, employer_id, salary_benefits, eligibility_criteria, id]
    );
    res.json(result.rows[0]);
  } catch (error) {
    console.error("Error updating opportunity:", error.message);
    res.status(500).json({ error: "Database error" });
  }
});

// Delete an opportunity
router.delete("/:id", async (req, res) => {
  const { id } = req.params;
  try {
    const result = await pool.query(
      "DELETE FROM Opportunities WHERE opportunity_id = $1 RETURNING *",
      [id]
    );
    res.json({ message: `Opportunity with ID ${id} deleted.` });
  } catch (error) {
    console.error("Error deleting opportunity:", error.message);
    res.status(500).json({ error: "Database error" });
  }
});*/

module.exports = router;
