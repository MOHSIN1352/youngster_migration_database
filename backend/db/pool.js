const { Pool } = require("pg");

const pool = new Pool({
  user: "postgres",              // Database username
  host: "localhost",             // Database host
  database: "Youngsters_db",     // Database name
  password: "Mohsin@1352",       // Database password
  port: 5432,                    // PostgreSQL default port
});

module.exports = pool;
