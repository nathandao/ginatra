import moment from 'moment';

// Dashboard.
export const DEFAULT_VISIBLE_REPOS = 6;

// Repo Pulse.
export const PULSE_PERIOD = 6;

let todayEnd = moment().hour(23).minute(59).second(59);
let pulseTimeStamps = [];
let pulseTimeLabels = [];

for (let i = PULSE_PERIOD; i >= 0; i--) {
  let diff = moment.duration(i, 'd');
  let currentDate = moment().hour(0).minute(0).second(0).subtract(diff);
  pulseTimeStamps.push(currentDate.format('DD-MM-YYYY hh:mm'));
  pulseTimeLabels.push(currentDate.format('ddd DD.MM'));
}
pulseTimeStamps.push(todayEnd.format('DD-MM-YYYY hh:mm'));
pulseTimeLabels.push(todayEnd.format('ddd DD.MM'));

export const PULSE_TIME_STAMPS = pulseTimeStamps;
export const PULSE_TIME_LABELS = pulseTimeLabels;
