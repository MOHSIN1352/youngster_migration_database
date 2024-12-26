import React from "react";
import { Link } from "react-router-dom";
import "../App.css";

function Home() {
  return (
    <div className="home">
      <nav className="animated-navbar">
        <h1 className="navbar-title">Migration Dashboard</h1>
        <ul className="navbar-links">
          <li>
            <Link to="/youngsters">Youngsters</Link>
          </li>
          <li>
            <Link to="/city">City</Link>
          </li>
          <li>
            <Link to="/states">State</Link>
          </li>
          <li>
            <Link to="/opportunities">Opportunities</Link>
          </li>
          <li>
            <Link to="/migration">Migration</Link>
          </li>
        </ul>
      </nav>
      <div className="welcome-container">
        <h2 className="welcome-heading">Welcome to the Youngsters Migration Database</h2>
        <p className="welcome-message">
          Discover migration patterns, analyze opportunities, and explore data like never before.
        </p>
        <div>
          <Link to="/youngsters" className="glowing-button">Explore Youngsters</Link>
          <Link to="/city" className="glowing-button">Explore Cities</Link>
        </div>
      </div>
    </div>
  );
}

export default Home;
