const express = require("express");
const pool = require("../db/pool");
const router = express.Router();

// Get all institutes
router.get("/", async (req, res) => {
  try {
    const result = await pool.query("SELECT * FROM Institute");
    res.json(result.rows);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// Add a new institute
router.post("/", async (req, res) => {
    
      const {
        name,
        tuition_fees,
        address,
        website,
        accreditation_status,
        established_year,
        type,
      } = req.body;

      if (!type) {
        return res.status(400).json({ error: 'Type is required' });
      } 

      console.log("Received data:", req.body); // Log received data

      try {
      const result = await pool.query(
        `INSERT INTO Institute 
        (name, tuition_fees, address, website, accreditation_status, established_year,type)
        VALUES ($1, $2, $3, $4, $5, $6, $7) RETURNING *`,
        [name, tuition_fees, address, website, accreditation_status, established_year, type]
      );

      console.log("Inserted institute:", result.rows[0]); // Log the inserted data

  
      res.status(201).json(result.rows[0]); // Return the newly created institute
    } catch (error) {
      console.error("Error inserting institute:", error.message);
      res.status(500).json({ error: error.message });
    }
  });
  
  

module.exports = router;
