import moment from 'moment';

// Dashboard.
export const DEFAULT_VISIBLE_REPOS = 6;

// Repo Pulse.
export const PULSE_PERIOD = 7;

let todayEnd = moment().day(0).hour(23).minute(59).second(59);
let pulseTimeStamps = [];
let pulseTimeLabels = [];
pulseTimeStamps.push(todayEnd.format('DD-MM-YYYY hh:mm'));
pulseTimeLabels.push(todayEnd.format('ddd DD.MM'));

for (let i = 0; i <= PULSE_PERIOD; i++) {
  let currentDate = moment().day(-i);
  pulseTimeStamps.push(currentDate.format('DD-MM-YYY hh:mm'));
  pulseTimeLabels.push(currentDate.format('ddd DD.MM'));
}

export const PULSE_TIME_STAMPS = pulseTimeStamps;
export const PULSE_TIME_LABELS = pulseTimeLabels;
