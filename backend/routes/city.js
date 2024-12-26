const express = require("express");
const pool = require("../db/pool");
const router = express.Router();

// Get all cities
router.get("/", async (req, res) => {
  try {
    const result = await pool.query("SELECT * FROM City");
    res.json(result.rows);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// Add a new city
router.post("/", async (req, res) => {
  const { city_name, region_id, state_id } = req.body;
  try {
    const result = await pool.query(
      "INSERT INTO City (city_name, region_id, state_id) VALUES ($1, $2, $3) RETURNING *",
      [city_name, region_id, state_id]
    );
    res.json(result.rows[0]);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

module.exports = router;
