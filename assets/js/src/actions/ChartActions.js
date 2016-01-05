import control from 'control';

class ChartActions {
  constructor() {
    this.generateActions(
      'loadRepoPulse',
      'requestRepoPulseError'
    );
  }
}

export default control.createActions(ChartActions);
