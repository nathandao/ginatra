import control from 'control';
import _ from 'lodash';

import ChartActions from 'actions/ChartActions';

class ChartStore {
  constructor() {
    this.bindActions(ChartActions);
    this.state = {
      pulses: [],
    };
  }

  onLoadRepoPulse(data) {
    let pulses = this.state.pulses;
    let index = _.findIndex(pulses, (pulse) => {
      return pulse.repoId === data.repoId;
    });

    if (index >= 0) {
      pulses[index] = data;
    } else {
      pulses.push(data);
    }

    this.setState({ pulses });
  }
}

export default control.createStore(ChartStore, 'ChartStore');
