import control from 'control';

class DashboardActions {
  constructor() {
    this.generateActions(
      'flushCaches'
    );
  }
}

export default control.createActions(DashboardActions);
