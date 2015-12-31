import request from 'reqwest';

import { API_CHART_REPO_PULSE } from 'constants/api';
import { PULSE_TIME_STAMPS } from 'constants/dashboard';

class RepoPulseServices {
  requestRepoPulse(repoId) {
    let data = {
      in: repoId,
      timeStamps: PULSE_TIME_STAMPS,
    };
    request({
      url: API_CHART_REPO_PULSE,
      data,
    });
  }
}

export default new RepoPulseServices();
