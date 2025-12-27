import "./App.css";

import { Suspense, lazy } from "react";
import { HashRouter, Routes, Route } from "react-router-dom";
import { ThemeProvider } from "./components/theme-provider";

const Settings = lazy(() => import("./pages/settings"));

function App() {
  return (
    <HashRouter>
      <Suspense fallback={<div>Loading...</div>}>
        <Routes>
          {/* <Route path="/" element={<Visualization />} /> */}
          <Route path="/" element={<ThemeProvider><Settings /></ThemeProvider>} />
          <Route path="/settings" element={<Settings />} />
        </Routes>
      </Suspense>
    </HashRouter>
  );
}

export default App;
