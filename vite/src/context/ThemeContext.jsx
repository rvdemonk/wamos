import { createContext, useContext, useState, useEffect } from "react";
import { ethers } from "ethers";

const ThemeContext = createContext({});

export function useTheme() {
  return useContext(ThemeContext);
}

export function ThemeProvider({ children }) {
  const [theme, setTheme] = useState(false);

  useEffect(() => {
    var body = document.getElementById("root");
    const bodyClass = theme ? "bg-dark" : "bg-light";
    const bodyClassRemove = !theme ? "bg-dark" : "bg-light";
    body.classList.remove(bodyClassRemove);
    body.classList.add(bodyClass);
  }, [theme]);

  return (
    <ThemeContext.Provider value={{ theme, setTheme }}>
      {children}
    </ThemeContext.Provider>
  );
}
