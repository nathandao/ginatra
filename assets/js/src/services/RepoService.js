import request from "reqwest";
import when from "when";

import RepoActions from "actions/RepoActions";
import {
  API_CHART_REPO_PULSE,
  PULSE_PERIOD
} from "constants";

class RepoService {

  getPulseData(repoIds) {
    when.reduce(when.map(repoIds, this.getSinglePulseData),this.combinePulse).
         done(result => {
           var pulses = {};
           for (var i = 0; i < result.length; i ++) {
             var repoId = Object.keys(result[i])[0];
             pulses[repoId] = result[i][repoId];
           }
           RepoActions.updatePulseData(pulses);
         });
  }

  getSinglePulseData = repoId => {
    var data = {
      in: repoId,
      time_stamps: this._pulseTimestamps()
    };

    return this._handleRequest(when(request({
      url: API_CHART_REPO_PULSE,
      method: "get",
      type: "json",
      dataType: "application/json",
      data: data
    })), repoId);
  }

  combinePulse(pulse1, pulse2) {
    return pulse1.concat(pulse2);
  }

  _handleRequest(promise, repoId) {
    return promise.then(resp => {
      var result = {};
      result[repoId] = resp;
      return [result];
    });
  }

  _pulseTimestamps() {
    var timestamps = [];

    for (var i = PULSE_PERIOD; i >= 3; i--) {
      timestamps = timestamps.concat(i + " days ago at 0:00");
    }

    timestamps = timestamps.concat([
      "yesterday at 0:00",
      "today at 0:00",
      "today at 23:59:59"
    ]);

    return timestamps;
  }

}

export default new RepoService();
