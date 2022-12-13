import '../app.css';  

import React from "react";
import ReactDOM from "react-dom";
import { BrowserRouter as Router, Route } from "react-router-dom";



export function Article() {
    return (

      <Router>
          <div className = "article">
            <button className='article-button'>
              <h1>Mint</h1>
            </button>
          
            <button className='article-button'>
              <h1>Battle</h1>
            </button>
          
            <button className='article-button'>
              <h1>Breed -- LOCKED</h1>
            </button>
          </div>
      </Router>
    );
  }
  