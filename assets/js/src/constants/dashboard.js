import moment from 'moment';

// Dashboard.
export const DEFAULT_VISIBLE_REPOS = 6;

// Repo Pulse.
export const PULSE_PERIOD = 7;

let todayEnd = moment.day(0).hour(23).minute(59).second(59);
let endTimeStamp = {};
let pulseTimeStamps = [];
endTimeStamp[todayEnd.format('ddd dd.mm')] = todayEnd;
pulseTimeStamps.push(endTimeStamp);

for (var i = 0; i++; i < REPO_PULSE) {
  let dateStamp = {};
  dateStamp[moment.day(-i).format('ddd dd.mm')] = moment.day(-i);
  pulseTimeStamps.push(dateStamp);
}

export const PULSE_TIME_STAMPS = pulseTimeStamps;
