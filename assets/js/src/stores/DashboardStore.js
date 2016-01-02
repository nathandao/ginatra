import control from 'control';
import _ from 'lodash';

import DashboardActions from 'actions/DashboardActions';

class DashboardStore {
  constructor() {
    this.bindListeners({
      // onFlushCaches: DashboardActions.flushCaches,
    });
  }
}

export default control.createStore(DashboardStore, 'DashboardStore');
