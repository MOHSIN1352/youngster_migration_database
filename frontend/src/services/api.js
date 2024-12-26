import axios from "axios";
const API_URL = process.env.REACT_APP_API_URL || "http://localhost:5000/api";  // Backend URL


const fetchData = async (url) => {
  try {
    const response = await fetch(`${API_URL}${url}`);
    if (!response.ok) {
      throw new Error(`Error: ${response.status} - ${response.statusText}`);
    }
    const data = await response.json();
    return data;
  } catch (error) {
    console.error("API fetch error:", error);
    throw error;
  }
};

export const getStates = async () => {
  return await fetchData("/state");
};

export const getCities = async () => {
  return await fetchData("/city");
};

export const getOpportunities = async () => {
  return await fetchData("/opportunities");
};

export const getYoungsters = async () => {
  return await fetchData("/youngsters");
};

export const getMigrations = async () => {
  return await fetchData("/migration");
};


// Fetch Institutes
export const getInstitutes = async () => {
  return await fetchData("/institute");
};


export const addInstitute = async (formData) => {
  try {
    const response = await axios.post("http://localhost:5000/api/institute", formData);
    return response.data;
  } catch (error) {
    console.error("Error adding institute:", error);
    throw error;
  }
};
