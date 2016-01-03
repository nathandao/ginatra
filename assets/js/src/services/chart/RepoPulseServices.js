import request from 'reqwest';

import RepoPulseActions from 'actions/chart/RepoPulseActions';
import { API_CHART_REPO_PULSE } from 'constants/api';
import {
  PULSE_TIME_STAMPS,
  PULSE_TIME_LABELS,
} from 'constants/dashboard';

class RepoPulseServices {
  requestRepoPulses(repoIds) {
    repoIds.map((repoId) => {
      this.requestRepoPulse(repoId);
    });
  }

  requestRepoPulse(repoId) {
    let data = {
      in: repoId,
      time_stamps: PULSE_TIME_STAMPS,
      labels: PULSE_TIME_LABELS,
    };

    request({
      url: API_CHART_REPO_PULSE,
      method: 'get',
      type: 'json',
      contentType: 'application/json',
      data,
      success: (resp) => {
        RepoPulseActions.loadRepoPulse({
          repoId,
          chartData: resp,
        });
      },
    });
  }
}

export default new RepoPulseServices();
