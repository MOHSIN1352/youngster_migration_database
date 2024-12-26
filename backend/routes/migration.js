const express = require("express");
const pool = require("../db/pool");
const router = express.Router();

// Get all migration events
router.get("/", async (req, res) => {
  try {
    const result = await pool.query("SELECT * FROM Migration_Event");
    res.json(result.rows);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// Add a new migration event
router.post("/", async (req, res) => {
  const { youngster_id, duration, from, to } = req.body;
  try {
    const result = await pool.query(
      "INSERT INTO Migration_Event (youngster_id, duration, from, to) VALUES ($1, $2, $3, $4) RETURNING *",
      [youngster_id, duration, from, to]
    );
    res.json(result.rows[0]);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

module.exports = router;
