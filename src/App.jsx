import React from 'react';
import { BrowserRouter, Routes, Route } from 'react-router-dom';
import Calendar from './calendar';
import Privacy from './privacy';
import { Analytics } from '@vercel/analytics/react';

const App = () => {
  return (
    <BrowserRouter>
      <Routes>
        <Route path="/" element={<Calendar />} />
        <Route path="/privacy" element={<Privacy />} />
      </Routes>
      <Analytics />
    </BrowserRouter>
  );
};

export default App;

