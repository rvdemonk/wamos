// import '../app.css';
import { useEffect } from "react";

export function Gallery({state}) {
  
      return (
        <div className="article">
     
            <div>
                {state.allWamos.map( (item, index) => {
                    console.log("allwamos")
                    return (
                            <div>
                                <button className="article-button f"><h4>{`Wamo #${index} is owned by ${item[1].substring(0,6)}...${item[1].slice(-3)}`}</h4></button>
                            </div>
                        )})}

            </div>
        </div>)
      }

