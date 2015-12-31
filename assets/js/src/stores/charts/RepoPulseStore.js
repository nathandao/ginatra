import control from 'control';

import RepoPulseActions from 'actions/chart/RepoPulseActions';
import RepoActions from 'actions/RepoActions';
import RepoStore from 'stores/RepoStore';

class RepoPulseStore {
  constructor() {
    this.bindActions(
      'repoPulseActions'
    );
    this.state = {
      pulses: [],
    };
  }
}

export default control.createStore(RepoPulseStore, 'RepoPulseStore');
