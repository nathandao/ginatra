import control from 'control';
import _ from 'lodash';

import RepoPulseActions from 'actions/chart/RepoPulseActions';

class RepoPulseStore {
  constructor() {
    this.bindActions(RepoPulseActions);
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

export default control.createStore(RepoPulseStore, 'RepoPulseStore');
