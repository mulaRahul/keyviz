import "./App.css";

import { Suspense, lazy } from "react";
import { HashRouter, Route, Routes } from "react-router-dom";
import { ThemeProvider } from "./components/theme-provider";
import { Toaster } from "./components/ui/sonner";
import { Visualization } from "./pages/visualization";
import { useTranslation } from 'react-i18next';
import { Overlay } from "./pages/overlay";
import { Keys } from "./pages/keys";

const Settings = lazy(() => import("./pages/settings"));

function App() {
  const { t } = useTranslation();
  return (
    <HashRouter>
      <Suspense fallback={<div>{t('loading', 'Loading...')}</div>}>
        <Routes>
          <Route path="/" element={<Visualization />} />
          <Route path="/overlay" element={<Overlay />} />
          <Route path="/keys" element={<Keys />} />
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
