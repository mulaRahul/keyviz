import React from "react";
import ReactDOM from "react-dom/client";
import App from "./App";
import { initializeLanguage } from "./i18n";

initializeLanguage().then(() => {
  ReactDOM.createRoot(document.getElementById("root") as HTMLElement).render(
    <React.StrictMode>
      <App />
    </React.StrictMode>,
  );
}).catch((error: unknown) => {
  console.error("Failed to initialize language", error);
});
