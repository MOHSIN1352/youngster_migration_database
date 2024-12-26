const express = require("express");
const pool = require("../db/pool");
const router = express.Router();

// Get all states
router.get("/", async (req, res) => {
  try {
    const result = await pool.query("SELECT * FROM State");
    console.log(result.rows);
    res.json(result.rows);
  } catch (error) {
    console.error("Error fetching states:", error.message);
    res.status(500).json({ error: "Database error" });
  }
});

// Add a new state
router.post("/", async (req, res) => {
  const { state_name } = req.body;
  try {
    const result = await pool.query(
      "INSERT INTO State (state_name) VALUES ($1) RETURNING *",
      [state_name]
    );
    res.json(result.rows[0]);
  } catch (error) {
    console.error("Error adding state:", error.message);
    res.status(500).json({ error: "Database error" });
  }
});

// Update a state
router.put("/:id", async (req, res) => {
  const { id } = req.params;
  const { state_name } = req.body;
  try {
    const result = await pool.query(
      "UPDATE State SET state_name = $1 WHERE state_id = $2 RETURNING *",
      [state_name, id]
    );
    res.json(result.rows[0]);
  } catch (error) {
    console.error("Error updating state:", error.message);
    res.status(500).json({ error: "Database error" });
  }
});

// Delete a state
router.delete("/:id", async (req, res) => {
  const { id } = req.params;
  try {
    const result = await pool.query(
      "DELETE FROM State WHERE state_id = $1 RETURNING *",
      [id]
    );
    res.json({ message: `State with ID ${id} deleted.` });
  } catch (error) {
    console.error("Error deleting state:", error.message);
    res.status(500).json({ error: "Database error" });
  }
});

module.exports = router;
