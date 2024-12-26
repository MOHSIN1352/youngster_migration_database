const express = require("express");
const pool = require("../db/pool");
const router = express.Router();

// Get all youngsters
router.get("/", async (req, res) => {
  try {
    const result = await pool.query("SELECT * FROM Youngster");
    res.json(result.rows);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

module.exports = router;
