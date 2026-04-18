import "./App.css";

import { Suspense, lazy } from "react";
import { HashRouter, Route, Routes } from "react-router-dom";
import { ThemeProvider } from "./components/theme-provider";
import { Toaster } from "./components/ui/sonner";
import { Visualization } from "./pages/visualization";

const Settings = lazy(() => import("./pages/settings"));

function App() {
  return (
    <HashRouter>
      <Suspense fallback={<div>Loading...</div>}>
        <Routes>
          <Route path="/" element={<Visualization />} />
          <Route path="/settings" element={
            <ThemeProvider>
              <Settings />
              <Toaster position="bottom-right" />
            </ThemeProvider>
          } />
        </Routes>
      </Suspense>
    </HashRouter>
  );
}

export default App;
