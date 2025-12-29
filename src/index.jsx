import React from 'react';
import { createRoot } from 'react-dom/client';
import { Analytics } from '@vercel/analytics/react';
import Calendar from './calendar';
import './style.css';

const container = document.getElementById('root');
if (container) {
  const root = createRoot(container);
  root.render(
    <>
      <Calendar />
      <Analytics />
    </>
  );
}

