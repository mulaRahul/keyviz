import "./App.css";

import { I18nProvider, useI18n } from "./i18n";
import { Suspense, lazy } from "react";
import { HashRouter, Route, Routes } from "react-router-dom";
import { ThemeProvider } from "./components/theme-provider";
import { Toaster } from "./components/ui/sonner";
import { Visualization } from "./pages/visualization";

const Settings = lazy(() => import("./pages/settings"));

function AppRoutes() {
  const { t } = useI18n();

  return (
    <HashRouter>
      <Suspense fallback={<div>{t("Loading...", "加载中...")}</div>}>
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

function App() {
  return (
    <I18nProvider>
      <AppRoutes />
    </I18nProvider>
  );
}

export default App;
