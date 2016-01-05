import request from 'reqwest';

import ChartActions from 'actions/ChartActions';
import { API_CHART_TIMELINE_COMMITS } from 'constants/api';
import {
  PULSE_TIME_STAMPS,
  PULSE_TIME_LABELS,
} from 'constants/dashboard';

class ChartServices {
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
      url: API_CHART_TIMELINE_COMMITS,
      method: 'get',
      type: 'json',
      contentType: 'application/json',
      data,
      success: (resp) => {
        ChartActions.loadRepoPulse({
          repoId,
          chartData: resp,
        });
      },
    });
  }
}

export default new ChartServices();
