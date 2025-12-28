import React from 'react';

const Calendar = () => {
  const today = new Date();
  const currentYear = today.getFullYear();
  const currentMonth = today.getMonth();

  // 月の最初の日と最後の日を取得
  const firstDay = new Date(currentYear, currentMonth, 1);
  const lastDay = new Date(currentYear, currentMonth + 1, 0);
  const daysInMonth = lastDay.getDate();
  const startingDayOfWeek = firstDay.getDay(); // 0 (日曜) から 6 (土曜)

  // カレンダーの日付配列を作成
  const calendarDays = [];
  
  // 前月の空白セルを追加
  for (let i = 0; i < startingDayOfWeek; i++) {
    calendarDays.push(null);
  }
  
  // 今月の日付を追加
  for (let day = 1; day <= daysInMonth; day++) {
    calendarDays.push(day);
  }

  // 曜日のラベル
  const weekDays = ['日', '月', '火', '水', '木', '金', '土'];
  
  // 月の名前
  const monthNames = [
    '1月', '2月', '3月', '4月', '5月', '6月',
    '7月', '8月', '9月', '10月', '11月', '12月'
  ];

  const currentDay = today.getDate();

  return (
    <div className="calendar-container">
      <div className="calendar-header">
        <h1>{currentYear}年 {monthNames[currentMonth]}</h1>
      </div>
      <div className="calendar">
        <div className="calendar-weekdays">
          {weekDays.map((day, index) => (
            <div key={index} className="weekday">
              {day}
            </div>
          ))}
        </div>
        <div className="calendar-days">
          {calendarDays.map((day, index) => (
            <div
              key={index}
              className={`calendar-day ${day === null ? 'empty' : ''} ${day === currentDay ? 'today' : ''}`}
            >
              {day}
            </div>
          ))}
        </div>
      </div>
    </div>
  );
};

export default Calendar;

