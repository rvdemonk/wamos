import { useEffect, useState } from "react";
import { storageParse } from "../utilities/StorageParse";

export function useLocalStorage(key) {
  const [value, setValue] = useState(() => {
    const initialValue = localStorage.getItem(key);
    if (initialValue === null) return false;
    return storageParse(initialValue);
  });

  useEffect(() => {
    localStorage.setItem(key, value);
  }, [key, value]);

  return [value, setValue];
}

export function eraseLocalStorage(key) {
  localStorage.removeItem(key);
}
