import React, { useState } from 'react';

const Calendar = () => {
  const today = new Date();
  // 初期表示は来月（1ヶ月先）
  const initialDate = new Date(today.getFullYear(), today.getMonth() + 1, 1);
  
  const [displayDate, setDisplayDate] = useState(initialDate);
  const [targetAmount, setTargetAmount] = useState('');
  const [hourlyWage, setHourlyWage] = useState('');
  const [workHours, setWorkHours] = useState('');
  const [selectedDays, setSelectedDays] = useState(new Set());
  const [errors, setErrors] = useState({});

  const displayYear = displayDate.getFullYear();
  const displayMonth = displayDate.getMonth();

  // 月の最初の日と最後の日を取得
  const firstDay = new Date(displayYear, displayMonth, 1);
  const lastDay = new Date(displayYear, displayMonth + 1, 0);
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
  const isCurrentMonth = today.getFullYear() === displayYear && today.getMonth() === displayMonth;

  // バリデーション
  const validateInputs = () => {
    const newErrors = {};
    
    const targetAmountNum = parseFloat(targetAmount);
    const hourlyWageNum = parseFloat(hourlyWage);
    const workHoursNum = parseFloat(workHours);

    if (!targetAmount || targetAmountNum <= 0 || isNaN(targetAmountNum)) {
      newErrors.targetAmount = '目標金額は0より大きい数値を入力してください';
    }
    
    if (!hourlyWage || hourlyWageNum <= 0 || isNaN(hourlyWageNum)) {
      newErrors.hourlyWage = '時給は0より大きい数値を入力してください';
    }
    
    if (!workHours || workHoursNum <= 0 || isNaN(workHoursNum)) {
      newErrors.workHours = '労働時間は0より大きい数値を入力してください';
    }

    setErrors(newErrors);
    return Object.keys(newErrors).length === 0;
  };

  // 等間隔に日付を選択する関数
  const calculateEvenlySpacedDays = (requiredDays, totalDays) => {
    if (requiredDays <= 0 || requiredDays > totalDays) {
      return new Set();
    }

    const selected = new Set();
    const interval = totalDays / requiredDays;
    
    for (let i = 0; i < requiredDays; i++) {
      const day = Math.floor(i * interval) + 1;
      selected.add(day);
    }

    return selected;
  };

  // シフト生成
  const generateShift = () => {
    if (!validateInputs()) {
      return;
    }

    const targetAmountNum = parseFloat(targetAmount);
    const hourlyWageNum = parseFloat(hourlyWage);
    const workHoursNum = parseFloat(workHours);

    // 必要な日数を計算（切り上げ）
    const totalEarningsPerDay = hourlyWageNum * workHoursNum;
    const requiredDays = Math.ceil(targetAmountNum / totalEarningsPerDay);

    // 等間隔に日付を選択
    const newSelectedDays = calculateEvenlySpacedDays(requiredDays, daysInMonth);
    setSelectedDays(newSelectedDays);
  };

  // 月を移動
  const changeMonth = (direction) => {
    setDisplayDate(prev => {
      const newDate = new Date(prev);
      newDate.setMonth(prev.getMonth() + direction);
      return newDate;
    });
    // 月が変わったら選択をリセット
    setSelectedDays(new Set());
  };

  return (
    <div className="calendar-container">
      <div className="input-section">
        <h2>シフト計算</h2>
        <div className="input-group">
          <label htmlFor="targetAmount">目標金額（円）</label>
          <input
            id="targetAmount"
            type="number"
            value={targetAmount}
            onChange={(e) => setTargetAmount(e.target.value)}
            placeholder="例: 100000"
            min="1"
            step="1"
          />
          {errors.targetAmount && <span className="error">{errors.targetAmount}</span>}
        </div>
        <div className="input-group">
          <label htmlFor="hourlyWage">時給（円）</label>
          <input
            id="hourlyWage"
            type="number"
            value={hourlyWage}
            onChange={(e) => setHourlyWage(e.target.value)}
            placeholder="例: 1000"
            min="1"
            step="1"
          />
          {errors.hourlyWage && <span className="error">{errors.hourlyWage}</span>}
        </div>
        <div className="input-group">
          <label htmlFor="workHours">1回の労働時間（時間）</label>
          <input
            id="workHours"
            type="number"
            value={workHours}
            onChange={(e) => setWorkHours(e.target.value)}
            placeholder="例: 8"
            min="0.1"
            step="0.1"
          />
          {errors.workHours && <span className="error">{errors.workHours}</span>}
        </div>
        <button className="generate-button" onClick={generateShift}>
          シフト生成
        </button>
      </div>

      <div className="calendar-header">
        <button className="month-nav-button" onClick={() => changeMonth(-1)}>
          ←
        </button>
        <h1>{displayYear}年 {monthNames[displayMonth]}</h1>
        <button className="month-nav-button" onClick={() => changeMonth(1)}>
          →
        </button>
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
          {calendarDays.map((day, index) => {
            const isToday = isCurrentMonth && day === currentDay;
            const isSelected = day !== null && selectedDays.has(day);
            
            return (
              <div
                key={index}
                className={`calendar-day ${day === null ? 'empty' : ''} ${isToday ? 'today' : ''} ${isSelected ? 'selected' : ''}`}
              >
                {day}
              </div>
            );
          })}
        </div>
      </div>
    </div>
  );
};

export default Calendar;

