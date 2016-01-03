import control from 'control';
import _ from 'lodash';

import RepoPulseActions from 'actions/chart/RepoPulseActions';
import InProgressActions from 'actions/InProgressActions';

class ChartStore {
  constructor() {
    this.bindActions(RepoPulseActions);
    this.bindListeners({
      onRequestRepoPulseStart: InProgressActions.requestRepoPulseStart,
    });

    this.state = {
      pulses: [],
    };
  }

  onRequestRepoPulseStart(repoId) {
    let pulses = this.state.pulses;
    let index = _.finIndex(pulses, (pulse) => {
      return pulse.repoId === repoId;
    });

    if (index < 0) {
      pulses.push({ repoId });
    }
    this.setState({ pulses });
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
