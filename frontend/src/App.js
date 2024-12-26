import React from "react";
import { BrowserRouter as Router, Routes, Route } from "react-router-dom";
import Home from "./components/HomePage";
import Youngsters from "./components/Youngsters_Front";
import City from "./components/City_Front";
import State from "./components/State_Front";
import Opportunities from "./components/Opportunities_Front";
import Migration from "./components/Migration_Front";
import "./App.css";
import InstituteList from "./components/institute_Front";
import AddInstitute from "./components/instituteForm";

function App() {
  return (
    <Router>
      <div className="App">
        <h1>Youngsters Migration Database</h1>
        <Routes>
          <Route path="/" element={<Home />} />
          <Route path="/youngsters" element={<Youngsters />} />
          <Route path="/city" element={<City />} />
          <Route path="/states" element={<State />} />
          <Route path="/opportunities" element={<Opportunities />} />
          <Route path="/migration" element={<Migration />} />
          <Route path="/institute" element={<InstituteList/>}/>
          <Route path="/add-institute" element={<AddInstitute/>}/>
        </Routes>
      </div>
    </Router>
  );
}

export default App;

